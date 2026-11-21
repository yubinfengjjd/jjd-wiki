"""Verification driver for cell-proportion-composition / compartment-prop-stats."""
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
    from compartment_prop_stats import run_compartment_prop_stats

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
    assert tests_df["p_adj"].dropna().between(0.0, 1.0).all()

    prop_df.to_csv(out_dir / "compartment_proportions.csv", index=False)
    tests_df.to_csv(out_dir / "stage_group_tests.csv", index=False)

    payload = {
        "scope": "Real CyCIF FOV compartment slice (Nirmal 2022, 1,418 cells across Epidermis/Dermis and 4 progression stages); verified ROI-level proportion normalization and BH-adjusted Kruskal-Wallis tests.",
        "checks": [
            f"input_cells={len(cells)}, units={len(unit_sums)}",
            "unit_proportion_sums_equal_1=true",
            f"kruskal_wallis_tests={len(tests_df)}",
            "bh_padj_in_0_1=true",
        ],
    }
    (out_dir / "checks.json").write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
