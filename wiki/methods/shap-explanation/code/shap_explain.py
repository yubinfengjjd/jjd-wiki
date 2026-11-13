"""训练一个模型并用 SHAP 解释它，写出图表模板读取的两张表。

改下面“要改的”一节，其余不用动。用法：python shap_explain.py
依赖：pandas、numpy、scipy、shap、scikit-learn；模型库按 MODEL 需要。
"""
from pathlib import Path

# ── 要改的 ──────────────────────────────────────────────
DATA = "data.csv"        # 一行一个样本，数值特征列 + 目标列
TARGET = "y"             # 目标列名
TASK = "regression"      # regression | classification（二分类）
MODEL = "xgboost"        # xgboost | lightgbm | catboost | random_forest | gbdt | extra_trees |
                         # logistic | linear | lasso | svm | mlp
MODEL_PARAMS = {}        # 传给模型的额外参数，如 {"n_estimators": 300, "max_depth": 4}
TEST_SIZE = 0.3
RANDOM_STATE = 42
TOP_N = 15               # 按平均绝对 SHAP 保留前几个特征
MIN_MEAN_ABS_SHAP = 0.0  # 低于此值的特征剔除
EXPLAIN_SAMPLES = 500    # 逐样本表最多用多少个测试样本（模型无关解释器 300–500 较稳）
OUT = Path("analysis")   # 输出目录
# ────────────────────────────────────────────────────────

import numpy as np
import pandas as pd
import shap
from sklearn.metrics import accuracy_score, mean_absolute_error, mean_squared_error, r2_score, roc_auc_score
from sklearn.model_selection import train_test_split

TREE_MODELS = ("xgboost", "lightgbm", "catboost", "random_forest", "extra_trees", "gbdt")
LINEAR_MODELS = ("logistic", "linear", "lasso")


def build_model(name: str):
    binary = TASK == "classification"
    if name == "xgboost":
        from xgboost import XGBClassifier, XGBRegressor

        return (XGBClassifier if binary else XGBRegressor)(random_state=RANDOM_STATE, n_jobs=1, **MODEL_PARAMS)
    if name == "lightgbm":
        from lightgbm import LGBMClassifier, LGBMRegressor

        return (LGBMClassifier if binary else LGBMRegressor)(random_state=RANDOM_STATE, n_jobs=1, verbose=-1, **MODEL_PARAMS)
    if name == "catboost":
        from catboost import CatBoostClassifier, CatBoostRegressor

        return (CatBoostClassifier if binary else CatBoostRegressor)(random_seed=RANDOM_STATE, verbose=0, **MODEL_PARAMS)
    from sklearn.ensemble import (ExtraTreesClassifier, ExtraTreesRegressor, GradientBoostingClassifier,
                                  GradientBoostingRegressor, RandomForestClassifier, RandomForestRegressor)
    from sklearn.linear_model import Lasso, LinearRegression, LogisticRegression
    from sklearn.neural_network import MLPClassifier, MLPRegressor
    from sklearn.svm import SVC, SVR

    choices = {
        "random_forest": RandomForestClassifier if binary else RandomForestRegressor,
        "extra_trees": ExtraTreesClassifier if binary else ExtraTreesRegressor,
        "gbdt": GradientBoostingClassifier if binary else GradientBoostingRegressor,
        "logistic": LogisticRegression if binary else LinearRegression,
        "linear": LinearRegression,
        "lasso": Lasso,
        "svm": SVC if binary else SVR,
        "mlp": MLPClassifier if binary else MLPRegressor,
    }
    model = choices[name](random_state=RANDOM_STATE, **MODEL_PARAMS)
    if binary and name == "svm":
        model.set_params(probability=True)  # 解释需要阳性类概率
    return model


def predict_fn(model):
    """解释哪一份输出：分类看阳性类概率，回归看预测值本身。"""
    return (lambda x: model.predict_proba(x)[:, 1]) if TASK == "classification" else model.predict


def shap_values(model, background: pd.DataFrame, samples: pd.DataFrame) -> np.ndarray:
    if MODEL in TREE_MODELS:
        explained = shap.TreeExplainer(model)(samples)
    elif MODEL in LINEAR_MODELS:
        explained = shap.LinearExplainer(model, background)(samples)
    else:
        explained = shap.Explainer(predict_fn(model), background)(samples)
    values = np.asarray(explained.values)
    # 二分类时可能给出 (样本, 特征, 2)，取阳性类。
    return values[:, :, 1] if values.ndim == 3 else values


def main() -> None:
    data = pd.read_csv(DATA)
    features = data.drop(columns=TARGET).astype(float)
    target = data[TARGET]
    binary = TASK == "classification"
    if binary and not pd.api.types.is_numeric_dtype(target):
        target = target.map({label: index for index, label in enumerate(sorted(target.unique()))})
    train_x, test_x, train_y, test_y = train_test_split(
        features, target, test_size=TEST_SIZE, random_state=RANDOM_STATE,
        stratify=target if binary else None)

    model = build_model(MODEL)
    model.fit(train_x, train_y)

    if binary:
        probability = model.predict_proba(test_x)[:, 1]
        print(f"test AUROC: {roc_auc_score(test_y, probability):.3f}  "
              f"accuracy: {accuracy_score(test_y, probability > 0.5):.3f}")
    else:
        prediction = model.predict(test_x)
        baseline = np.full(len(test_y), train_y.mean())
        print(f"test R2: {r2_score(test_y, prediction):.3f}  "
              f"RMSE: {mean_squared_error(test_y, prediction) ** 0.5:.3f}  "
              f"MAE: {mean_absolute_error(test_y, prediction):.3f}  "
              f"(mean baseline RMSE {mean_squared_error(test_y, baseline) ** 0.5:.3f})")

    explained = test_x.head(EXPLAIN_SAMPLES)
    values = shap_values(model, train_x, explained)

    importance = np.abs(values).mean(axis=0)
    total = importance.sum()
    percent = np.divide(100 * importance, total, out=np.zeros_like(importance), where=total != 0)
    summary = pd.DataFrame({"feature": features.columns, "shap": importance, "percent": percent})
    summary = summary.sort_values("shap", ascending=False, kind="stable")
    summary = summary[summary["shap"] >= MIN_MEAN_ABS_SHAP].head(TOP_N)
    selected = features.columns.get_indexer(summary["feature"])

    # 着色值在解释样本内按每个特征最小–最大缩放到 0–1；常数特征取 0。
    raw = explained.to_numpy()
    span = np.ptp(raw, axis=0)
    scaled = np.divide(raw - raw.min(axis=0), span, out=np.zeros_like(raw), where=span != 0)
    samples = pd.DataFrame({
        "feature": np.tile(summary["feature"].to_numpy(), len(explained)),
        "shap": values[:, selected].ravel(),
        "feature_value": scaled[:, selected].ravel(),
    })

    OUT.mkdir(parents=True, exist_ok=True)
    summary.to_csv(OUT / "shap-summary.csv", index=False)
    samples.to_csv(OUT / "shap-samples.csv", index=False)
    print(f"保留 {len(summary)} 个特征；逐样本表 {len(explained)} 个解释样本 → {OUT}")


if __name__ == "__main__":
    main()
