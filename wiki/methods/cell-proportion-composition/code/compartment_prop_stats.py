"""Sample/compartment-level cell composition normalization and pairwise group testing.

Adapted from Nirmal et al., Cancer Discovery 2022 (PMC9167783).
"""
from __future__ import annotations

from itertools import combinations

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
    """Compute per-sample/compartment normalized cell proportions and replicate-gated Mann-Whitney U tests."""
    required = {sample_col, group_col, celltype_col}
    if compartment_col is not None:
        required.add(compartment_col)
    missing = required - set(cells_df.columns)
    if missing:
        raise ValueError(f"Missing required columns: {sorted(missing)}")

    df = cells_df.copy()
    # Standardize all grouping columns to str before groupby/unstack so integer labels never zero-out on reindex.
    norm_cols = [sample_col, group_col, celltype_col]
    if compartment_col is not None:
        norm_cols.append(compartment_col)
    for col in norm_cols:
        df[col] = df[col].astype(str)

    group_keys = [sample_col, group_col] + ([compartment_col] if compartment_col is not None else [])
    all_celltypes = sorted(df[celltype_col].unique().tolist())

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
    prop_df["total_cells"] = prop_df.groupby(group_keys, observed=True)["count"].transform("sum")

    # Compartment-level summary across groups
    sum_keys = [group_col] + ([compartment_col] if compartment_col is not None else []) + ["cell_type"]
    summary_df = (
        prop_df.groupby(sum_keys, observed=True)["proportion"]
        .agg(n_units="count", mean_proportion="mean", median_proportion="median", sd_proportion="std")
        .reset_index()
    )

    # Pairwise group tests across independent ROIs (only testable when both sides have >= 2 ROIs)
    test_rows = []
    split_cols = ([compartment_col] if compartment_col is not None else []) + ["cell_type"]
    for keys, sub in prop_df.groupby(split_cols, observed=True):
        if not isinstance(keys, tuple):
            keys = (keys,)
        groups_present = sorted(sub[group_col].unique().tolist())
        roi_by_group = {
            g: g_df.groupby(sample_col, sort=False)["proportion"].mean().to_numpy(dtype=float)
            for g, g_df in sub.groupby(group_col, observed=True)
        }
        for grp_a, grp_b in combinations(groups_present, 2):
            vals_a = roi_by_group[grp_a]
            vals_b = roi_by_group[grp_b]
            n_roi_a = int(len(vals_a))
            n_roi_b = int(len(vals_b))
            if n_roi_a < 2 or n_roi_b < 2:
                u_stat = np.nan
                p_val = np.nan
                status = "untestable_insufficient_replicates"
            elif np.ptp(np.concatenate([vals_a, vals_b])) == 0.0:
                u_stat = np.nan
                p_val = np.nan
                status = "untestable_zero_variance"
            else:
                mw = stats.mannwhitneyu(vals_a, vals_b, alternative="two-sided")
                u_stat = float(mw.statistic)
                p_val = float(mw.pvalue)
                status = "tested_mann_whitney_u" if np.isfinite(p_val) else "untestable_zero_variance"

            row = {col: val for col, val in zip(split_cols, keys)}
            row.update({
                "group_a": grp_a,
                "group_b": grp_b,
                "n_roi_a": n_roi_a,
                "n_roi_b": n_roi_b,
                "mean_prop_a": round(float(np.mean(vals_a)), 6),
                "mean_prop_b": round(float(np.mean(vals_b)), 6),
                "u_statistic": round(u_stat, 4) if np.isfinite(u_stat) else np.nan,
                "p_value": p_val if np.isfinite(p_val) else np.nan,
                "test_status": status,
            })
            test_rows.append(row)

    tests_df = pd.DataFrame(test_rows)
    if len(tests_df) > 0:
        tests_df["padj"] = _bh_adjust(tests_df["p_value"].to_numpy(dtype=float))
        tests_df = tests_df.sort_values(["padj", "p_value"], na_position="last").reset_index(drop=True)

    return {
        "proportions": prop_df,
        "summary": summary_df,
        "group_tests": tests_df,
    }
