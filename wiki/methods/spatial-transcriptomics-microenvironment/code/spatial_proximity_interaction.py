"""Spatial nearest-neighbor physical distance and node-label permutation co-occurrence/avoidance test.

Adapted from MIT-licensed scimap (spatial_distance, spatial_interaction) as used in
Nirmal et al., Cancer Discovery 2022 (PMC9167783).
"""
from __future__ import annotations

import numpy as np
import pandas as pd
from sklearn.neighbors import BallTree


def _bh_adjust(pvals: np.ndarray) -> np.ndarray:
    n = len(pvals)
    if n == 0:
        return np.array([], dtype=float)
    out = np.full(n, np.nan, dtype=float)
    valid = np.isfinite(pvals)
    if not valid.any():
        return out
    pv = pvals[valid]
    m = len(pv)
    order = np.argsort(pv)
    ranked = pv[order]
    adj = ranked * m / np.arange(1, m + 1, dtype=float)
    adj = np.minimum.accumulate(adj[::-1])[::-1]
    adj = np.clip(adj, 0.0, 1.0)
    res = np.empty(m, dtype=float)
    res[order] = adj
    out[valid] = res
    return out


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
    """Compute pairwise spatial node-label permutation co-occurrence/avoidance and nearest-neighbor distances."""
    required = {x_col, y_col, phenotype_col, fov_col}
    missing = required - set(cells_df.columns)
    if missing:
        raise ValueError(f"Missing required columns: {sorted(missing)}")
    if int(n_perm) < 1:
        raise ValueError("n_perm must be >= 1")

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
        pheno_idx = np.asarray([p_to_i[p] for p in phenos], dtype=np.int32)

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

        # 2. Fixed spatial graph with node-level phenotype label permutation within each FOV
        kdt = BallTree(coords, metric="euclidean")
        ind = kdt.query_radius(coords, r=float(radius), return_distance=False)
        edge_u_list: list[int] = []
        edge_v_list: list[int] = []
        for i, nbrs in enumerate(ind):
            nbrs = nbrs[nbrs != i]
            if len(nbrs) == 0:
                continue
            edge_u_list.extend([i] * len(nbrs))
            edge_v_list.extend(nbrs.tolist())
        if not edge_u_list:
            continue

        edge_u = np.asarray(edge_u_list, dtype=np.int32)
        edge_v = np.asarray(edge_v_list, dtype=np.int32)

        obs_src = pheno_idx[edge_u]
        obs_dst = pheno_idx[edge_v]
        obs_mat = np.bincount(obs_src * n_p + obs_dst, minlength=n_p * n_p).reshape(n_p, n_p).astype(float)

        n_perm_int = int(n_perm)
        perm_mats = np.empty((n_perm_int, n_p, n_p), dtype=float)
        for k in range(n_perm_int):
            perm_pheno = rng.permutation(pheno_idx)
            p_src = perm_pheno[edge_u]
            p_dst = perm_pheno[edge_v]
            perm_mats[k] = np.bincount(p_src * n_p + p_dst, minlength=n_p * n_p).reshape(n_p, n_p)

        mean_mat = perm_mats.mean(axis=0)
        std_mat = perm_mats.std(axis=0)
        with np.errstate(divide="ignore", invalid="ignore"):
            z_mat = np.where(std_mat > 0, (obs_mat - mean_mat) / std_mat, 0.0)

        abs_obs_dev = np.abs(obs_mat - mean_mat)
        abs_perm_dev = np.abs(perm_mats - mean_mat[None, :, :])
        extreme_count = np.sum(abs_perm_dev >= (abs_obs_dev[None, :, :] - 1e-12), axis=0)
        p_emp_mat = (1.0 + extreme_count) / (float(n_perm_int) + 1.0)
        padj_mat = _bh_adjust(p_emp_mat.ravel()).reshape(n_p, n_p)

        for i, p1 in enumerate(uniq_p):
            for j, p2 in enumerate(uniq_p):
                z_val = float(z_mat[i, j])
                p_emp = float(p_emp_mat[i, j])
                padj_bh = float(padj_mat[i, j])
                if padj_bh < alpha and z_val > 0:
                    state = "Co-occurrence"
                elif padj_bh < alpha and z_val < 0:
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
                    "p_emp": p_emp,
                    "padj_bh": padj_bh,
                    "sig_state": state,
                })

    return {
        "interactions": pd.DataFrame(interaction_rows),
        "distances": pd.DataFrame(distance_rows),
    }
