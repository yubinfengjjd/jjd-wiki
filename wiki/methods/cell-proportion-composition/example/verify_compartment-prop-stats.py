"""Verification driver for cell-proportion-composition / compartment-prop-stats."""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

import numpy as np
import pandas as pd
from scipy import stats


def _reference_bh(pvals: np.ndarray) -> np.ndarray:
    out = np.full(len(pvals), np.nan, dtype=float)
    valid = np.isfinite(pvals)
    if not valid.any():
        return out
    pv = pvals[valid]
    m = len(pv)
    order = np.argsort(pv)
    adj = pv[order] * m / np.arange(1, m + 1, dtype=float)
    adj = np.minimum.accumulate(adj[::-1])[::-1]
    adj = np.clip(adj, 0.0, 1.0)
    res = np.empty(m, dtype=float)
    res[order] = adj
    out[valid] = res
    return out


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--code", required=True)
    parser.add_argument("--example", required=True)
    parser.add_argument("--out", required=True)
    args = parser.parse_args()

    code_dir = Path(args.code)
    example_dir = Path(args.example)
    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)

    sys.path.insert(0, str(code_dir))
    from compartment_prop_stats import run_compartment_prop_stats

    # 1. Descriptive normalization + single-ROI untestable gating + integer cell_type robustness on 4-ROI compartment slice
    cells = pd.read_csv(example_dir / "nirmal_compartment_cells.csv")
    res = run_compartment_prop_stats(
        cells,
        sample_col="roi_id",
        group_col="Stage",
        celltype_col="phenotype_abbrev",
        compartment_col="compartment",
    )

    prop_df = res["proportions"]
    tests_df = res["group_tests"]

    unit_sums = prop_df.groupby(["roi_id", "Stage", "compartment"])["proportion"].sum().to_numpy()
    assert np.allclose(unit_sums, 1.0, atol=1e-6), "Proportions per ROI x compartment must sum to 1"
    assert len(tests_df) > 0
    assert (tests_df["test_status"] == "untestable_insufficient_replicates").all(), (
        "Single-ROI-per-stage slice must not report inferential p-values"
    )
    assert tests_df["p_value"].isna().all() and tests_df["padj"].isna().all()

    # Integer cell_type label robustness check
    int_cells = cells.copy()
    label_map = {lbl: idx + 1 for idx, lbl in enumerate(sorted(int_cells["phenotype_abbrev"].astype(str).unique()))}
    int_cells["phenotype_int"] = int_cells["phenotype_abbrev"].astype(str).map(label_map).astype(int)
    res_int = run_compartment_prop_stats(
        int_cells,
        sample_col="roi_id",
        group_col="Stage",
        celltype_col="phenotype_int",
        compartment_col="compartment",
    )
    int_prop = res_int["proportions"]
    assert int(int_prop["count"].sum()) == len(cells), "Integer cell_type labels must preserve total cell counts"
    int_unit_sums = int_prop.groupby(["roi_id", "Stage", "compartment"])["proportion"].sum().to_numpy()
    assert np.allclose(int_unit_sums, 1.0, atol=1e-6)
    inv_map = {str(v): k for k, v in label_map.items()}
    int_prop_cmp = int_prop.assign(cell_type=int_prop["cell_type"].map(inv_map)).sort_values(
        ["roi_id", "Stage", "compartment", "cell_type"]
    ).reset_index(drop=True)
    str_prop_cmp = prop_df.sort_values(["roi_id", "Stage", "compartment", "cell_type"]).reset_index(drop=True)
    assert np.array_equal(int_prop_cmp["count"].to_numpy(), str_prop_cmp["count"].to_numpy())
    assert np.allclose(int_prop_cmp["proportion"].to_numpy(), str_prop_cmp["proportion"].to_numpy(), atol=1e-12)

    # 2. Multi-ROI independent replicate verification (IM=6, MIS=8, Normal=2, Precursor=1)
    strat_cells = pd.read_csv(example_dir / "nirmal_stratified_cells.csv")
    res_strat = run_compartment_prop_stats(
        strat_cells,
        sample_col="roi_id",
        group_col="Stage",
        celltype_col="phenotype_abbrev",
        compartment_col=None,
    )
    strat_prop = res_strat["proportions"]
    strat_tests = res_strat["group_tests"]

    strat_unit_sums = strat_prop.groupby(["roi_id", "Stage"])["proportion"].sum().to_numpy()
    assert np.allclose(strat_unit_sums, 1.0, atol=1e-6)

    tested_mask = strat_tests["test_status"] == "tested_mann_whitney_u"
    insufficient_mask = strat_tests["test_status"] == "untestable_insufficient_replicates"
    assert tested_mask.any(), "Expected testable multi-ROI pairwise comparisons"
    assert insufficient_mask.any(), "Expected untestable Precursor (1 ROI) pairwise comparisons"
    assert ((strat_tests.loc[tested_mask, "n_roi_a"] >= 2) & (strat_tests.loc[tested_mask, "n_roi_b"] >= 2)).all()
    assert ((strat_tests.loc[insufficient_mask, "n_roi_a"] < 2) | (strat_tests.loc[insufficient_mask, "n_roi_b"] < 2)).all()
    assert strat_tests.loc[insufficient_mask, "p_value"].isna().all()
    assert strat_tests.loc[insufficient_mask, "padj"].isna().all()

    # Exact numerical check of Mann-Whitney U and BH FDR against scipy/reference formula
    for row in strat_tests.loc[tested_mask].itertuples(index=False):
        sub_ct = strat_prop[strat_prop["cell_type"] == row.cell_type]
        va = sub_ct.loc[sub_ct["Stage"] == row.group_a, "proportion"].to_numpy(dtype=float)
        vb = sub_ct.loc[sub_ct["Stage"] == row.group_b, "proportion"].to_numpy(dtype=float)
        ref_mw = stats.mannwhitneyu(va, vb, alternative="two-sided")
        assert abs(float(row.u_statistic) - round(float(ref_mw.statistic), 4)) <= 1e-4
        assert abs(float(row.p_value) - float(ref_mw.pvalue)) <= 1e-12

    ref_padj = _reference_bh(strat_tests["p_value"].to_numpy(dtype=float))
    valid_padj = np.isfinite(ref_padj)
    assert np.allclose(strat_tests.loc[valid_padj, "padj"].to_numpy(dtype=float), ref_padj[valid_padj], atol=1e-12)
    assert strat_tests["padj"].dropna().between(0.0, 1.0).all()

    prop_df.to_csv(out_dir / "compartment_proportions.csv", index=False)
    tests_df.to_csv(out_dir / "compartment_single_roi_tests.csv", index=False)
    strat_tests.to_csv(out_dir / "stratified_multi_roi_tests.csv", index=False)

    payload = {
        "scope": (
            "Two real Nirmal 2022 CyCIF slices: (1) descriptive compartment proportion normalization, "
            "integer cell_type label robustness, and single-ROI untestable gating on nirmal_compartment_cells.csv "
            "(1,418 cells across 4 single-ROI stages and Epidermis/Dermis); (2) replicate-gated pairwise Mann-Whitney U "
            "and BH FDR exact numerical verification on nirmal_stratified_cells.csv "
            "(1,987 cells across 17 ROIs: IM=6, MIS=8, Normal=2 testable; Precursor=1 untestable)."
        ),
        "checks": [
            f"compartment_slice_cells={len(cells)}, units={len(unit_sums)}, untestable_pairs={len(tests_df)}",
            "unit_proportion_sums_equal_1=true",
            "integer_celltype_label_counts_consistent=true",
            "single_roi_comparisons_flagged_untestable_nan=true",
            f"stratified_slice_cells={len(strat_cells)}, multi_roi_tested_pairs={int(tested_mask.sum())}, untestable_pairs={int(insufficient_mask.sum())}",
            "mann_whitney_u_and_bh_padj_exact_match=true",
        ],
    }
    (out_dir / "checks.json").write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
