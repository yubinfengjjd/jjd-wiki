#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
train_uc_bayes_stacking_v1.py

v1 (single-file) implementation of:
- Multiple base learners
- skopt Bayesian hyperparameter optimization (5-fold Stratified CV) on TRAIN only
- Stacking ensemble (LogisticRegression meta-learner)
- Diagnostic metrics for UC binary classification
- Interpretability (SHAP + permutation importance + PDP)
- "Top-journal style" ROC plots:
  (1) 8-panel univariate ROC (one gene per panel) with right-side AUC strip
  (2) Multigene ROC comparison (all models + stacking)

Input:
- Expression matrix file (default: merge.normalize.txt), CSV/TSV auto-detected.
- Must contain label column (default: "label") and gene columns listed in gene_list_path.

Gene list file (user provided):
/mnt/data/output_mRNA_selected.txt

Usage example:
python train_uc_bayes_stacking_v1.py \
  --data merge.normalize.txt \
  --label_col label \
  --gene_list_path /mnt/data/output_mRNA_selected.txt \
  --outdir outputs/run1 \
  --n_iter 100
"""

from __future__ import annotations

import argparse
import json
import warnings
warnings.filterwarnings("ignore")

import numpy as np
import pandas as pd

from pathlib import Path
from dataclasses import dataclass
from typing import Dict, List, Tuple, Optional

from sklearn.model_selection import train_test_split, StratifiedKFold
from sklearn.metrics import (
    roc_auc_score, roc_curve, average_precision_score, precision_recall_curve,
    accuracy_score, precision_score, recall_score, f1_score, confusion_matrix,
    brier_score_loss
)
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier
from sklearn.neighbors import KNeighborsClassifier
from sklearn.svm import SVC
from sklearn.gaussian_process import GaussianProcessClassifier
from sklearn.gaussian_process.kernels import RBF, ConstantKernel as C
from sklearn.base import BaseEstimator, ClassifierMixin
from sklearn.inspection import permutation_importance, PartialDependenceDisplay
from sklearn.calibration import calibration_curve

# IterativeImputer is experimental
from sklearn.experimental import enable_iterative_imputer  # noqa: F401
from sklearn.impute import IterativeImputer

import joblib

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
from mpl_toolkits.axes_grid1.inset_locator import inset_axes
import matplotlib.patches as patches

# Optional third-party ML libs
try:
    from xgboost import XGBClassifier
except Exception:
    XGBClassifier = None

try:
    from lightgbm import LGBMClassifier, LGBMRegressor
except Exception:
    LGBMClassifier, LGBMRegressor = None, None

try:
    from catboost import CatBoostClassifier
except Exception:
    CatBoostClassifier = None

# Bayesian optimization (skopt)
try:
    from skopt import BayesSearchCV
    from skopt.space import Real, Integer, Categorical
except Exception:
    BayesSearchCV = None
    Real = Integer = Categorical = None

# SHAP
try:
    import shap
except Exception:
    shap = None

try:
    import torch
    import torch.nn as nn
    from torch.utils.data import DataLoader, TensorDataset
except Exception:
    torch = None
    nn = None
    DataLoader = None
    TensorDataset = None


def set_all_seeds(seed: int = 42) -> None:
    import random
    random.seed(seed)
    np.random.seed(seed)
    try:
        import torch
        torch.manual_seed(seed)
        torch.cuda.manual_seed_all(seed)
        torch.backends.cudnn.deterministic = True
        torch.backends.cudnn.benchmark = False
    except Exception:
        pass


def read_gene_list(gene_list_path: str) -> List[str]:
    """Read gene list (one per line). Ignores empty lines and trivial headers like 'x'."""
    genes: List[str] = []
    with open(gene_list_path, "r", encoding="utf-8") as f:
        for line in f:
            g = line.strip()
            if not g:
                continue
            if g.lower() in {"x", "gene", "genes"}:
                continue
            if g.startswith("#"):
                continue
            genes.append(g)
    # de-duplicate preserving order
    seen = set()
    out = []
    for g in genes:
        if g not in seen:
            out.append(g)
            seen.add(g)
    return out


def read_matrix_auto(path: str) -> pd.DataFrame:
    """
    Robust reader for CSV/TSV/TXT. Uses pandas sep=None auto-detection first.
    """
    p = Path(path)
    if not p.exists():
        raise FileNotFoundError(f"Data file not found: {path}")
    try:
        df = pd.read_csv(p, sep=None, engine="python")
        if df.shape[1] == 1:
            df = pd.read_csv(p, sep="\t")
    except Exception:
        df = pd.read_csv(p, sep="\t")
    return df


def infer_label_col(df: pd.DataFrame) -> Optional[str]:
    candidates = ["label", "Label", "group", "Group", "phenotype", "Phenotype", "class", "Class", "y", "Y"]
    for c in candidates:
        if c in df.columns:
            return c
    return None

def detect_gene_by_sample_and_transpose(df: pd.DataFrame, gene_list: List[str]) -> pd.DataFrame:
    """
    Detect if the matrix is gene-by-sample (genes as rows) and transpose to sample-by-gene.
    
    Heuristic: If first column is 'ID' and gene names appear as row indices, transpose.
    """
    # Check if first column is 'ID' (gene IDs)
    if df.shape[0] > 0 and 'ID' in df.columns:
        # Gene-by-sample: first column is gene ID, remaining columns are samples
        df_t = df.set_index('ID').T
        df_t.index.name = 'sample'
        print(f"[INFO] Detected gene-by-sample matrix. Transposed to sample-by-gene ({df_t.shape[0]} samples x {df_t.shape[1]} genes)")
        return df_t
    
    # Check if any of the genes in gene_list appear as row values
    if df.shape[0] > 0:
        first_col = df.columns[0]
        first_col_vals = df[first_col].astype(str).head(20).tolist()
        gene_set = set(gene_list)
        if any(g in gene_set for g in first_col_vals) or len(df) <= 50:
            # Likely gene-by-sample: transpose
            df_t = df.set_index(first_col).T
            df_t.index.name = 'sample'
            print(f"[INFO] Detected gene-by-sample matrix (heuristic). Transposed to sample-by-gene ({df_t.shape[0]} samples x {df_t.shape[1]} genes)")
            return df_t
    
    return df


def infer_labels_from_sample_names(sample_names: List[str]) -> np.ndarray:
    """
    Infer binary labels from sample names.
    
    Pattern: *_control -> 0, *_treat -> 1
    """
    mapping = {
        'control': 0, 'ctrl': 0, 'ctl': 0, 'hc': 0, 'healthy': 0, 'normal': 0,
        'treat': 1, 'tre': 1, 'uc': 1, 'case': 1, 'patient': 1, 'disease': 1
    }
    
    labels = []
    for name in sample_names:
        name_lower = name.lower()
        found = False
        for suffix, label in mapping.items():
            if name_lower.endswith(f'_{suffix}'):
                labels.append(label)
                found = True
                break
        if not found:
            if 'control' in name_lower or 'ctl' in name_lower or '_c_' in name_lower:
                labels.append(0)
            elif 'treat' in name_lower or 'tre' in name_lower or '_t_' in name_lower:
                labels.append(1)
            else:
                raise ValueError(f"Cannot infer label from sample name: {name}")
    
    return np.array(labels, dtype=int)


def force_numeric_dataframe(df: pd.DataFrame, gene_columns: list, nan_threshold: float = 0.01) -> pd.DataFrame:
    """
    Force gene columns to numeric, handling string formats like '[7.889273E-1]'.
    """
    import re
    df = df.copy()
    total_cells = len(df) * len(gene_columns)
    total_nan = 0
    
    def clean_value(v):
        if pd.isna(v):
            return np.nan
        if isinstance(v, (int, float)):
            return float(v)
        s = str(v).strip()
        s = re.sub(r'\[|\]', '', s)
        s = s.replace('E-', 'e-').replace('E+', 'e+')
        try:
            return float(s)
        except:
            return np.nan

    for col in gene_columns:
        if col not in df.columns:
            continue
        
        # Apply strict cleaning and convert to float64
        df[col] = df[col].apply(clean_value).astype(float)
        total_nan += df[col].isna().sum()
    
    nan_proportion = total_nan / total_cells if total_cells > 0 else 0
    
    if nan_proportion > nan_threshold:
        for col in gene_columns:
            if col in df.columns and df[col].isna().any():
                median_val = df[col].median()
                if pd.isna(median_val):
                    median_val = 0.0
                df[col] = df[col].fillna(median_val)
        print(f"[WARN] NaN proportion {nan_proportion:.2%} > {nan_threshold:.2%}, filled with median")
    
    return df



def ensure_binary_labels(y: pd.Series) -> np.ndarray:
    """
    Ensure labels are binary 0/1. Accepts {0,1}, {Control,UC}, {HC,UC}, etc.
    """
    if y.dtype.kind in "biu":
        vals = set(pd.unique(y))
        if vals.issubset({0, 1}):
            return y.astype(int).to_numpy()

    ys = y.astype(str).str.strip()
    mapping = {
        "0": 0, "1": 1,
        "control": 0, "hc": 0, "healthy": 0, "normal": 0,
        "uc": 1, "case": 1, "patient": 1, "disease": 1
    }
    mapped = []
    for v in ys:
        key = v.lower()
        if key in mapping:
            mapped.append(mapping[key])
        else:
            raise ValueError(f"Unrecognized label value '{v}'. Please provide binary 0/1 label column.")
    return np.array(mapped, dtype=int)


def get_proba(clf, X: np.ndarray) -> np.ndarray:
    """Get positive-class probability."""
    if hasattr(clf, "predict_proba"):
        return clf.predict_proba(X)[:, 1]
    if hasattr(clf, "decision_function"):
        s = clf.decision_function(X)
        return 1.0 / (1.0 + np.exp(-s))
    raise AttributeError("Model has neither predict_proba nor decision_function")


def compute_specificity(y_true: np.ndarray, y_pred: np.ndarray) -> float:
    tn, fp, fn, tp = confusion_matrix(y_true, y_pred).ravel()
    return tn / (tn + fp + 1e-12)


def youden_threshold(y_true: np.ndarray, y_prob: np.ndarray) -> Tuple[float, float]:
    fpr, tpr, thr = roc_curve(y_true, y_prob)
    j = tpr - fpr
    idx = int(np.argmax(j))
    return float(thr[idx]), float(j[idx])


def bootstrap_ci_auc(y_true: np.ndarray, y_prob: np.ndarray, n_boot: int = 1000, seed: int = 42) -> Tuple[float, float]:
    rng = np.random.default_rng(seed)
    n = len(y_true)
    scores = []
    for _ in range(n_boot):
        idx = rng.integers(0, n, n)
        if len(np.unique(y_true[idx])) < 2:
            continue
        scores.append(roc_auc_score(y_true[idx], y_prob[idx]))
    if not scores:
        return (np.nan, np.nan)
    return (float(np.percentile(scores, 2.5)), float(np.percentile(scores, 97.5)))


class TorchMLPClassifier(ClassifierMixin, BaseEstimator):
    _estimator_type = "classifier"
    def __init__(
        self,
        hidden_dims: Tuple[int, ...] = (64, 32),
        dropout: float = 0.2,
        lr: float = 1e-3,
        weight_decay: float = 1e-5,
        batch_size: int = 32,
        max_epochs: int = 300,
        patience: int = 30,
        val_split: float = 0.15,
        seed: int = 42,
        verbose: bool = False,
        device: str = "auto",
    ):
        self.hidden_dims = hidden_dims
        self.dropout = dropout
        self.lr = lr
        self.weight_decay = weight_decay
        self.batch_size = batch_size
        self.max_epochs = max_epochs
        self.patience = patience
        self.val_split = val_split
        self.seed = seed
        self.verbose = verbose
        self.device = device

    def _resolve_device(self) -> str:
        if self.device != "auto":
            return self.device
        if torch is not None and torch.cuda.is_available():
            return "cuda"
        return "cpu"

    def _build_model(self, n_features: int) -> object:
        layers: List[object] = []
        in_dim = n_features
        for h in self.hidden_dims:
            layers.append(nn.Linear(in_dim, int(h)))
            layers.append(nn.ReLU())
            layers.append(nn.Dropout(float(self.dropout)))
            in_dim = int(h)
        layers.append(nn.Linear(in_dim, 1))
        return nn.Sequential(*layers)

    def fit(self, X: np.ndarray, y: np.ndarray):
        if torch is None or nn is None:
            raise ImportError("PyTorch is required for TorchMLPClassifier.")

        X = np.asarray(X, dtype=np.float32)
        y = np.asarray(y, dtype=np.float32)
        if X.ndim != 2:
            raise ValueError("X must be a 2D array")

        set_all_seeds(int(self.seed))
        device = self._resolve_device()
        self.classes_ = np.array([0, 1], dtype=int)

        if self.val_split > 0 and len(np.unique(y)) == 2:
            Xtr, Xval, ytr, yval = train_test_split(
                X,
                y,
                test_size=float(self.val_split),
                stratify=y.astype(int),
                random_state=int(self.seed),
            )
        else:
            Xtr, ytr = X, y
            Xval = np.empty((0, X.shape[1]), dtype=np.float32)
            yval = np.empty((0,), dtype=np.float32)

        train_ds = TensorDataset(torch.from_numpy(Xtr), torch.from_numpy(ytr))
        train_loader = DataLoader(train_ds, batch_size=int(self.batch_size), shuffle=True)

        self.model_ = self._build_model(X.shape[1]).to(device)
        criterion = nn.BCEWithLogitsLoss()
        optimizer = torch.optim.Adam(
            self.model_.parameters(),
            lr=float(self.lr),
            weight_decay=float(self.weight_decay),
        )

        history = {"epoch": [], "train_loss": [], "val_loss": [], "val_auc": []}
        best_state = None
        best_auc = -np.inf
        stale_epochs = 0

        for epoch in range(1, int(self.max_epochs) + 1):
            self.model_.train()
            train_losses: List[float] = []
            for xb, yb in train_loader:
                xb = xb.to(device)
                yb = yb.to(device).unsqueeze(1)
                optimizer.zero_grad()
                logits = self.model_(xb)
                loss = criterion(logits, yb)
                loss.backward()
                optimizer.step()
                train_losses.append(float(loss.detach().cpu().item()))

            mean_train_loss = float(np.mean(train_losses)) if train_losses else np.nan

            self.model_.eval()
            val_loss = np.nan
            val_auc = np.nan
            if Xval.shape[0] > 0:
                with torch.no_grad():
                    xv = torch.from_numpy(Xval).to(device)
                    yv = torch.from_numpy(yval).to(device).unsqueeze(1)
                    logits = self.model_(xv)
                    val_loss = float(criterion(logits, yv).detach().cpu().item())
                    probs = torch.sigmoid(logits).detach().cpu().numpy().ravel()
                if len(np.unique(yval.astype(int))) == 2:
                    val_auc = float(roc_auc_score(yval.astype(int), probs))

            history["epoch"].append(epoch)
            history["train_loss"].append(mean_train_loss)
            history["val_loss"].append(val_loss)
            history["val_auc"].append(val_auc)

            score = val_auc if np.isfinite(val_auc) else -val_loss
            if np.isfinite(score) and score > best_auc:
                best_auc = score
                stale_epochs = 0
                best_state = {k: v.detach().cpu().clone() for k, v in self.model_.state_dict().items()}
            else:
                stale_epochs += 1

            if self.verbose and epoch % 20 == 0:
                print(f"[TorchMLP] epoch={epoch} train_loss={mean_train_loss:.4f} val_auc={val_auc}")

            if stale_epochs >= int(self.patience):
                break

        if best_state is not None:
            self.model_.load_state_dict(best_state)

        self.history_ = history
        self.device_ = device
        self.n_features_in_ = X.shape[1]
        return self

    def predict_proba(self, X: np.ndarray) -> np.ndarray:
        if not hasattr(self, "model_"):
            raise RuntimeError("Model is not fitted.")
        X = np.asarray(X, dtype=np.float32)
        self.model_.eval()
        with torch.no_grad():
            xt = torch.from_numpy(X).to(self.device_)
            logits = self.model_(xt)
            p1 = torch.sigmoid(logits).detach().cpu().numpy().ravel()
        p0 = 1.0 - p1
        return np.vstack([p0, p1]).T

    def predict(self, X: np.ndarray) -> np.ndarray:
        p1 = self.predict_proba(X)[:, 1]
        return (p1 >= 0.5).astype(int)


@dataclass
class ModelSpec:
    name: str
    estimator: object
    search_space: Optional[dict] = None


def build_model_specs(seed: int) -> List[ModelSpec]:
    if BayesSearchCV is None:
        print("[WARN] scikit-optimize (skopt) is not available. Bayesian optimization will fail unless installed.")
    if Real is None:
        # allow script to import; BO will raise later
        pass

    specs: List[ModelSpec] = []

    specs.append(ModelSpec(
        name="Bayes-RF",
        estimator=RandomForestClassifier(random_state=seed, n_jobs=-1),
        search_space={
            "n_estimators": Integer(200, 2000),
            "max_depth": Integer(2, 30),
            "min_samples_split": Integer(2, 10),
            "min_samples_leaf": Integer(1, 10),
            "max_features": Categorical(["sqrt", "log2", None]),
        }
    ))

    specs.append(ModelSpec(
        name="Bayes-SVM",
        estimator=SVC(probability=True, random_state=seed),
        search_space={
            "C": Real(1e-3, 1e3, prior="log-uniform"),
            "gamma": Real(1e-4, 1e1, prior="log-uniform"),
            "kernel": Categorical(["rbf"]),
        }
    ))

    specs.append(ModelSpec(
        name="Bayes-KNN",
        estimator=KNeighborsClassifier(),
        search_space={
            "n_neighbors": Integer(1, 50),
            "weights": Categorical(["uniform", "distance"]),
            "p": Integer(1, 2),
        }
    ))

    specs.append(ModelSpec(
        name="Bayes-DNN",
        estimator=TorchMLPClassifier(seed=seed),
        search_space={
            "dropout": Real(0.05, 0.5),
            "lr": Real(1e-4, 1e-2, prior="log-uniform"),
            "weight_decay": Real(1e-6, 1e-2, prior="log-uniform"),
            "batch_size": Integer(16, 64),
            "patience": Integer(15, 40),
        }
    ))

    if XGBClassifier is not None:
        specs.append(ModelSpec(
            name="Bayes-XGBoost",
            estimator=XGBClassifier(
                random_state=seed,
                n_jobs=-1,
                eval_metric="logloss",
                tree_method="hist"
            ),
            search_space={
                "n_estimators": Integer(200, 3000),
                "max_depth": Integer(2, 10),
                "learning_rate": Real(1e-3, 0.3, prior="log-uniform"),
                "subsample": Real(0.5, 1.0),
                "colsample_bytree": Real(0.5, 1.0),
                "min_child_weight": Integer(1, 10),
                "reg_lambda": Real(1e-3, 10.0, prior="log-uniform"),
            }
        ))
    else:
        print("[WARN] xgboost not available; skipping Bayes-XGBoost")

    if LGBMClassifier is not None:
        specs.append(ModelSpec(
            name="Bayes-LightGBM",
            estimator=LGBMClassifier(random_state=seed, n_jobs=-1, verbose=-1),
            search_space={
                "n_estimators": Integer(200, 5000),
                "num_leaves": Integer(16, 256),
                "max_depth": Integer(-1, 15),
                "learning_rate": Real(1e-3, 0.3, prior="log-uniform"),
                "subsample": Real(0.5, 1.0),
                "colsample_bytree": Real(0.5, 1.0),
                "min_child_samples": Integer(5, 50),
                "reg_lambda": Real(1e-3, 10.0, prior="log-uniform"),
            }
        ))
    else:
        print("[WARN] lightgbm not available; skipping Bayes-LightGBM")

    if CatBoostClassifier is not None:
        specs.append(ModelSpec(
            name="Bayes-CatBoost",
            estimator=CatBoostClassifier(
                random_seed=seed,
                verbose=False,
                loss_function="Logloss"
            ),
            search_space={
                "iterations": Integer(200, 5000),
                "depth": Integer(4, 10),
                "learning_rate": Real(1e-3, 0.3, prior="log-uniform"),
                "l2_leaf_reg": Real(1.0, 10.0, prior="log-uniform"),
                "border_count": Integer(32, 255),
            }
        ))
    else:
        print("[WARN] catboost not available; skipping Bayes-CatBoost")

    # GPR (note: O(n^3))
    kernel = C(1.0, (1e-3, 1e3)) * RBF(length_scale=1.0, length_scale_bounds=(1e-3, 1e3))
    specs.append(ModelSpec(
        name="Bayes-GPR",
        estimator=GaussianProcessClassifier(kernel=kernel, random_state=seed, max_iter_predict=100),
        search_space={
            "max_iter_predict": Integer(50, 300),
        }
    ))

    return specs


def maybe_build_imputer(df: pd.DataFrame, genes: List[str], seed: int) -> Optional[object]:
    if df[genes].isna().sum().sum() == 0:
        return None

    if LGBMRegressor is not None:
        est = LGBMRegressor(random_state=seed, n_jobs=-1)
    else:
        from sklearn.ensemble import ExtraTreesRegressor
        est = ExtraTreesRegressor(random_state=seed, n_jobs=-1)

    return IterativeImputer(
        estimator=est,
        random_state=seed,
        max_iter=10,
        initial_strategy="median"
    )


def bayes_optimize(spec: ModelSpec, X_train: np.ndarray, y_train: np.ndarray, n_iter: int,
                  cv: StratifiedKFold, outdir: Path, seed: int) -> Tuple[object, Dict]:
    if BayesSearchCV is None:
        raise ImportError("skopt is required (pip install scikit-optimize).")

    # GPR safety
    if spec.name == "Bayes-GPR" and X_train.shape[0] > 2000:
        est = spec.estimator
        est.fit(X_train, y_train)
        summary = {"skipped_bo": True, "reason": "n_samples too large for GPR", "best_params": {}, "best_cv_auc": np.nan}
        return est, summary

    search = BayesSearchCV(
        estimator=spec.estimator,
        search_spaces=spec.search_space,
        n_iter=n_iter,
        scoring="roc_auc",
        cv=cv,
        n_jobs=-1,
        random_state=seed,
        refit=True,
        return_train_score=False
    )
    search.fit(X_train, y_train)

    cvres = search.cv_results_
    mean_scores = cvres.get("mean_test_score", [])
    std_scores = cvres.get("std_test_score", [])
    params_list = cvres.get("params", [])

    log_df = pd.DataFrame({
        "iteration": np.arange(1, len(mean_scores) + 1),
        "mean_cv_auc": mean_scores,
        "std_cv_auc": std_scores,
        "params_json": [json.dumps(p, ensure_ascii=False, default=str) for p in params_list],
    })
    bo_log_path = outdir / "bo_logs" / f"{spec.name}_bo_history.csv"
    bo_log_path.parent.mkdir(parents=True, exist_ok=True)
    log_df.to_csv(bo_log_path, index=False)

    # Convergence plot
    fig_path = outdir / "figures" / f"bo_convergence_{spec.name}.png"
    fig_path.parent.mkdir(parents=True, exist_ok=True)
    plt.figure(figsize=(5.2, 3.6))
    plt.plot(log_df["iteration"], log_df["mean_cv_auc"], linewidth=1.8)
    plt.xlabel("Iteration")
    plt.ylabel("Mean CV ROC-AUC")
    plt.title(f"{spec.name} BO convergence")
    plt.tight_layout()
    plt.savefig(fig_path, dpi=300)
    plt.close()
    try:
        plt.figure(figsize=(5.2, 3.6))
        plt.plot(log_df["iteration"], log_df["mean_cv_auc"], linewidth=1.8)
        plt.xlabel("Iteration")
        plt.ylabel("Mean CV ROC-AUC")
        plt.title(f"{spec.name} BO convergence")
        plt.tight_layout()
        plt.savefig(fig_path.with_suffix(".pdf"))
        plt.close()
    except Exception:
        pass

    summary = {
        "skipped_bo": False,
        "best_params": search.best_params_,
        "best_cv_auc": float(search.best_score_),
        "bo_history_csv": str(bo_log_path),
        "bo_convergence_png": str(fig_path),
    }
    return search.best_estimator_, summary


def eval_binary(y_true: np.ndarray, y_prob: np.ndarray, threshold: float = 0.5) -> Dict:
    y_pred = (y_prob >= threshold).astype(int)
    tn, fp, fn, tp = confusion_matrix(y_true, y_pred).ravel()
    out = {
        "roc_auc": float(roc_auc_score(y_true, y_prob)),
        "pr_auc": float(average_precision_score(y_true, y_prob)),
        "accuracy": float(accuracy_score(y_true, y_pred)),
        "precision": float(precision_score(y_true, y_pred, zero_division=0)),
        "recall_sensitivity": float(recall_score(y_true, y_pred, zero_division=0)),
        "specificity": float(tn / (tn + fp + 1e-12)),
        "f1": float(f1_score(y_true, y_pred, zero_division=0)),
        "brier": float(brier_score_loss(y_true, y_prob)),
        "confusion_matrix": [[int(tn), int(fp)], [int(fn), int(tp)]],
        "threshold": float(threshold),
    }
    return out


def youden_threshold(y_true: np.ndarray, y_prob: np.ndarray) -> Tuple[float, float]:
    fpr, tpr, thr = roc_curve(y_true, y_prob)
    j = tpr - fpr
    idx = int(np.argmax(j))
    return float(thr[idx]), float(j[idx])


def bootstrap_ci_auc(y_true: np.ndarray, y_prob: np.ndarray, n_boot: int = 1000, seed: int = 42) -> Tuple[float, float]:
    rng = np.random.default_rng(seed)
    n = len(y_true)
    scores = []
    for _ in range(n_boot):
        idx = rng.integers(0, n, n)
        if len(np.unique(y_true[idx])) < 2:
            continue
        scores.append(roc_auc_score(y_true[idx], y_prob[idx]))
    if not scores:
        return (np.nan, np.nan)
    return (float(np.percentile(scores, 2.5)), float(np.percentile(scores, 97.5)))


def plot_calibration(y_true: np.ndarray, y_prob: np.ndarray, outpath: Path) -> None:
    prob_true, prob_pred = calibration_curve(y_true, y_prob, n_bins=10, strategy="uniform")
    plt.figure(figsize=(4.6, 4.0))
    plt.plot(prob_pred, prob_true, marker="o", linewidth=1.6)
    plt.plot([0, 1], [0, 1], linestyle="--", linewidth=1.2)
    plt.xlabel("Predicted probability")
    plt.ylabel("Observed frequency")
    plt.title("Calibration curve")
    plt.tight_layout()
    plt.savefig(outpath, dpi=300)
    plt.close()
    try:
        plt.figure(figsize=(4.6, 4.0))
        plt.plot(prob_pred, prob_true, marker="o", linewidth=1.6)
        plt.plot([0, 1], [0, 1], linestyle="--", linewidth=1.2)
        plt.xlabel("Predicted probability")
        plt.ylabel("Observed frequency")
        plt.title("Calibration curve")
        plt.tight_layout()
        plt.savefig(outpath.with_suffix(".pdf"))
        plt.close()
    except Exception:
        pass


def plot_confusion(cm: np.ndarray, outpath: Path) -> None:
    plt.figure(figsize=(4.0, 3.6))
    plt.imshow(cm, interpolation="nearest")
    plt.title("Confusion matrix")
    plt.colorbar(fraction=0.046, pad=0.04)
    tick_marks = np.arange(2)
    plt.xticks(tick_marks, ["Control(0)", "UC(1)"], rotation=0)
    plt.yticks(tick_marks, ["Control(0)", "UC(1)"])
    thresh = cm.max() / 2.0
    for i in range(2):
        for j in range(2):
            plt.text(j, i, format(int(cm[i, j]), "d"),
                     horizontalalignment="center",
                     color="white" if cm[i, j] > thresh else "black")
    plt.ylabel("True label")
    plt.xlabel("Predicted label")
    plt.tight_layout()
    plt.savefig(outpath, dpi=300)
    plt.close()
    try:
        plt.figure(figsize=(4.0, 3.6))
        plt.imshow(cm, interpolation="nearest")
        plt.title("Confusion matrix")
        plt.colorbar(fraction=0.046, pad=0.04)
        tick_marks = np.arange(2)
        plt.xticks(tick_marks, ["Control(0)", "UC(1)"], rotation=0)
        plt.yticks(tick_marks, ["Control(0)", "UC(1)"])
        thresh = cm.max() / 2.0
        for i in range(2):
            for j in range(2):
                plt.text(j, i, format(int(cm[i, j]), "d"),
                         horizontalalignment="center",
                         color="white" if cm[i, j] > thresh else "black")
        plt.ylabel("True label")
        plt.xlabel("Predicted label")
        plt.tight_layout()
        plt.savefig(outpath.with_suffix(".pdf"))
        plt.close()
    except Exception:
        pass


def plot_dnn_training_curve(model, outpath: Path, title: str = "Bayes-DNN training curve") -> None:
    if not hasattr(model, "history_"):
        return
    hist = getattr(model, "history_", {})
    epochs = hist.get("epoch", [])
    train_loss = hist.get("train_loss", [])
    val_loss = hist.get("val_loss", [])
    val_auc = hist.get("val_auc", [])
    if len(epochs) == 0:
        return

    fig, ax1 = plt.subplots(figsize=(6.2, 4.0))
    ax1.plot(epochs, train_loss, label="train_loss", linewidth=1.6)
    if len(val_loss) == len(epochs):
        ax1.plot(epochs, val_loss, label="val_loss", linewidth=1.6)
    ax1.set_xlabel("Epoch")
    ax1.set_ylabel("Loss")
    ax1.grid(False)

    ax2 = ax1.twinx()
    if len(val_auc) == len(epochs):
        ax2.plot(epochs, val_auc, label="val_auc", color="tab:green", linewidth=1.6)
    ax2.set_ylabel("Validation AUC")

    lines1, labels1 = ax1.get_legend_handles_labels()
    lines2, labels2 = ax2.get_legend_handles_labels()
    ax1.legend(lines1 + lines2, labels1 + labels2, loc="best", fontsize=8, frameon=True)
    plt.title(title)
    plt.tight_layout()
    outpath.parent.mkdir(parents=True, exist_ok=True)
    plt.savefig(outpath, dpi=300)
    plt.close(fig)
    try:
        fig, ax1 = plt.subplots(figsize=(6.2, 4.0))
        ax1.plot(epochs, train_loss, label="train_loss", linewidth=1.6)
        if len(val_loss) == len(epochs):
            ax1.plot(epochs, val_loss, label="val_loss", linewidth=1.6)
        ax1.set_xlabel("Epoch")
        ax1.set_ylabel("Loss")
        ax2 = ax1.twinx()
        if len(val_auc) == len(epochs):
            ax2.plot(epochs, val_auc, label="val_auc", color="tab:green", linewidth=1.6)
        ax2.set_ylabel("Validation AUC")
        lines1, labels1 = ax1.get_legend_handles_labels()
        lines2, labels2 = ax2.get_legend_handles_labels()
        ax1.legend(lines1 + lines2, labels1 + labels2, loc="best", fontsize=8, frameon=True)
        plt.title(title)
        plt.tight_layout()
        plt.savefig(outpath.with_suffix(".pdf"))
        plt.close(fig)
    except Exception:
        pass


def style_axes(ax):
    ax.set_facecolor("white")
    for spine in ax.spines.values():
        spine.set_color("black")
        spine.set_linewidth(1.0)
    ax.tick_params(axis="both", colors="black", labelsize=8)
    ax.grid(False)



# Fixed color map for model names (matching ROC curves with AUC strip)
MODEL_COLORS = {
    'Bayes-RF': '#1f77b4',
    'Bayes-LightGBM': '#ff7f0e',
    'Bayes-KNN': '#2ca02c',
    'Bayes-CatBoost': '#d62728',
    'Bayes-XGBoost': '#9467bd',
    'Bayes-SVM': '#8c564b',
    'Bayes-DNN': '#e377c2',
    'Bayes-GPR': '#7f7f7f',
}

def draw_auc_strip(ax_parent, auc_dict: Dict[str, float], model_colors: Dict[str, str] = None):
    if model_colors is None:
        model_colors = MODEL_COLORS
    items = sorted(auc_dict.items(), key=lambda x: x[1], reverse=True)
    n = len(items)
    ax_strip = inset_axes(
        ax_parent,
        width="40%",
        height="100%",
        loc="lower left",
        bbox_to_anchor=(1.02, 0.0, 0.4, 1.0),
        bbox_transform=ax_parent.transAxes,
        borderpad=0
    )
    ax_strip.set_xlim(0, 1)
    ax_strip.set_ylim(0, n)
    ax_strip.axis("off")

    for i, (model_name, aucv) in enumerate(items):
        y0 = n - i - 1
        # Use fixed color for this model
        color = model_colors.get(model_name, '#333333')
        rect = patches.Rectangle((0.0, y0), 1.0, 1.0, facecolor=color, edgecolor="white", linewidth=0.8)
        ax_strip.add_patch(rect)
        ax_strip.text(0.5, y0 + 0.5, f"{aucv:.3f}", ha="center", va="center", fontsize=8, color="white")
    return ax_strip


def plot_roc(ax, y_true, y_prob, label: str, lw: float = 1.6):
    fpr, tpr, _ = roc_curve(y_true, y_prob)
    ax.plot(fpr, tpr, linewidth=lw, label=label)



   
def plot_roc_univariate_per_gene(
    X_train_df: pd.DataFrame,
    y_train: np.ndarray,
    X_test_df: pd.DataFrame,
    y_test: np.ndarray,
    genes: List[str],
    tuned_models: Dict[str, object],
    outdir: Path
) -> None:
    """
    Plot ROC curves for each gene separately.
    - One PDF per gene (8 genes = 8 files)
    - Uses MODEL_COLORS for both curves and AUC strip
    - No panel labels (A/B/C...)
    - Filename: ROC_univariate_<gene>.pdf
    """
    outdir.mkdir(parents=True, exist_ok=True)
    model_names = list(tuned_models.keys())
    
    for gene in genes[:8]:
        fig, ax = plt.subplots(figsize=(5.0, 4.5))
        ax.plot([0, 1], [0, 1], linestyle='--', linewidth=1.0, color='black')
        
        aucs = {}
        for mname in model_names:
            base_model = tuned_models[mname]
            try:
                from sklearn.base import clone
                model = clone(base_model)
            except Exception:
                model = base_model
            
            Xtr = X_train_df[[gene]].to_numpy()
            Xte = X_test_df[[gene]].to_numpy()
            
            if mname == 'Bayes-GPR' and Xtr.shape[0] > 2000:
                continue
            
            try:
                model.fit(Xtr, y_train)
                prob = get_proba(model, Xte)
                aucv = roc_auc_score(y_test, prob)
                aucs[mname] = float(aucv)
                
                # Use MODEL_COLORS for curve
                color = MODEL_COLORS.get(mname, '#333333')
                fpr, tpr, _ = roc_curve(y_test, prob)
                ax.plot(fpr, tpr, linewidth=1.6, label=mname.replace('Bayes-', ''), color=color)
            except Exception as e:
                print(f'[WARN] Univariate fit failed for {mname} on {gene}: {e}')
        
        ax.set_title(gene, fontsize=12)
        ax.set_xlabel('False Positive Rate', fontsize=10)
        ax.set_ylabel('True Positive Rate', fontsize=10)
        style_axes(ax)
        ax.legend(loc='lower right', fontsize=7, frameon=True, framealpha=0.9)
        
        # AUC strip with MODEL_COLORS
        if aucs:
            draw_auc_strip(ax, aucs, model_colors=MODEL_COLORS)
        
        fig.tight_layout()
        
        # Save with gene-specific filename
        outpath = outdir / f'ROC_univariate_{gene}.pdf'
        fig.savefig(outpath, bbox_inches='tight')
        
        # Also save PNG
        try:
            fig.savefig(outpath.with_suffix('.png'), dpi=300, bbox_inches='tight')
        except Exception:
            pass
        
        plt.close(fig)
        print(f'[INFO] Saved ROC plot: {outpath}')


def plot_multigene_roc(y_test: np.ndarray, proba_dict: Dict[str, np.ndarray], outpath: Path) -> None:
    plt.figure(figsize=(6.0, 5.0))
    ax = plt.gca()
    ax.plot([0, 1], [0, 1], linestyle="--", linewidth=1.0, color="black")
    for name, prob in proba_dict.items():
        aucv = roc_auc_score(y_test, prob)
        plot_roc(ax, y_test, prob, label=f"{name} (AUC={aucv:.3f})")
    ax.set_xlabel("False Positive Rate")
    ax.set_ylabel("True Positive Rate")
    ax.set_title("ROC curves (8-gene model)")
    style_axes(ax)
    ax.legend(loc="lower right", fontsize=8, frameon=True)
    plt.tight_layout()
    outpath.parent.mkdir(parents=True, exist_ok=True)
    plt.savefig(outpath, dpi=300)
    plt.close()
    try:
        plt.figure(figsize=(6.0, 5.0))
        ax = plt.gca()
        ax.plot([0, 1], [0, 1], linestyle="--", linewidth=1.0, color="black")
        for name, prob in proba_dict.items():
            aucv = roc_auc_score(y_test, prob)
            plot_roc(ax, y_test, prob, label=f"{name} (AUC={aucv:.3f})")
        ax.set_xlabel("False Positive Rate")
        ax.set_ylabel("True Positive Rate")
        ax.set_title("ROC curves (8-gene model)")
        style_axes(ax)
        ax.legend(loc="lower right", fontsize=8, frameon=True)
        plt.tight_layout()
        plt.savefig(outpath.with_suffix(".pdf"))
        plt.close()
    except Exception:
        pass


def plot_multigene_pr(y_test: np.ndarray, proba_dict: Dict[str, np.ndarray], outpath: Path) -> None:
    plt.figure(figsize=(6.0, 5.0))
    ax = plt.gca()
    for name, prob in proba_dict.items():
        ap = average_precision_score(y_test, prob)
        prec, rec, _ = precision_recall_curve(y_test, prob)
        ax.plot(rec, prec, linewidth=1.6, label=f"{name} (AP={ap:.3f})")
    ax.set_xlabel("Recall")
    ax.set_ylabel("Precision")
    ax.set_title("PR curves (8-gene model)")
    style_axes(ax)
    ax.legend(loc="lower left", fontsize=8, frameon=True)
    plt.tight_layout()
    outpath.parent.mkdir(parents=True, exist_ok=True)
    plt.savefig(outpath, dpi=300)
    plt.close()
    try:
        plt.figure(figsize=(6.0, 5.0))
        ax = plt.gca()
        for name, prob in proba_dict.items():
            ap = average_precision_score(y_test, prob)
            prec, rec, _ = precision_recall_curve(y_test, prob)
            ax.plot(rec, prec, linewidth=1.6, label=f"{name} (AP={ap:.3f})")
        ax.set_xlabel("Recall")
        ax.set_ylabel("Precision")
        ax.set_title("PR curves (8-gene model)")
        style_axes(ax)
        ax.legend(loc="lower left", fontsize=8, frameon=True)
        plt.tight_layout()
        plt.savefig(outpath.with_suffix(".pdf"))
        plt.close()
    except Exception:
        pass


def run_explainability(best_name: str, best_model, X_train: pd.DataFrame, X_test: pd.DataFrame,
                       y_test: np.ndarray, outdir: Path, seed: int) -> None:
    figdir = outdir / "figures"
    figdir.mkdir(parents=True, exist_ok=True)
    (outdir / "bo_logs").mkdir(parents=True, exist_ok=True)

    # Permutation importance (ROC-AUC scoring)
    try:
        r = permutation_importance(best_model, X_test, y_test, n_repeats=20, random_state=seed, scoring="roc_auc")
        imp = pd.DataFrame({"feature": X_test.columns, "importance_mean": r.importances_mean, "importance_std": r.importances_std})
        imp = imp.sort_values("importance_mean", ascending=False)
        imp.to_csv(outdir / "bo_logs" / f"{best_name}_permutation_importance.csv", index=False)

        plt.figure(figsize=(5.2, 3.6))
        plt.barh(imp["feature"][::-1], imp["importance_mean"][::-1])
        plt.xlabel("Permutation importance (mean)")
        plt.title(f"{best_name} permutation importance")
        plt.tight_layout()
        plt.savefig(figdir / f"importance_{best_name}.png", dpi=300)
        plt.close()
        try:
            plt.figure(figsize=(5.2, 3.6))
            plt.barh(imp["feature"][::-1], imp["importance_mean"][::-1])
            plt.xlabel("Permutation importance (mean)")
            plt.title(f"{best_name} permutation importance")
            plt.tight_layout()
            plt.savefig(figdir / f"importance_{best_name}.pdf")
            plt.close()
        except Exception:
            pass
    except Exception as e:
        print(f"[WARN] permutation importance failed: {e}")
        imp = None

    # PDP for top 5
    try:
        top_feats = list(X_test.columns)
        if imp is not None:
            top_feats = imp["feature"].tolist()
        top_feats = top_feats[:5]
        for feat in top_feats:
            fig = plt.figure(figsize=(4.6, 3.8))
            ax = fig.add_subplot(111)
            PartialDependenceDisplay.from_estimator(best_model, X_train, [feat], ax=ax, kind="average")
            plt.title(f"PDP: {feat} ({best_name})")
            plt.tight_layout()
            plt.savefig(figdir / f"pdp_{best_name}_{feat}.png", dpi=300)
            plt.close(fig)
            try:
                fig = plt.figure(figsize=(4.6, 3.8))
                ax = fig.add_subplot(111)
                PartialDependenceDisplay.from_estimator(best_model, X_train, [feat], ax=ax, kind="average")
                plt.title(f"PDP: {feat} ({best_name})")
                plt.tight_layout()
                plt.savefig(figdir / f"pdp_{best_name}_{feat}.pdf")
                plt.close(fig)
            except Exception:
                pass
    except Exception as e:
        print(f"[WARN] PDP failed: {e}")

    def _to_float_ndarray(arr) -> np.ndarray:
        """Convert any array-like to float ndarray, handling special formats."""
        import re
        raw = np.asarray(arr)
        # Already numeric
        if raw.dtype.kind in "fiu":
            return raw.astype(float)
        # Try to handle object arrays with strings like '[7.889273E-1]'
        if raw.dtype.kind in "OSU":
            def _convert_item(v):
                s = str(v).strip()
                # Handle numpy arrays embedded in strings
                s = re.sub(r'\[|\]', '', s)
                # Handle scientific notation
                s = s.replace('E-', 'e-').replace('E+', 'e+')
                try:
                    return float(s)
                except:
                    return np.nan
            vec = np.vectorize(_convert_item, otypes=[np.float64])
            result = vec(raw)
            return result
        return raw.astype(float)



    # SHAP
    if shap is None:
        print("[WARN] shap not installed; skipping SHAP plots.")
        return
    
    is_tree = any(k in best_name.lower() for k in ["xgboost", "lightgbm", "catboost", "rf"])
    
    # Compute SHAP values first
    try:
        X_train_num = pd.DataFrame(_to_float_ndarray(X_train), columns=X_train.columns, index=X_train.index)
        X_test_num = pd.DataFrame(_to_float_ndarray(X_test), columns=X_test.columns, index=X_test.index)
        
        if is_tree:
            explainer = shap.TreeExplainer(best_model)
            shap_values = explainer.shap_values(X_test_num)
            X_for_plot = X_test_num
            # Handle CatBoost/XGBoost returning list for binary classification
            if isinstance(shap_values, list):
                shap_values = shap_values[1] if len(shap_values) > 1 else shap_values[0]
        else:
            # For non-tree models, skip SHAP (KernelExplainer is too slow)
            print(f"[INFO] Skipping SHAP for non-tree model {best_name}")
            return
        
        # Ensure shap_values is float
        shap_values = np.asarray(shap_values, dtype=float)
        if shap_values.ndim == 1:
            shap_values = shap_values.reshape(-1, 1)
    except Exception as e:
        print(f"[WARN] SHAP computation failed: {e}")
        return
    
    # ---- Fig_SHAP_like (blue→green winter cmap, white bg, black axes) ----
    try:
        from matplotlib.colors import Normalize
        fig_shap, ax_shap = plt.subplots(figsize=(7.0, 5.0))
        ax_shap.set_facecolor("white")
        fig_shap.patch.set_facecolor("white")
        for spine in ax_shap.spines.values():
            spine.set_color("black")
            spine.set_linewidth(1.0)
        ax_shap.tick_params(axis="both", colors="black")
        ax_shap.grid(False)

        mean_abs = np.abs(shap_values).mean(axis=0)
        order = np.argsort(mean_abs)
        feature_names = list(X_for_plot.columns)
        cmap = plt.cm.winter
        norm = Normalize(vmin=0, vmax=1)

        for pos, idx in enumerate(order):
            sv = shap_values[:, idx]
            fvals = X_for_plot.iloc[:, idx].values.astype(float)
            fmin, fmax = np.nanmin(fvals), np.nanmax(fvals)
            if fmax - fmin < 1e-12:
                normed = np.full_like(fvals, 0.5)
            else:
                normed = (fvals - fmin) / (fmax - fmin)
            colors = cmap(normed)
            jitter = np.random.default_rng(42).normal(0, 0.12, size=len(sv))
            ax_shap.scatter(sv, np.full_like(sv, pos) + jitter, c=colors, s=6, alpha=0.7, edgecolors="none")

        ax_shap.set_yticks(range(len(order)))
        ax_shap.set_yticklabels([feature_names[i] for i in order], fontsize=9)
        ax_shap.set_xlabel("SHAP value", fontsize=10)
        ax_shap.axvline(0, color="grey", linewidth=0.5, linestyle="--")

        sm = plt.cm.ScalarMappable(cmap=cmap, norm=norm)
        sm.set_array([])
        cbar = fig_shap.colorbar(sm, ax=ax_shap, fraction=0.04, pad=0.02)
        cbar.set_label("Feature value", fontsize=9)
        cbar.set_ticks([0, 1])
        cbar.set_ticklabels(["Low", "High"])

        fig_shap.tight_layout()
        fig_shap.savefig(figdir / "Fig_SHAP_like.png", dpi=300, bbox_inches="tight")
        fig_shap.savefig(figdir / "Fig_SHAP_like.pdf", bbox_inches="tight")
        plt.close(fig_shap)
        print("[INFO] Saved Fig_SHAP_like.png/pdf")
    except Exception as e:
        print(f"[WARN] Fig_SHAP_like failed: {e}")

    # ---- shap_beeswarm ----
    try:
        plt.figure(figsize=(6.4, 4.8))
        shap.summary_plot(shap_values, X_for_plot, show=False, cmap='winter')
        plt.tight_layout()
        plt.savefig(figdir / f"shap_beeswarm_{best_name}.png", dpi=300, bbox_inches="tight")
        plt.close()
        plt.figure(figsize=(6.4, 4.8))
        shap.summary_plot(shap_values, X_for_plot, show=False, cmap='winter')
        plt.tight_layout()
        plt.savefig(figdir / f"shap_beeswarm_{best_name}.pdf", bbox_inches="tight")
        plt.close()
        print(f"[INFO] Saved shap_beeswarm_{best_name}.png/pdf")
    except Exception as e:
        print(f"[WARN] shap_beeswarm failed: {e}")

    # ---- shap_bar ----
    try:
        plt.figure(figsize=(6.4, 4.0))
        shap.summary_plot(shap_values, X_for_plot, plot_type="bar", show=False)
        plt.tight_layout()
        plt.savefig(figdir / f"shap_bar_{best_name}.png", dpi=300, bbox_inches="tight")
        plt.close()
        plt.figure(figsize=(6.4, 4.0))
        shap.summary_plot(shap_values, X_for_plot, plot_type="bar", show=False)
        plt.tight_layout()
        plt.savefig(figdir / f"shap_bar_{best_name}.pdf", bbox_inches="tight")
        plt.close()
        print(f"[INFO] Saved shap_bar_{best_name}.png/pdf")
    except Exception as e:
        print(f"[WARN] shap_bar failed: {e}")

    # ---- shap_dependence for Top-5 features ----
    try:
        dep_feats = list(X_for_plot.columns)
        if imp is not None:
            dep_feats = imp["feature"].tolist()
        dep_feats = dep_feats[:5]
        for feat in dep_feats:
            fidx = list(X_for_plot.columns).index(feat)
            fig_dep, ax_dep = plt.subplots(figsize=(5.0, 4.0))
            shap.dependence_plot(fidx, shap_values, X_for_plot, ax=ax_dep, show=False)
            ax_dep.set_title(f"SHAP dependence: {feat}")
            fig_dep.tight_layout()
            fig_dep.savefig(figdir / f"shap_dependence_{feat}.png", dpi=300, bbox_inches="tight")
            fig_dep.savefig(figdir / f"shap_dependence_{feat}.pdf", bbox_inches="tight")
            plt.close(fig_dep)
        print(f"[INFO] Saved shap_dependence for {dep_feats}")
    except Exception as e:
        print(f"[WARN] shap_dependence failed: {e}")


def write_env(outdir: Path) -> None:
    import platform, subprocess, sys
    outdir.mkdir(parents=True, exist_ok=True)
    lines = [f"Python: {sys.version}", f"Platform: {platform.platform()}"]
    try:
        pip_freeze = subprocess.check_output([sys.executable, "-m", "pip", "freeze"], text=True)
        lines.append("\n# pip freeze\n")
        lines.append(pip_freeze)
    except Exception as e:
        lines.append(f"[WARN] pip freeze failed: {e}")
    (outdir / "env.txt").write_text("\n".join(lines), encoding="utf-8")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--data", type=str, default="merge.normalize.txt", help="Input matrix file (CSV/TSV/TXT).")
    parser.add_argument("--label_col", type=str, default=None, help="Label column name (binary 0/1). If omitted, auto-infer.")
    parser.add_argument("--gene_list_path", type=str, default="/mnt/data/output_mRNA_selected.txt", help="Gene list file path.")
    parser.add_argument("--outdir", type=str, default="outputs/run1", help="Output directory.")
    parser.add_argument("--n_iter", type=int, default=100, help="Bayesian optimization iterations per model.")
    parser.add_argument("--top_k", type=int, default=3, help="Top-K base learners for stacking.")
    parser.add_argument("--seed", type=int, default=42, help="Random seed.")
    parser.add_argument("--step", type=str, default="all", choices=["all", "train", "eval", "explain"], 
                        help="Execution step: all, train (models only), eval (ROC/metrics), explain (SHAP).")
    args = parser.parse_args()

    set_all_seeds(args.seed)

    outdir = Path(args.outdir)
    (outdir / "figures").mkdir(parents=True, exist_ok=True)
    (outdir / "bo_logs").mkdir(parents=True, exist_ok=True)
    (outdir / "models").mkdir(parents=True, exist_ok=True)
    
    checkpoint_path = outdir / "checkpoint.joblib"

    genes = read_gene_list(args.gene_list_path)
    if len(genes) == 0:
        raise ValueError(f"No genes found in {args.gene_list_path}")
    if len(genes) != 8:
        print(f"[WARN] Gene list contains {len(genes)} genes; expected 8. Using first 8.")
    genes = genes[:8]

    # Initialize variables that might be loaded from checkpoint
    X_train, X_test, y_train, y_test = None, None, None, None
    tuned_models, tuning_summaries = {}, {}
    proba_dict, metrics_all = {}, {}
    cv = StratifiedKFold(n_splits=5, shuffle=True, random_state=args.seed)

    if args.step in ["all", "train"]:
        df = read_matrix_auto(args.data)
        df = detect_gene_by_sample_and_transpose(df, genes)
        label_col = args.label_col or infer_label_col(df)
        if label_col is not None and label_col in df.columns:
            y = ensure_binary_labels(df[label_col])
            X = df[genes].copy()
            print(f"[INFO] Using label column '{label_col}' with {len(y)} samples")
        else:
            print("[INFO] No label column found. Inferring labels from sample names...")
            sample_names = list(df.index)
            y = infer_labels_from_sample_names(sample_names)
            X = df[genes].copy()
            n_control, n_treat = np.sum(y == 0), np.sum(y == 1)
            print(f"[INFO] Inferred labels: {n_control} control, {n_treat} treat")

        missing = [g for g in genes if g not in df.columns]
        if missing:
            raise ValueError(f"Missing gene columns: {missing}\nAvailable columns: {list(df.columns)}")

        X = force_numeric_dataframe(X, genes)
        imputer = maybe_build_imputer(df, genes, args.seed)
        if imputer is not None:
            X = pd.DataFrame(imputer.fit_transform(X), columns=genes, index=df.index)

        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=0.30, stratify=y, random_state=args.seed
        )

        specs = build_model_specs(args.seed)
        for spec in specs:
            print(f"[INFO] Tuning {spec.name} ...")
            try:
                best_est, summary = bayes_optimize(spec, X_train.to_numpy(), y_train, args.n_iter, cv, outdir, args.seed)
                tuned_models[spec.name] = best_est
                tuning_summaries[spec.name] = summary
                joblib.dump(best_est, outdir / "models" / f"{spec.name}.joblib")
                if spec.name == "Bayes-DNN":
                    plot_dnn_training_curve(best_est, outdir / "figures" / "training_curve_Bayes-DNN.png", title="Bayes-DNN (PyTorch) training")
                    if hasattr(best_est, "history_"):
                        pd.DataFrame(best_est.history_).to_csv(outdir / "bo_logs" / "Bayes-DNN_training_history.csv", index=False)
            except Exception as e:
                print(f"[WARN] {spec.name} BO failed ({e}); fallback to default fit.")
                try:
                    est = spec.estimator
                    if not (spec.name == "Bayes-GPR" and X_train.shape[0] > 2000):
                        est.fit(X_train.to_numpy(), y_train)
                        tuned_models[spec.name] = est
                        tuning_summaries[spec.name] = {"skipped_bo": True, "reason": str(e), "best_params": {}, "best_cv_auc": np.nan}
                        joblib.dump(est, outdir / "models" / f"{spec.name}.joblib")
                except Exception as e2:
                    print(f"[ERROR] {spec.name} default fit failed: {e2}. Skipping.")

        # Save checkpoint after training
        print(f"[INFO] Saving checkpoint to {checkpoint_path}")
        joblib.dump({
            'X_train': X_train, 'X_test': X_test, 'y_train': y_train, 'y_test': y_test,
            'genes': genes, 'tuned_models': tuned_models, 'tuning_summaries': tuning_summaries
        }, checkpoint_path)

    # Load from checkpoint if we are in eval or explain mode
    if args.step in ["eval", "explain"]:
        if not checkpoint_path.exists():
            raise FileNotFoundError(f"Checkpoint not found at {checkpoint_path}. Run with --step train first.")
        print(f"[INFO] Loading checkpoint from {checkpoint_path}")
        cp = joblib.load(checkpoint_path)
        X_train, X_test = cp['X_train'], cp['X_test']
        y_train, y_test = cp['y_train'], cp['y_test']
        genes = cp['genes']
        tuned_models = cp['tuned_models']
        tuning_summaries = cp['tuning_summaries']

    if args.step in ["all", "eval"]:
        # Evaluate each model on TEST
        for name, model in tuned_models.items():
            try:
                prob = get_proba(model, X_test.to_numpy())
                proba_dict[name] = prob
                met = eval_binary(y_test, prob, threshold=0.5)
                thr, j = youden_threshold(y_test, prob)
                met.update({"youden_threshold": float(thr), "youden_j": float(j)})
                met["metrics_at_youden_threshold"] = eval_binary(y_test, prob, threshold=thr)
                met["roc_auc_ci95"] = list(bootstrap_ci_auc(y_test, prob, n_boot=1000, seed=args.seed))
                metrics_all[name] = met
            except Exception as e:
                print(f"[WARN] Evaluation failed for {name}: {e}")

        # Stacking
        from sklearn.ensemble import StackingClassifier
        ranks = sorted([(n, tuning_summaries.get(n, {}).get("best_cv_auc", metrics_all.get(n, {}).get("roc_auc", -1))) 
                       for n in tuned_models.keys()], key=lambda x: np.nan_to_num(x[1], -1), reverse=True)
        top_names = [n for n, _ in ranks[:max(1, args.top_k)]]
        preferred = ["Bayes-CatBoost", "Bayes-LightGBM", "Bayes-XGBoost"]
        if all(p in tuned_models for p in preferred) and any(p in top_names for p in preferred):
            top_names = preferred

        estimators = [(n, tuned_models[n]) for n in top_names if n in tuned_models]
        print(f"[INFO] Fitting stacking with {len(estimators)} learners...")
        stack = StackingClassifier(estimators=estimators, final_estimator=LogisticRegression(max_iter=2000), cv=cv, n_jobs=-1)
        stack.fit(X_train.to_numpy(), y_train)
        joblib.dump(stack, outdir / "models" / "Stacking.joblib")

        prob_stack = get_proba(stack, X_test.to_numpy())
        proba_dict["Stacking"] = prob_stack
        met = eval_binary(y_test, prob_stack, threshold=0.5)
        thr, j = youden_threshold(y_test, prob_stack)
        met.update({"youden_threshold": float(thr), "youden_j": float(j)})
        met["metrics_at_youden_threshold"] = eval_binary(y_test, prob_stack, threshold=thr)
        met["roc_auc_ci95"] = list(bootstrap_ci_auc(y_test, prob_stack, n_boot=1000, seed=args.seed))
        metrics_all["Stacking"] = met

        # Save results
        (outdir / "metrics.json").write_text(json.dumps(metrics_all, indent=2, ensure_ascii=False), encoding="utf-8")
        pd.DataFrame([{"model": m, **{k: (json.dumps(v) if isinstance(v, (dict, list)) else v) for k, v in met.items()}} 
                    for m, met in metrics_all.items()]).to_csv(outdir / "metrics.csv", index=False)

        figdir = outdir / "figures"
        plot_multigene_roc(y_test, proba_dict, figdir / "Fig_ROC_multigene_models.png")
        plot_multigene_pr(y_test, proba_dict, figdir / "Fig_PR_multigene_models.png")
        plot_calibration(y_test, prob_stack, figdir / "calibration_stacking.png")
        plot_confusion(confusion_matrix(y_test, (prob_stack >= 0.5).astype(int)), figdir / "confusion_matrix_stacking.png")
        plot_roc_univariate_per_gene(X_train, y_train, X_test, y_test, genes, tuned_models, figdir)
        (outdir / "bo_logs" / "tuning_summary.json").write_text(json.dumps(tuning_summaries, indent=2, ensure_ascii=False), encoding="utf-8")

    if args.step in ["all", "explain"]:
        # Attempt to load metrics if not already present (needed if running only 'explain' step)
        if not metrics_all:
            metrics_json = outdir / "metrics.json"
            if metrics_json.exists():
                try:
                    metrics_all = json.loads(metrics_json.read_text(encoding="utf-8"))
                    print(f"[INFO] Loaded metrics for model selection from {metrics_json}")
                except Exception as e:
                    print(f"[WARN] Failed to load metrics for model selection: {e}")

        prefer = ["Bayes-XGBoost", "Bayes-CatBoost", "Bayes-LightGBM"]
        models_to_use_for_explain = tuned_models if tuned_models else {}
        
        best_name = next((p for p in prefer if p in models_to_use_for_explain), None)
        if best_name is None and metrics_all:
            # If preferred models not in tuned_models but are in metrics_all (already evaluated)
            best_name = next((p for p in prefer if p in metrics_all), None)
            if best_name is None:
                best_name = max(metrics_all.keys(), key=lambda n: metrics_all.get(n, {}).get("roc_auc", -1))
        
        if best_name is None and models_to_use_for_explain:
            # Fallback to any model that is likely a tree model in tuned_models
            best_name = next((n for n in models_to_use_for_explain.keys() if any(k in n.lower() for k in ["xgboost", "catboost", "lightgbm", "rf"])), list(models_to_use_for_explain.keys())[0])

        if best_name and best_name in models_to_use_for_explain:
            print(f"[INFO] Running explainability for Best Model: {best_name}")
            run_explainability(best_name, models_to_use_for_explain[best_name], X_train, X_test, y_test, outdir, args.seed)
        else:
            print("[WARN] No model selected for explainability.")
    
    write_env(outdir)
    print(f"[DONE] Stage '{args.step}' complete. Outputs: {outdir.resolve()}")

if __name__ == "__main__":
    main()
