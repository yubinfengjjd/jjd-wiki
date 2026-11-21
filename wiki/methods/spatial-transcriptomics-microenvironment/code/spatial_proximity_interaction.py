"""Spatial nearest-neighbor physical distance and permutation co-occurrence/avoidance test.

Adapted from MIT-licensed scimap (spatial_distance, spatial_interaction) as used in
Nirmal et al., Cancer Discovery 2022 (PMC9167783).
"""
from __future__ import annotations

import numpy as np
import pandas as pd
from scipy import stats
from sklearn.neighbors import BallTree


def run_spatial_proximity_interaction(
    cells_df: pd.DataFrame,
    *,
    x_col: str = "X_um",
    y_col: str = "Y_um",
    phenotype_col: str = "phenotype_abbrev",
    fov_col: str = "fov_id",
    radius: float = 20.0,
    n_perm: int = 200,
    alpha: float = 0.05,
    seed: int = 42,
) -> dict[str, pd.DataFrame]:
    """Compute pairwise spatial permutation co-occurrence/avoidance and nearest-neighbor distances."""
    required = {x_col, y_col, phenotype_col, fov_col}
    missing = required - set(cells_df.columns)
    if missing:
        raise ValueError(f"Missing required columns: {sorted(missing)}")

    rng = np.random.default_rng(int(seed))
    interaction_rows: list[dict] = []
    distance_rows: list[dict] = []

    for fov, grp in cells_df.groupby(fov_col, sort=False):
        coords = grp[[x_col, y_col]].to_numpy(dtype=float)
        phenos = grp[phenotype_col].astype(str).to_numpy()
        uniq_p = sorted(np.unique(phenos).tolist())
        n_p = len(uniq_p)
        if n_p < 2:
            continue
        p_to_i = {p: i for i, p in enumerate(uniq_p)}

        # 1. Nearest-neighbor distance summary between every ordered pair of phenotypes
        trees = {
            p: BallTree(coords[phenos == p], metric="euclidean")
            for p in uniq_p
        }
        for src_p in uniq_p:
            src_coords = coords[phenos == src_p]
            for tgt_p in uniq_p:
                if src_p == tgt_p:
                    if len(src_coords) < 2:
                        continue
                    dists, _ = trees[tgt_p].query(src_coords, k=2)
                    nn = dists[:, 1]
                else:
                    dists, _ = trees[tgt_p].query(src_coords, k=1)
                    nn = dists[:, 0]
                distance_rows.append({
                    fov_col: str(fov),
                    "source_phenotype": src_p,
                    "target_phenotype": tgt_p,
                    "n_source": int(len(nn)),
                    "median_nn_dist": round(float(np.median(nn)), 4),
                    "mean_nn_dist": round(float(np.mean(nn)), 4),
                    "q25_nn_dist": round(float(np.percentile(nn, 25)), 4),
                    "q75_nn_dist": round(float(np.percentile(nn, 75)), 4),
                })

        # 2. Radius-based neighbor pair permutation test (degree-preserving edge shuffle)
        kdt = BallTree(coords, metric="euclidean")
        ind = kdt.query_radius(coords, r=float(radius), return_distance=False)
        src_list: list[int] = []
        dst_list: list[int] = []
        for i, nbrs in enumerate(ind):
            nbrs = nbrs[nbrs != i]
            if len(nbrs) == 0:
                continue
            src_list.extend([p_to_i[phenos[i]]] * len(nbrs))
            dst_list.extend([p_to_i[phenos[j]] for j in nbrs])
        if not src_list:
            continue

        src_arr = np.asarray(src_list, dtype=np.int32)
        dst_arr = np.asarray(dst_list, dtype=np.int32)
        obs_mat = np.bincount(src_arr * n_p + dst_arr, minlength=n_p * n_p).reshape(n_p, n_p).astype(float)

        perm_sum = np.zeros((n_p, n_p), dtype=float)
        perm_sq = np.zeros((n_p, n_p), dtype=float)
        for _ in range(int(n_perm)):
            shuf_dst = rng.permutation(dst_arr)
            pm = np.bincount(src_arr * n_p + shuf_dst, minlength=n_p * n_p).reshape(n_p, n_p).astype(float)
            perm_sum += pm
            perm_sq += pm * pm

        mean_mat = perm_sum / float(n_perm)
        std_mat = np.sqrt(np.maximum(perm_sq / float(n_perm) - mean_mat * mean_mat, 0.0))
        with np.errstate(divide="ignore", invalid="ignore"):
            z_mat = np.where(std_mat > 0, (obs_mat - mean_mat) / std_mat, 0.0)
        p_mat = stats.norm.sf(np.abs(z_mat)) * 2.0

        for i, p1 in enumerate(uniq_p):
            for j, p2 in enumerate(uniq_p):
                z_val = float(z_mat[i, j])
                p_val = float(p_mat[i, j])
                if p_val < alpha and z_val > 0:
                    state = "Co-occurrence"
                elif p_val < alpha and z_val < 0:
                    state = "Avoidance"
                else:
                    state = "Non-Sig"
                interaction_rows.append({
                    fov_col: str(fov),
                    "phenotype": p1,
                    "neighbour_phenotype": p2,
                    "obs_count": int(obs_mat[i, j]),
                    "perm_mean": round(float(mean_mat[i, j]), 4),
                    "z_score": round(z_val, 4),
                    "p_value": p_val,
                    "sig_state": state,
                })

    return {
        "interactions": pd.DataFrame(interaction_rows),
        "distances": pd.DataFrame(distance_rows),
    }
