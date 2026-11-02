"""Exact source evaluation functions. No training, label inference, filtering, orientation selection or file I/O at import."""
from __future__ import annotations
from typing import Dict, Tuple
import numpy as np
from sklearn.metrics import (roc_auc_score, roc_curve, average_precision_score, accuracy_score, precision_score, recall_score, f1_score, confusion_matrix, brier_score_loss)

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
