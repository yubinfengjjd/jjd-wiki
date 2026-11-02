"""Summarize held-out regression predictions; does not train or select a model.

Copy into the project, edit INPUT/OUTPUT and run in the project's Python.
Requires numpy/pandas only. Undefined R2/r remain missing (never coerced to 1).
"""
from pathlib import Path
import numpy as np
import pandas as pd

# Parameters to edit in the project
INPUT = Path('analysis/regression-predictions.csv')
OUTPUT = Path('analysis')
EXPECTED_IDS = None  # optional CSV containing sample_id, for full K-fold coverage

DESIGNS = {'kfold', 'repeated_kfold', 'group_kfold', 'time_series', 'repeated_holdout'}
REQUIRED = ['sample_id', 'model', 'repeat', 'fold', 'y_true', 'y_pred', 'split_design']


def metric_row(frame):
    true = frame['y_true'].to_numpy(float)
    pred = frame['y_pred'].to_numpy(float)
    residual = pred - true
    sst = np.square(true - true.mean()).sum()
    r2 = 1 - np.square(residual).sum() / sst if len(true) >= 2 and sst > 0 else np.nan
    corr = np.corrcoef(true, pred)[0, 1] if len(true) >= 2 and np.ptp(true) > 0 and np.ptp(pred) > 0 else np.nan
    return dict(n_test=len(true), RMSE=float(np.sqrt(np.square(residual).mean())),
                MAE=float(np.abs(residual).mean()), R2=float(r2), r=float(corr))


def summarize(frame, expected_ids=None):
    missing = set(REQUIRED) - set(frame.columns)
    if missing:
        raise ValueError(f'Missing columns: {sorted(missing)}')
    if frame.empty or frame[REQUIRED].isna().any().any():
        raise ValueError('Empty table or missing required values')
    frame = frame.copy()
    for col in ['sample_id', 'model', 'split_design']:
        frame[col] = frame[col].astype(str)
        if frame[col].str.strip().eq('').any():
            raise ValueError(f'Empty identifier: {col}')
    for col in ['repeat', 'fold']:
        x = pd.to_numeric(frame[col], errors='raise').to_numpy(float)
        if not np.isfinite(x).all() or (x < 1).any() or (x != np.floor(x)).any():
            raise ValueError(f'{col} must contain positive integers')
        frame[col] = x.astype(int)
    for col in ['y_true', 'y_pred']:
        frame[col] = pd.to_numeric(frame[col], errors='raise')
        if not np.isfinite(frame[col].to_numpy(float)).all():
            raise ValueError(f'Nonfinite {col}')
    designs = set(frame['split_design'])
    if len(designs) != 1 or not designs <= DESIGNS:
        raise ValueError('Use exactly one supported split_design per table')
    design = next(iter(designs))
    keys = ['model', 'repeat', 'fold', 'sample_id']
    if frame.duplicated(keys).any():
        raise ValueError('Duplicate sample within a model/repeat/fold')
    if design != 'repeated_holdout' and frame.duplicated(['model', 'repeat', 'sample_id']).any():
        raise ValueError('Each sample may be held out once per repeat in this design')
    if frame.groupby('sample_id')['y_true'].nunique().gt(1).any():
        raise ValueError('Same sample_id has inconsistent y_true')
    models = sorted(frame['model'].unique())
    # Paired comparison: exactly the same test membership for every model.
    reference = None
    for model in models:
        sub = frame.loc[frame['model'] == model]
        membership = set(map(tuple, sub[['repeat', 'fold', 'sample_id']].to_numpy()))
        if reference is None:
            reference = membership
        elif membership != reference:
            raise ValueError('Models do not share the same held-out folds/samples')
        if expected_ids is not None and design in {'kfold', 'repeated_kfold', 'group_kfold'}:
            expected = set(map(str, expected_ids))
            for _, rep in sub.groupby('repeat'):
                if set(rep['sample_id']) != expected:
                    raise ValueError('Incomplete or unexpected sample coverage')
    rows = []
    for (model, repeat, fold), sub in frame.groupby(['model', 'repeat', 'fold'], sort=True):
        rows.append(dict(model=model, repeat=int(repeat), fold=int(fold),
                         **metric_row(sub), split_design=design))
    return pd.DataFrame(rows)[['model', 'repeat', 'fold', 'n_test', 'RMSE', 'MAE', 'R2', 'r', 'split_design']]


def main():
    predictions = pd.read_csv(INPUT, dtype={'sample_id': str, 'model': str})
    expected = None if EXPECTED_IDS is None else pd.read_csv(EXPECTED_IDS, dtype={'sample_id': str})['sample_id']
    metrics = summarize(predictions, expected)
    OUTPUT.mkdir(parents=True, exist_ok=True)
    metrics.to_csv(OUTPUT / 'regression-fold-metrics.csv', index=False)
    summary = metrics.groupby('model')[['RMSE', 'MAE', 'R2', 'r']].agg(['mean', 'std'])
    summary.to_csv(OUTPUT / 'regression-metric-summary.csv')
    print(summary.to_string())
    print('Descriptive fold mean/SD only; correlated folds are not independent replicates.')
    print('Full coverage checked only when EXPECTED_IDS is supplied; upstream leakage is not detectable here.')


if __name__ == '__main__':
    main()
