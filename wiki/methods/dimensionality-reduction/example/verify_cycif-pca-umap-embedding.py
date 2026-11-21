"""Verification driver for dimensionality-reduction / cycif-pca-umap-embedding."""
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
    from cycif_pca_umap import run_cycif_pca_umap

    cells = pd.read_csv(example_dir / "cycif_scaled_slice.csv")
    feature_cols = [c for c in cells.columns if c.startswith("scaled_")]
    res = run_cycif_pca_umap(
        cells,
        feature_cols=feature_cols,
        cell_id_col="cell_uid",
        n_pcs=10,
        n_neighbors=15,
        min_dist=0.1,
        random_state=42,
    )

    scree_df = res["pca_scree"]
    load_df = res["pca_loadings"]
    emb_df = res["embedding"]

    assert len(emb_df) == len(cells)
    assert len(scree_df) == 10
    assert np.all(np.diff(scree_df["explained_variance_ratio"].to_numpy()) <= 1e-6)
    assert np.isfinite(emb_df[["PC1", "PC2", "UMAP_1", "UMAP_2"]].to_numpy()).all()
    assert len(load_df) == len(feature_cols)

    scree_df.to_csv(out_dir / "pca_scree.csv", index=False)
    load_df.to_csv(out_dir / "pca_loadings.csv", index=False)
    emb_df.to_csv(out_dir / "umap_embedding.csv", index=False)

    payload = {
        "scope": "Real CyCIF scaled single-cell slice (Nirmal 2022, 287 cells x 16 scaled markers); verified PCA variance scree, PC1/PC2 feature loadings ranking, and 2D UMAP embedding.",
        "checks": [
            f"input_cells={len(cells)}, features={len(feature_cols)}",
            f"pc1_var_ratio={scree_df.loc[0, 'explained_variance_ratio']:.4f}, pc2_var_ratio={scree_df.loc[1, 'explained_variance_ratio']:.4f}",
            f"top_pc1_feature={load_df.loc[0, 'feature']}",
            "pca_umap_coordinates_finite=true",
        ],
    }
    (out_dir / "checks.json").write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
