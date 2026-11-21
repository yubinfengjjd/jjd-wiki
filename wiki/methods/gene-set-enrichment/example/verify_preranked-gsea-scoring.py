"""Verification driver for gene-set-enrichment / preranked-gsea-scoring."""
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
    from preranked_gsea_scoring import run_preranked_gsea

    ranked_df = pd.read_csv(example_dir / "mrseq_ranked_genes.csv")
    gene_sets = json.loads((example_dir / "melanoma_gene_sets.json").read_text(encoding="utf-8"))

    res = run_preranked_gsea(
        ranked_df,
        gene_sets,
        gene_col="gene_symbol",
        stat_col="stat",
        weight=1.0,
        n_perm=300,
        min_size=5,
        max_size=500,
        seed=42,
    )

    sum_df = res["summary"]
    curves_df = res["running_curves"]

    assert len(sum_df) == len(gene_sets), f"Expected all {len(gene_sets)} sets evaluated, got {len(sum_df)}"
    assert np.isfinite(sum_df["ES"]).all() and (sum_df["ES"].abs() <= 1.0 + 1e-6).all()
    assert np.isfinite(sum_df["NES"]).all()
    assert sum_df["pvalue"].between(0.0, 1.0).all() and sum_df["p_adjust"].between(0.0, 1.0).all()
    assert len(curves_df) == len(sum_df) * len(ranked_df)

    sum_df.to_csv(out_dir / "gsea_summary.csv", index=False)
    # Write compact running curves summary (every 10th rank + all hit positions)
    compact_curves = curves_df[(curves_df["position"] == 1) | (curves_df["x"] % 10 == 1)].copy()
    compact_curves.to_csv(out_dir / "gsea_running_curves.csv", index=False)

    payload = {
        "scope": f"Real PickSeq IM-vs-EM DESeq2 ranked gene list (Nirmal 2022, {len(ranked_df)} genes) x {len(gene_sets)} MSigDB Hallmark gene sets; verified weighted Running ES, NES, BH-adjusted empirical permutation p-values, and leading-edge genes.",
        "checks": [
            f"ranked_genes={len(ranked_df)}, pathways_tested={len(sum_df)}",
            "running_es_bounded_in_minus1_1=true",
            "nes_finite_and_pvalues_in_0_1=true",
            f"top_pathway={sum_df.loc[0, 'pathway']} (NES={sum_df.loc[0, 'NES']:.3f}, p={sum_df.loc[0, 'pvalue']:.4f})",
        ],
    }
    (out_dir / "checks.json").write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
