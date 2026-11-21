"""Verification driver for spatial-transcriptomics-microenvironment / spatial-proximity-interaction."""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

import numpy as np
import pandas as pd


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
    from spatial_proximity_interaction import run_spatial_proximity_interaction

    cells = pd.read_csv(example_dir / "cycif_fov_slice.csv")
    res = run_spatial_proximity_interaction(
        cells,
        x_col="X_um",
        y_col="Y_um",
        phenotype_col="phenotype_abbrev",
        fov_col="fov_id",
        radius=20.0,
        n_perm=200,
        alpha=0.05,
        seed=42,
    )

    inter_df = res["interactions"]
    dist_df = res["distances"]

    assert len(inter_df) > 0 and len(dist_df) > 0, "Empty output tables"
    assert set(inter_df["sig_state"].unique()) <= {"Co-occurrence", "Avoidance", "Non-Sig"}
    assert ((inter_df["p_emp"] > 0.0) & (inter_df["p_emp"] <= 1.0)).all(), "Empirical p-values must be in (0, 1]"
    assert (inter_df["padj_bh"].between(0.0, 1.0)).all(), "BH adjusted p-values must be in [0, 1]"
    assert (inter_df["padj_bh"] >= inter_df["p_emp"] - 1e-12).all(), "BH padj must satisfy padj_bh >= p_emp"
    assert (dist_df["median_nn_dist"] >= 0).all() and np.isfinite(dist_df["median_nn_dist"]).all()

    # 1. Node-label conservation within each FOV:
    # (a) Total directed adjacency edge count per FOV is invariant across permutations (obs_sum == perm_mean_sum).
    for fov, sub in inter_df.groupby("fov_id"):
        assert abs(float(sub["obs_count"].sum()) - float(sub["perm_mean"].sum())) < 0.05, (
            f"Edge count not conserved in {fov}"
        )
    # (b) Singleton phenotypes (count == 1 in MEL11_FOV_Normal: DC, Th) can never self-pair under node-label permutation.
    fov_norm_counts = cells[cells["fov_id"] == "MEL11_FOV_Normal"]["phenotype_abbrev"].value_counts()
    singletons = [p for p, c in fov_norm_counts.items() if c == 1]
    assert len(singletons) > 0
    for sp in singletons:
        row = inter_df[
            (inter_df["fov_id"] == "MEL11_FOV_Normal")
            & (inter_df["phenotype"] == sp)
            & (inter_df["neighbour_phenotype"] == sp)
        ]
        assert len(row) == 1
        assert int(row["obs_count"].iloc[0]) == 0 and float(row["perm_mean"].iloc[0]) == 0.0, (
            f"Node-label conservation violated for singleton phenotype {sp}"
        )

    # 2. Reproducibility under fixed seed on the real FOV slice
    res_repeat = run_spatial_proximity_interaction(
        cells,
        x_col="X_um",
        y_col="Y_um",
        phenotype_col="phenotype_abbrev",
        fov_col="fov_id",
        radius=20.0,
        n_perm=200,
        alpha=0.05,
        seed=42,
    )
    pd.testing.assert_frame_equal(inter_df, res_repeat["interactions"])
    pd.testing.assert_frame_equal(dist_df, res_repeat["distances"])

    inter_df.to_csv(out_dir / "spatial_interaction_pairs.csv", index=False)
    dist_df.to_csv(out_dir / "nearest_neighbor_distances.csv", index=False)

    n_co = int((inter_df["sig_state"] == "Co-occurrence").sum())
    n_av = int((inter_df["sig_state"] == "Avoidance").sum())
    payload = {
        "scope": (
            "Real CyCIF FOV slice (Nirmal 2022, 420 cells across 2 FOVs); verified 20 um 200-permutation "
            "node-label permutation spatial co-occurrence/avoidance test with +1 smoothed empirical two-sided p_emp, "
            "per-FOV BH FDR correction (padj_bh), and nearest-neighbor physical distances."
        ),
        "checks": [
            f"interaction_pairs={len(inter_df)} (co_occurrence={n_co}, avoidance={n_av})",
            f"distance_pairs={len(dist_df)}",
            "node_label_counts_and_edge_totals_conserved=true",
            "p_emp_in_0_1_open_closed_and_padj_bh_ge_p_emp=true",
            "seed_reproducibility_exact=true",
            "nearest_neighbor_distances_non_negative_finite=true",
        ],
    }
    (out_dir / "checks.json").write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
