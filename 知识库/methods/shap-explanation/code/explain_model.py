"""Explain an already fitted model; never split data, fit, tune, or save files.

Source: shap_explain.py shap_values() and main() table calculations. Tree,
linear and generic explanation retain those branches. Caller owns background,
sample selection and positive-class meaning. Input data frames must have the
same ordered numeric feature columns. Original script remains unchanged.
"""
import numpy as np
import pandas as pd
import shap


def explain_model(model, background, samples, *, explainer_kind,
                  task='regression', output_index=1, top_n=15,
                  min_mean_abs_shap=0.0, explainer_parameters=None,
                  call_parameters=None):
    """Return values, summary/samples tables and diagnostics without training.

    explainer_kind: tree | linear | model_agnostic. For classification generic
    explanation uses predict_proba[:, output_index]. Multioutput tree/linear
    arrays select that same explicit output index. Percent denominator includes
    ALL features before filtering. feature_value is min/max scaled within the
    explanation samples, exactly as the original script (constants are zero).
    Kernel/generic methods may be stochastic: pass their seed/options explicitly.
    """
    if not isinstance(background, pd.DataFrame) or not isinstance(samples, pd.DataFrame):
        raise TypeError('background and samples must be pandas DataFrames')
    if not background.columns.equals(samples.columns) or not samples.columns.is_unique:
        raise ValueError('background/samples require identical unique feature order')
    if background.empty or samples.empty:
        raise ValueError('background and samples must be nonempty')
    if task not in ('regression', 'classification'):
        raise ValueError('task must be regression or classification')
    if not isinstance(top_n, int) or top_n < 1 or min_mean_abs_shap < 0:
        raise ValueError('top_n must be positive and min_mean_abs_shap nonnegative')
    raw = samples.to_numpy(dtype=float, copy=True)
    if not np.isfinite(raw).all() or not np.isfinite(background.to_numpy(dtype=float)).all():
        raise ValueError('Features must be finite numeric values')
    options = dict(explainer_parameters or {})
    if explainer_kind == 'tree':
        explainer = shap.TreeExplainer(model, **options)
    elif explainer_kind == 'linear':
        explainer = shap.LinearExplainer(model, background.copy(), **options)
    elif explainer_kind == 'model_agnostic':
        predict = ((lambda x: model.predict_proba(x)[:, output_index])
                   if task == 'classification' else model.predict)
        explainer = shap.Explainer(predict, background.copy(), **options)
    else:
        raise ValueError('Unknown explainer_kind')
    explanation = explainer(samples.copy(), **dict(call_parameters or {}))
    values = np.asarray(explanation.values)
    if values.ndim == 3:
        values = values[:, :, output_index]
    if values.shape != raw.shape:
        raise ValueError(f'Expected sample by feature SHAP array, got {values.shape}')
    importance = np.abs(values).mean(axis=0)
    total = importance.sum()
    percent = np.divide(100 * importance, total, out=np.zeros_like(importance), where=total != 0)
    summary = pd.DataFrame(dict(feature=samples.columns, shap=importance, percent=percent))
    summary = summary.sort_values('shap', ascending=False, kind='stable')
    summary = summary[summary.shap >= min_mean_abs_shap].head(top_n).reset_index(drop=True)
    selected = samples.columns.get_indexer(summary.feature)
    span = np.ptp(raw, axis=0)
    scaled = np.divide(raw-raw.min(axis=0), span, out=np.zeros_like(raw), where=span != 0)
    long = pd.DataFrame(dict(feature=np.tile(summary.feature.to_numpy(), len(samples)),
        shap=values[:, selected].ravel(), feature_value=scaled[:, selected].ravel()))
    return dict(values=values, summary=summary, samples=long, diagnostics=dict(
        explainer_kind=explainer_kind, task=task, output_index=output_index,
        n_background=len(background), n_samples=len(samples), n_features=len(samples.columns),
        feature_order=samples.columns.tolist(), percent_denominator='all features',
        feature_value_scale='per feature min/max in explanation samples; constant=0',
        shap_version=shap.__version__, model_training='caller supplied fitted model'))
