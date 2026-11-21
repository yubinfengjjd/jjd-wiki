"""Sample/compartment-level cell composition normalization and group-difference testing.

Adapted from Nirmal et al., Cancer Discovery 2022 (PMC9167783).
"""
from __future__ import annotations

import numpy as np
import pandas as pd
from scipy import stats


def _bh_adjust(pvals: np.ndarray) -> np.ndarray:
    n = len(pvals)
    if n == 0:
        return np.array([], dtype=float)
    out = np.full(n, np.nan, dtype=float)
    valid = np.isfinite(pvals)
    if not valid.any():
        return out
    pv = pvals[valid]
    m = len(pv)
    order = np.argsort(pv)
    ranked = pv[order]
    adj = ranked * m / np.arange(1, m + 1, dtype=float)
    adj = np.minimum.accumulate(adj[::-1])[::-1]
    adj = np.clip(adj, 0.0, 1.0)
    res = np.empty(m, dtype=float)
    res[order] = adj
    out[valid] = res
    return out


def run_compartment_prop_stats(
    cells_df: pd.DataFrame,
    *,
    sample_col: str = "roi_id",
    group_col: str = "Stage",
    celltype_col: str = "phenotype_abbrev",
    compartment_col: str | None = "compartment",
) -> dict[str, pd.DataFrame]:
    """Compute per-sample/compartment normalized cell proportions and group-level Kruskal-Wallis tests."""
    required = {sample_col, group_col, celltype_col}
    if compartment_col is not None:
        required.add(compartment_col)
    missing = required - set(cells_df.columns)
    if missing:
        raise ValueError(f"Missing required columns: {sorted(missing)}")

    df = cells_df.copy()
    group_keys = [sample_col, group_col] + ([compartment_col] if compartment_col is not None else [])
    all_celltypes = sorted(df[celltype_col].astype(str).unique().tolist())

    # Complete sample x compartment x celltype table so missing types get proportion 0
    counts = (
        df.groupby(group_keys + [celltype_col], observed=True)
        .size()
        .unstack(fill_value=0)
        .reindex(columns=all_celltypes, fill_value=0)
    )
    totals = counts.sum(axis=1)
    props = counts.div(totals.replace(0, np.nan), axis=0).fillna(0.0)

    long_counts = counts.stack().rename("count")
    long_props = props.stack().rename("proportion")
    prop_df = pd.concat([long_counts, long_props], axis=1).reset_index()
    prop_df.rename(columns={celltype_col: "cell_type"}, inplace=True)
    prop_df["total_cells"] = prop_df.groupby(group_keys)["count"].transform("sum")

    # Compartment-level summary across groups
    sum_keys = [group_col] + ([compartment_col] if compartment_col is not None else []) + ["cell_type"]
    summary_df = (
        prop_df.groupby(sum_keys, observed=True)["proportion"]
        .agg(n_units="count", mean_proportion="mean", median_proportion="median", sd_proportion="std")
        .reset_index()
    )

    # Sample-level group difference tests (Kruskal-Wallis across groups per cell_type & compartment)
    test_rows = []
    split_cols = ([compartment_col] if compartment_col is not None else []) + ["cell_type"]
    for keys, sub in prop_df.groupby(split_cols, observed=True):
        if not isinstance(keys, tuple):
            keys = (keys,)
        groups = [g["proportion"].to_numpy(dtype=float) for _, g in sub.groupby(group_col, observed=True) if len(g) > 0]
        if len(groups) >= 2 and np.std(np.concatenate(groups)) > 0:
            stat_v, p_v = stats.kruskal(*groups)
        else:
            stat_v, p_v = np.nan, 1.0
        row = {col: val for col, val in zip(split_cols, keys)}
        row.update({
            "n_groups": int(len(groups)),
            "n_units": int(len(sub)),
            "kw_statistic": round(float(stat_v), 4) if np.isfinite(stat_v) else np.nan,
            "p_value": float(p_v) if np.isfinite(p_v) else np.nan,
        })
        test_rows.append(row)

    tests_df = pd.DataFrame(test_rows)
    if len(tests_df) > 0:
        tests_df["p_adj"] = _bh_adjust(tests_df["p_value"].to_numpy(dtype=float))
        tests_df = tests_df.sort_values(["p_adj", "p_value"], na_position="last").reset_index(drop=True)

    return {
        "proportions": prop_df,
        "summary": summary_df,
        "group_tests": tests_df,
    }
