"""PCA variance contribution, feature loadings ranking, and 2D UMAP embedding for CyCIF proteomics.

Adapted from MIT-licensed scimap (tools/umap.py) and Nirmal et al., Cancer Discovery 2022
(02_umap_marker_gradients.py).
"""
from __future__ import annotations

import numpy as np
import pandas as pd
import umap as umap_lib
from sklearn.decomposition import PCA


def run_cycif_pca_umap(
    cells_df: pd.DataFrame,
    feature_cols: list[str],
    *,
    cell_id_col: str = "cell_uid",
    n_pcs: int = 10,
    n_neighbors: int = 15,
    min_dist: float = 0.1,
    random_state: int = 42,
) -> dict[str, pd.DataFrame]:
    """Compute PCA scree/loadings and 2D UMAP embedding on scaled single-cell marker features."""
    missing = set(feature_cols) - set(cells_df.columns)
    if missing:
        raise ValueError(f"Missing feature columns: {sorted(missing)}")

    df = cells_df.reset_index(drop=True).copy()
    if cell_id_col not in df.columns:
        df[cell_id_col] = [f"cell_{i}" for i in range(len(df))]

    mat = df[feature_cols].to_numpy(dtype=float)
    n_pcs_eff = max(2, min(int(n_pcs), mat.shape[1], mat.shape[0] - 1))

    pca = PCA(n_components=n_pcs_eff, random_state=int(random_state))
    pcs = pca.fit_transform(mat)

    scree_df = pd.DataFrame({
        "PC": [f"PC{i + 1}" for i in range(n_pcs_eff)],
        "pc_num": np.arange(1, n_pcs_eff + 1),
        "explained_variance_ratio": np.round(pca.explained_variance_ratio_, 6),
        "cumulative_variance_ratio": np.round(np.cumsum(pca.explained_variance_ratio_), 6),
    })

    loadings_df = pd.DataFrame({
        "feature": feature_cols,
        "PC1_loading": np.round(pca.components_[0], 6),
        "PC2_loading": np.round(pca.components_[1], 6),
        "abs_PC1": np.round(np.abs(pca.components_[0]), 6),
        "abs_PC2": np.round(np.abs(pca.components_[1]), 6),
    }).sort_values("abs_PC1", ascending=False).reset_index(drop=True)

    reducer = umap_lib.UMAP(
        n_neighbors=min(int(n_neighbors), max(2, len(df) - 1)),
        n_components=2,
        metric="euclidean",
        min_dist=float(min_dist),
        random_state=int(random_state),
    )
    emb = reducer.fit_transform(mat)

    embedding_df = pd.DataFrame({
        cell_id_col: df[cell_id_col].values,
        "PC1": np.round(pcs[:, 0], 5),
        "PC2": np.round(pcs[:, 1], 5),
        "UMAP_1": np.round(emb[:, 0], 5),
        "UMAP_2": np.round(emb[:, 1], 5),
    })
    for meta_col in ("Stage", "patient_id", "phenotype_abbrev"):
        if meta_col in df.columns:
            embedding_df[meta_col] = df[meta_col].values

    return {
        "pca_scree": scree_df,
        "pca_loadings": loadings_df,
        "embedding": embedding_df,
    }
