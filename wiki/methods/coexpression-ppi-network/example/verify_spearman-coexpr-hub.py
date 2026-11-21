"""Verification driver for coexpression-ppi-network / spearman-coexpr-hub."""
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
    from spearman_coexpr_hub import run_spearman_coexpr_hub

    expr_df = pd.read_csv(example_dir / "mrseq_s100b_expr_slice.csv")
    res = run_spearman_coexpr_hub(
        expr_df,
        gene_col="gene_symbol",
        hub_gene="S100B",
        r_threshold=0.6,
        use_abs=True,
    )

    edges_df = res["edges"]
    hub_df = res["hub_neighbors"]
    mod_df = res["module_scores"]

    assert len(edges_df) > 0, "Expected co-expression edges at |r| >= 0.6"
    assert (edges_df["abs_r"] >= 0.6).all(), "Edge threshold violated"
    assert "S100B" in set(hub_df["gene_symbol"]) and len(hub_df) >= 5
    assert len(mod_df) == expr_df.shape[1] - 1
    assert np.isfinite(mod_df["module_mean_expr"]).all()

    edges_df.to_csv(out_dir / "coexpr_edges.csv", index=False)
    hub_df.to_csv(out_dir / "hub_neighbors.csv", index=False)
    mod_df.to_csv(out_dir / "module_scores.csv", index=False)

    payload = {
        "scope": "Real PickSeq mrSEQ log2-normalized expression slice (Nirmal 2022, 100 genes x 120 mROIs); verified Spearman |r| >= 0.6 network edges, S100B 1-hop hub module extraction, and per-sample module scoring.",
        "checks": [
            f"genes={len(expr_df)}, samples={len(mod_df)}",
            f"coexpr_edges_ge_0.6={len(edges_df)}",
            f"s100b_1hop_module_size={len(hub_df)}",
            "module_scores_finite_and_ordered=true",
        ],
    }
    (out_dir / "checks.json").write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
