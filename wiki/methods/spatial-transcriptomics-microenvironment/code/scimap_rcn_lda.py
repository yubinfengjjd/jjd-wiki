"""Radius-based spatial neighborhood composition, Spatial LDA motifs, and KMeans RCN clustering.

Adapted from MIT-licensed scimap (spatial_count, spatial_lda, spatial_cluster) as used in
Nirmal et al., Cancer Discovery 2022 (PMC9167783).
"""
from __future__ import annotations

import numpy as np
import pandas as pd
from sklearn.cluster import KMeans
from sklearn.decomposition import LatentDirichletAllocation
from sklearn.neighbors import BallTree


def run_scimap_rcn_spatial_lda(
    cells_df: pd.DataFrame,
    *,
    x_col: str = "X_um",
    y_col: str = "Y_um",
    phenotype_col: str = "phenotype_abbrev",
    fov_col: str = "fov_id",
    cell_id_col: str = "cell_uid",
    radius: float = 20.0,
    num_motifs: int = 6,
    n_clusters: int = 6,
    random_state: int = 42,
) -> dict[str, pd.DataFrame]:
    """Compute radius neighborhood counts, Spatial LDA motif weights, and KMeans RCN labels."""
    required = {x_col, y_col, phenotype_col, fov_col}
    missing = required - set(cells_df.columns)
    if missing:
        raise ValueError(f"Missing required columns: {sorted(missing)}")

    df = cells_df.reset_index(drop=True).copy()
    if cell_id_col not in df.columns:
        df[cell_id_col] = [f"cell_{i}" for i in range(len(df))]

    cell_types = sorted(df[phenotype_col].astype(str).unique().tolist())
    t_idx = {ct: i for i, ct in enumerate(cell_types)}
    n_cells = len(df)
    n_types = len(cell_types)

    count_mat = np.zeros((n_cells, n_types), dtype=np.int64)
    freq_mat = np.zeros((n_cells, n_types), dtype=float)

    for _, grp in df.groupby(fov_col, sort=False):
        idx = grp.index.to_numpy()
        coords = grp[[x_col, y_col]].to_numpy(dtype=float)
        phenos = grp[phenotype_col].astype(str).to_numpy()
        tree = BallTree(coords, metric="euclidean")
        neighbors = tree.query_radius(coords, r=float(radius), return_distance=False)
        for local_i, nbrs in enumerate(neighbors):
            g_i = idx[local_i]
            for j in nbrs:
                count_mat[g_i, t_idx[phenos[j]]] += 1
            nbrs_no_self = nbrs[nbrs != local_i]
            if len(nbrs_no_self) > 0:
                for j in nbrs_no_self:
                    freq_mat[g_i, t_idx[phenos[j]]] += 1.0
                freq_mat[g_i] /= float(len(nbrs_no_self))

    n_motifs_eff = max(2, min(int(num_motifs), n_types, n_cells))
    lda = LatentDirichletAllocation(n_components=n_motifs_eff, random_state=int(random_state))
    motif_weights = lda.fit_transform(count_mat)
    motif_cols = [f"Motif_{i + 1}" for i in range(n_motifs_eff)]

    n_clust_eff = max(2, min(int(n_clusters), n_cells))
    km = KMeans(n_clusters=n_clust_eff, random_state=int(random_state), n_init=10)
    raw_labels = km.fit_predict(motif_weights)

    # Order clusters deterministically by descending size
    counts_order = pd.Series(raw_labels).value_counts().index.tolist()
    label_map = {old: f"RCN{i + 1}" for i, old in enumerate(counts_order)}
    rcn_labels = pd.Series(raw_labels).map(label_map).to_numpy()

    assignments = pd.DataFrame({
        cell_id_col: df[cell_id_col].values,
        fov_col: df[fov_col].values,
        x_col: df[x_col].values,
        y_col: df[y_col].values,
        phenotype_col: df[phenotype_col].astype(str).values,
        "RCN": rcn_labels,
    })

    motif_df = pd.DataFrame(motif_weights, columns=motif_cols)
    motif_df.insert(0, cell_id_col, df[cell_id_col].values)

    spatial_count_df = pd.DataFrame(freq_mat, columns=cell_types)
    spatial_count_df.insert(0, cell_id_col, df[cell_id_col].values)

    composition = (
        pd.crosstab(assignments["RCN"], assignments[phenotype_col], normalize="index")
        .reset_index()
    )

    topic_prob = lda.components_ / np.maximum(lda.components_.sum(axis=1, keepdims=True), 1e-12)
    motif_profiles = pd.DataFrame(topic_prob.T, columns=motif_cols)
    motif_profiles.insert(0, phenotype_col, cell_types)

    return {
        "assignments": assignments,
        "composition": composition,
        "motif_weights": motif_df,
        "motif_profiles": motif_profiles,
        "spatial_count": spatial_count_df,
    }
