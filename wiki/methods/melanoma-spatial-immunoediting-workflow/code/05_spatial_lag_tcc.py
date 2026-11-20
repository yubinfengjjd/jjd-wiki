#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Step 05: 20 um distance-weighted spatial lag (spatial_expression),
KMeans (k=20) -> 10 Tumor Cell Communities TCC1-TCC10 (Fig 5C-F),
2D spatial expression contour grids (Fig 5B, S5B), and 1,000-permutation
TCC x Immune/Stroma co-occurrence matrix (Fig S5C).
Algorithms extracted from MIT-licensed upstream_repo/scimap.
"""

import os
import gc
import json
import time
from pathlib import Path

import anndata as ad
import numpy as np
import pandas as pd
from scipy import stats
from scipy.cluster.hierarchy import fcluster, linkage
from scipy.spatial import Voronoi
from scipy.spatial.distance import pdist
from shapely.geometry import MultiPoint, Point, Polygon
from sklearn.cluster import KMeans
from sklearn.neighbors import BallTree
from sklearn.preprocessing import StandardScaler

SEED = 42
ROOT = Path(os.environ.get("PAPER_ROOT", "."))
IN_STEP03 = ROOT / "runs" / "step03_rcn_lda"
OUT_DIR = ROOT / "runs" / "step05_tcc_spatial_lag"
OUT_DIR.mkdir(parents=True, exist_ok=True)


def spatial_expression_scimap(adata_tumor: ad.AnnData, radius: float = 20.0, imageid: str = "fov_id") -> pd.DataFrame:
    """
    Extracted from scimap/tools/spatial_expression.py:
    Computes 20 um inverse-distance-normalized weighted neighborhood expression lag
    on 0-1 rescaled adata.X within each FOV (prevents raw stain-intensity outliers).
    """
    markers = list(adata_tumor.var.index)
    expr_df = pd.DataFrame(adata_tumor.X, columns=markers, index=adata_tumor.obs.index)
    parts = []
    for fov in adata_tumor.obs[imageid].unique():
        sub = adata_tumor[adata_tumor.obs[imageid] == fov]
        coords = sub.obs[["X_um", "Y_um"]].to_numpy()
        kdt = BallTree(coords, metric="euclidean")
        ind, dist = kdt.query_radius(coords, r=radius, return_distance=True)

        n = len(sub)
        W = np.zeros((n, n), dtype=float)
        for row, (cols, vals) in enumerate(zip(ind, dist)):
            mask = cols != row
            cols = cols[mask]
            vals = vals[mask]
            if len(vals) == 0:
                W[row, row] = 1.0  # self-fallback for isolated border cell
            elif len(vals) == 1:
                W[row, cols[0]] = 1.0
            else:
                span = vals.max() - vals.min()
                if span > 1e-9:
                    w = (vals.max() - vals) / span
                else:
                    w = np.ones_like(vals)
                w_sum = w.sum()
                w = w / w_sum if w_sum > 0 else np.ones_like(vals) / len(vals)
                W[row, cols] = w

        sub_expr = expr_df.loc[sub.obs.index].to_numpy()
        lag_mat = W @ sub_expr
        parts.append(pd.DataFrame(lag_mat, index=sub.obs.index, columns=markers))
    return pd.concat(parts, axis=0).reindex(adata_tumor.obs.index).fillna(0.0)


def voronoi_finite_polygons_2d(vor: Voronoi, radius: float | None = None):
    if vor.points.shape[1] != 2:
        raise ValueError("Requires 2D input")
    new_regions = []
    new_vertices = vor.vertices.tolist()
    center = vor.points.mean(axis=0)
    if radius is None:
        radius = np.ptp(vor.points, axis=0).max() * 2.0
    all_ridges = {}
    for (p1, p2), (v1, v2) in zip(vor.ridge_points, vor.ridge_vertices):
        all_ridges.setdefault(p1, []).append((p2, v1, v2))
        all_ridges.setdefault(p2, []).append((p1, v1, v2))
    for p1, region in enumerate(vor.point_region):
        vertices = vor.regions[region]
        if all(v >= 0 for v in vertices):
            new_regions.append(vertices)
            continue
        ridges = all_ridges.get(p1, [])
        new_region = [v for v in vertices if v >= 0]
        for p2, v1, v2 in ridges:
            if v2 < 0:
                v1, v2 = v2, v1
            if v1 >= 0:
                continue
            t = vor.points[p2] - vor.points[p1]
            t /= np.linalg.norm(t)
            n = np.array([-t[1], t[0]])
            midpoint = vor.points[[p1, p2]].mean(axis=0)
            direction = np.sign(np.dot(midpoint - center, n)) * n
            far_point = vor.vertices[v2] + direction * radius
            new_region.append(len(new_vertices))
            new_vertices.append(far_point.tolist())
        vs = np.asarray([new_vertices[v] for v in new_region])
        c = vs.mean(axis=0)
        angles = np.arctan2(vs[:, 1] - c[1], vs[:, 0] - c[0])
        new_region = np.array(new_region)[np.argsort(angles)]
        new_regions.append(new_region.tolist())
    return new_regions, np.asarray(new_vertices)


def compute_spatial_contours(adata_tumor: ad.AnnData, fov_id: str, markers: list[str], grid_n: int = 40) -> pd.DataFrame:
    """Compute Gaussian kernel-smoothed 2D spatial expression grid for Fig 5B / S5B."""
    sub = adata_tumor[adata_tumor.obs["fov_id"] == fov_id]
    if sub.n_obs < 10:
        return pd.DataFrame()
    pts = sub.obs[["X_um", "Y_um"]].to_numpy()
    scaled_df = pd.DataFrame(sub.X, columns=sub.var.index, index=sub.obs.index)
    markers = [m for m in markers if m in scaled_df.columns]
    vals = scaled_df[markers].to_numpy()

    gx = np.linspace(pts[:, 0].min(), pts[:, 0].max(), grid_n)
    gy = np.linspace(pts[:, 1].min(), pts[:, 1].max(), grid_n)
    XX, YY = np.meshgrid(gx, gy)
    grid_pts = np.column_stack([XX.ravel(), YY.ravel()])

    # Gaussian bandwidth = 25 um
    bw = 25.0
    d2 = ((grid_pts[:, None, :] - pts[None, :, :]) ** 2).sum(axis=2)
    W = np.exp(-0.5 * d2 / (bw ** 2))
    W_sum = np.maximum(W.sum(axis=1, keepdims=True), 1e-12)
    interp = (W @ vals) / W_sum

    out = pd.DataFrame({"fov_id": fov_id, "X_um": grid_pts[:, 0], "Y_um": grid_pts[:, 1]})
    for j, m in enumerate(markers):
        out[m] = interp[:, j]
    return out


def compute_tcc_cooccurrence(adata_all: ad.AnnData, tcc_series: pd.Series, radius: float = 20.0, n_perm: int = 1000) -> pd.DataFrame:
    """1,000-permutation co-occurrence between TCC1-10 and immune/stromal phenotypes (Fig S5C)."""
    rng = np.random.default_rng(SEED)
    labels = adata_all.obs["phenotype_abbrev"].astype(str).copy()
    labels.loc[tcc_series.index] = tcc_series.values

    sub = adata_all[adata_all.obs["fov_id"].isin(["MEL09_FOV_IM", "MEL09_FOV_MIS"])].copy()
    sub_labels = labels.loc[sub.obs.index].to_numpy()
    coords = sub.obs[["X_um", "Y_um"]].to_numpy()

    uniq_p = sorted(np.unique(sub_labels))
    p_to_i = {p: i for i, p in enumerate(uniq_p)}
    n_p = len(uniq_p)

    kdt = BallTree(coords, metric="euclidean")
    ind = kdt.query_radius(coords, r=radius, return_distance=False)
    src_list, dst_list = [], []
    for i, nbrs in enumerate(ind):
        nbrs = nbrs[nbrs != i]
        if len(nbrs) == 0:
            continue
        src_list.extend([p_to_i[sub_labels[i]]] * len(nbrs))
        dst_list.extend([p_to_i[sub_labels[j]] for j in nbrs])

    src_arr = np.asarray(src_list, dtype=np.int32)
    dst_arr = np.asarray(dst_list, dtype=np.int32)
    obs_mat = np.bincount(src_arr * n_p + dst_arr, minlength=n_p * n_p).reshape(n_p, n_p).astype(float)

    perm_sum = np.zeros((n_p, n_p), dtype=float)
    perm_sq = np.zeros((n_p, n_p), dtype=float)
    for _ in range(n_perm):
        shuf = rng.permutation(dst_arr)
        pm = np.bincount(src_arr * n_p + shuf, minlength=n_p * n_p).reshape(n_p, n_p).astype(float)
        perm_sum += pm
        perm_sq += pm * pm

    mean_mat = perm_sum / n_perm
    std_mat = np.sqrt(np.maximum(perm_sq / n_perm - mean_mat * mean_mat, 0.0))
    with np.errstate(divide="ignore", invalid="ignore"):
        z_mat = np.where(std_mat > 0, (obs_mat - mean_mat) / std_mat, 0.0)
    p_mat = stats.norm.sf(np.abs(z_mat)) * 2.0

    tcc_names = [f"TCC{i}" for i in range(1, 11)]
    rows = []
    for i, p1 in enumerate(uniq_p):
        if p1 not in tcc_names:
            continue
        for j, p2 in enumerate(uniq_p):
            state = "Co-occurrence" if (p_mat[i, j] < 0.05 and z_mat[i, j] > 0) else ("Avoidance" if (p_mat[i, j] < 0.05 and z_mat[i, j] < 0) else "Non-Sig")
            rows.append({
                "TCC": p1,
                "neighbour": p2,
                "obs_count": int(obs_mat[i, j]),
                "perm_mean": round(float(mean_mat[i, j]), 3),
                "z_score": round(float(z_mat[i, j]), 4),
                "p_value": float(p_mat[i, j]),
                "sig_state": state,
            })
    return pd.DataFrame(rows)


def main() -> None:
    t0 = time.time()
    adata_all = ad.read_h5ad(IN_STEP03 / "fov_with_rcn.h5ad")

    # Select Melanocytic/Tumor cells (SOX10+ / Mel)
    scaled_all = pd.DataFrame(adata_all.X, columns=adata_all.var.index, index=adata_all.obs.index)
    tumor_mask = (adata_all.obs["phenotype_abbrev"] == "Mel") | (scaled_all["SOX10"] >= 0.5)
    adata_tumor = adata_all[tumor_mask].copy()
    print(f"[step05] Selected {adata_tumor.n_obs} tumor/melanocytic cells across FOVs.")

    print("[step05] Computing 20 um spatial_expression lag matrix...")
    lag_df = spatial_expression_scimap(adata_tumor, radius=20.0)
    lag_df.to_csv(OUT_DIR / "tumor_spatial_lag_20um.csv")

    # Cluster 0-1 rescaled spatial lag matrix via KMeans(k=20) (matching scimap spatial_cluster)
    # and Ward hierarchical merge into 10 meta-clusters TCC1-TCC10
    lag_mat = lag_df.to_numpy()
    km20 = KMeans(n_clusters=20, random_state=SEED, n_init=10).fit(lag_mat)
    c20 = pd.Series(km20.labels_, index=adata_tumor.obs.index)
    lag_means_20 = pd.DataFrame(lag_mat, index=adata_tumor.obs.index, columns=lag_df.columns).groupby(c20).mean()
    Z = linkage(pdist(lag_means_20.to_numpy(), metric="euclidean"), method="ward")
    meta10 = fcluster(Z, t=10, criterion="maxclust")
    c20_to_meta = {c: int(m) for c, m in zip(lag_means_20.index, meta10)}
    raw_tcc = c20.map(c20_to_meta)

    # Order TCC1..TCC10 by IM prevalence / proliferation-differentiation gradient
    im_share = raw_tcc.groupby(raw_tcc).apply(lambda s: (adata_tumor.obs.loc[s.index, "Stage"] == "IM").mean())
    ordered_ids = im_share.sort_values(ascending=False).index.tolist()
    id_to_tcc = {m: f"TCC{i + 1}" for i, m in enumerate(ordered_ids)}
    tcc_series = raw_tcc.map(id_to_tcc)
    adata_tumor.obs["TCC"] = tcc_series.astype(str)

    # Fig 5C: Protein expression (scaled & z-scored) + Morphology features + Stage proportions per TCC
    scaled_tumor = pd.DataFrame(adata_tumor.X, columns=adata_tumor.var.index, index=adata_tumor.obs.index)
    morph_cols = ["Area", "Solidity", "Extent", "Eccentricity"]
    morph_z = pd.DataFrame(
        StandardScaler().fit_transform(adata_tumor.obs[morph_cols].to_numpy()),
        columns=morph_cols,
        index=adata_tumor.obs.index,
    )
    feat_combined = pd.concat([scaled_tumor, morph_z], axis=1)
    tcc_heatmap = feat_combined.groupby(adata_tumor.obs["TCC"]).median()
    tcc_heatmap = tcc_heatmap.reindex([f"TCC{i}" for i in range(1, 11)])
    tcc_heatmap.to_csv(OUT_DIR / "fig5c_tcc_protein_morph_heatmap.csv")

    tcc_stage_prop = pd.crosstab(adata_tumor.obs["TCC"], adata_tumor.obs["Stage"], normalize="index")
    tcc_stage_prop = tcc_stage_prop.reindex([f"TCC{i}" for i in range(1, 11)])
    tcc_stage_prop.to_csv(OUT_DIR / "fig5c_tcc_stage_proportions.csv")

    # Fig 5D: Spatial map of all tumor cells with TCC1-10
    adata_tumor.obs[["X_um", "Y_um", "fov_id", "Stage", "RCN", "TCC"]].to_csv(
        OUT_DIR / "fig5d_tcc_spatial_map.csv", index_label="cell_uid"
    )

    # Fig 5E-inset: Clipped Voronoi polygons for TCCs in MEL09_FOV_IM
    im_tumor = adata_tumor[adata_tumor.obs["fov_id"] == "MEL09_FOV_IM"]
    pts = im_tumor.obs[["X_um", "Y_um"]].to_numpy(copy=True)
    pts[:, 1] = pts[:, 1].max() - pts[:, 1]
    vor = Voronoi(pts)
    regions, vertices = voronoi_finite_polygons_2d(vor)
    hull = MultiPoint([Point(p) for p in pts]).convex_hull
    vor_tcc = []
    for i, reg in enumerate(regions):
        poly_pts = vertices[reg]
        if len(poly_pts) < 3:
            continue
        p = Polygon(poly_pts).intersection(hull)
        if p.is_empty or p.area <= 0:
            continue
        if p.geom_type == "MultiPolygon":
            p = max(p.geoms, key=lambda g: g.area)
        if p.geom_type != "Polygon":
            continue
        coords = [[round(float(x), 2), round(float(y), 2)] for x, y in list(p.exterior.coords)[:-1]]
        vor_tcc.append({
            "cell_uid": im_tumor.obs.index[i],
            "TCC": str(im_tumor.obs["TCC"].iloc[i]),
            "x_um": round(float(pts[i, 0]), 2),
            "y_um_flipped": round(float(pts[i, 1]), 2),
            "polygon": coords,
        })
    with open(OUT_DIR / "fig5e_tcc_voronoi_im.json", "w", encoding="utf-8") as f:
        json.dump(vor_tcc, f)

    # Fig 5F: Marker positivity (%) within each TCC1-10
    pos_markers = [m for m in ["SOX10", "MART1", "S100a", "CCND1", "HLADPB1", "MYC", "pERK", "pS6"] if m in scaled_tumor.columns]
    pos_df = (scaled_tumor[pos_markers] >= 0.5).astype(float) * 100.0
    pos_by_tcc = pos_df.groupby(adata_tumor.obs["TCC"]).mean().reindex([f"TCC{i}" for i in range(1, 11)])
    pos_by_tcc.to_csv(OUT_DIR / "fig5f_tcc_marker_positivity.csv")

    # Fig 5B & S5B: 2D spatial contour grids for IM and MIS
    contour_markers = ["SOX10", "MART1", "S100a", "CCND1", "HLADPB1"]
    c_im = compute_spatial_contours(adata_tumor, "MEL09_FOV_IM", contour_markers)
    c_mis = compute_spatial_contours(adata_tumor, "MEL09_FOV_MIS", contour_markers)
    pd.concat([c_im, c_mis], ignore_index=True).to_csv(OUT_DIR / "fig5b_s5b_spatial_contours_proxy.csv", index=False)

    # Fig S5C: 1,000-permutation TCC x Immune/Stroma spatial co-occurrence
    print("[step05] Running 1,000-permutation TCC co-occurrence (Fig S5C)...")
    tcc_co = compute_tcc_cooccurrence(adata_all, tcc_series, radius=20.0, n_perm=1000)
    tcc_co.to_csv(OUT_DIR / "figs5c_tcc_cooccurrence.csv", index=False)

    adata_tumor.write_h5ad(OUT_DIR / "tumor_with_tcc.h5ad")

    summary = {
        "step": "05_spatial_lag_tcc",
        "n_tumor_cells": int(adata_tumor.n_obs),
        "tcc_counts": adata_tumor.obs["TCC"].value_counts().to_dict(),
        "covered_panels": {
            "Fig 5C / 5D / 5E / 5F / S5C": "local_recompute (20 um spatial lag -> KMeans20 -> TCC1-10 on Panel 2 tumor cells)",
            "Fig 5B / S5B": "proxy (2D spatial expression contours for MART1/SOX10/S100a/CCND1; S100B/MITF are Panel 1-exclusive)",
        },
        "elapsed_sec": round(time.time() - t0, 2),
    }
    with open(OUT_DIR / "step05_summary.json", "w", encoding="utf-8") as f:
        json.dump(summary, f, indent=2, ensure_ascii=False)

    del adata_all, adata_tumor
    gc.collect()
    print(f"[step05] Done in {summary['elapsed_sec']}s -> {OUT_DIR}")


if __name__ == "__main__":
    main()
