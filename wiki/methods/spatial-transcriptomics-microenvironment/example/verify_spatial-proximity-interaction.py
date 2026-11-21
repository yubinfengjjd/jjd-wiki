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
    assert (inter_df["p_value"].between(0.0, 1.0)).all(), "Invalid p-values"
    assert (dist_df["median_nn_dist"] >= 0).all() and np.isfinite(dist_df["median_nn_dist"]).all()

    inter_df.to_csv(out_dir / "spatial_interaction_pairs.csv", index=False)
    dist_df.to_csv(out_dir / "nearest_neighbor_distances.csv", index=False)

    n_co = int((inter_df["sig_state"] == "Co-occurrence").sum())
    n_av = int((inter_df["sig_state"] == "Avoidance").sum())
    payload = {
        "scope": "Real CyCIF FOV slice (Nirmal 2022, 420 cells across 2 FOVs); verified 20 um 200-permutation spatial co-occurrence/avoidance test and nearest-neighbor physical distances.",
        "checks": [
            f"interaction_pairs={len(inter_df)} (co_occurrence={n_co}, avoidance={n_av})",
            f"distance_pairs={len(dist_df)}",
            "p_values_in_0_1=true",
            "nearest_neighbor_distances_non_negative_finite=true",
        ],
    }
    (out_dir / "checks.json").write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
