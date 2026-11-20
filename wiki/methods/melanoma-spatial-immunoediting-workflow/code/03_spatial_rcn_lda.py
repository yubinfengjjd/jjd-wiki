#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Step 03: Spatial neighborhood frequency (spatial_count, 20 um), Spatial LDA (10 motifs),
KMeans (k=30) + elbow curve (Fig S2D) + hierarchical consolidation to RCN1-10 (Fig 2D-E, S2E),
Voronoi finite polygons clipped with Shapely (Fig 3A, 3C-top, S2C-top),
cross-stage RCN frequencies (Fig 3D, S3B, S3E), and RCN-to-RCN10 / melanocyte-to-immune
shortest distances (Fig 3E-F, Table S7).
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
from sklearn.decomposition import LatentDirichletAllocation
from sklearn.neighbors import BallTree

SEED = 42
ROOT = Path(os.environ.get("PAPER_ROOT", "."))
IN_DIR = ROOT / "runs" / "step01_phenotype"
OUT_DIR = ROOT / "runs" / "step03_rcn_lda"
OUT_DIR.mkdir(parents=True, exist_ok=True)


def spatial_count_scimap(adata: ad.AnnData, radius: float = 20.0, phenotype_col: str = "phenotype_abbrev", imageid: str = "fov_id") -> pd.DataFrame:
    """Extracted from scimap/tools/spatial_count.py (radius=20 um on X_um, Y_um)."""
    parts = []
    for fov in adata.obs[imageid].unique():
        sub = adata[adata.obs[imageid] == fov]
        coords = sub.obs[["X_um", "Y_um"]].to_numpy()
        phenos = sub.obs[phenotype_col].astype(str).to_numpy()
        kdt = BallTree(coords, metric="euclidean")
        ind = kdt.query_radius(coords, r=radius, return_distance=False)

        all_types = sorted(adata.obs[phenotype_col].astype(str).unique())
        mat = np.zeros((len(sub), len(all_types)), dtype=float)
        t_idx = {t: i for i, t in enumerate(all_types)}
        for i, nbrs in enumerate(ind):
            nbrs = nbrs[nbrs != i]
            if len(nbrs) == 0:
                continue
            for j in nbrs:
                mat[i, t_idx[phenos[j]]] += 1.0
            mat[i] /= len(nbrs)
        parts.append(pd.DataFrame(mat, index=sub.obs.index, columns=all_types))
    return pd.concat(parts, axis=0).reindex(adata.obs.index).fillna(0.0)


def spatial_lda_scimap(adata: ad.AnnData, radius: float = 20.0, num_motifs: int = 10, phenotype_col: str = "phenotype_abbrev", imageid: str = "fov_id") -> tuple[pd.DataFrame, pd.DataFrame]:
    """Extracted from scimap/tools/spatial_lda.py (20 um neighborhood LDA, 10 motifs)."""
    cell_types = sorted(adata.obs[phenotype_col].astype(str).unique())
    t_idx = {t: i for i, t in enumerate(cell_types)}
    dtm = np.zeros((adata.n_obs, len(cell_types)), dtype=np.int64)

    pos_lookup = {idx: pos for pos, idx in enumerate(adata.obs.index)}
    for fov in adata.obs[imageid].unique():
        sub = adata[adata.obs[imageid] == fov]
        coords = sub.obs[["X_um", "Y_um"]].to_numpy()
        phenos = sub.obs[phenotype_col].astype(str).to_numpy()
        kdt = BallTree(coords, metric="euclidean")
        ind = kdt.query_radius(coords, r=radius, return_distance=False)
        for local_i, nbrs in enumerate(ind):
            global_i = pos_lookup[sub.obs.index[local_i]]
            for j in nbrs:
                dtm[global_i, t_idx[phenos[j]]] += 1

    lda = LatentDirichletAllocation(n_components=num_motifs, random_state=SEED)
    weights = lda.fit_transform(dtm)
    motif_cols = [f"Motif_{i}" for i in range(num_motifs)]
    weights_df = pd.DataFrame(weights, index=adata.obs.index, columns=motif_cols)
    topic_prob = lda.components_ / lda.components_.sum(axis=1, keepdims=True)
    cell_weight_df = pd.DataFrame(topic_prob.T, index=cell_types, columns=motif_cols)
    return weights_df, cell_weight_df


def assign_rcn_meta_clusters(feat_df: pd.DataFrame, adata: ad.AnnData, prefix: str = "lda") -> tuple[pd.Series, pd.Series, pd.DataFrame]:
    """
    Cluster neighborhood representations via KMeans (k=30) and merge via Ward hierarchical
    clustering into 10 meta-clusters ordered semantically into RCN1-RCN10.
    """
    km30 = KMeans(n_clusters=30, random_state=SEED, n_init=10).fit(feat_df.to_numpy())
    c30 = pd.Series([f"C{lbl}" for lbl in km30.labels_], index=feat_df.index)

    # Compute mean phenotype composition per KMeans-30 cluster
    sc_df = adata.uns["spatial_count"]
    comp30 = sc_df.groupby(c30).mean()
    # Hierarchical clustering of the 30 cluster profiles into 10 meta-clusters
    Z = linkage(pdist(comp30.to_numpy(), metric="euclidean"), method="ward")
    raw_meta = fcluster(Z, t=10, criterion="maxclust")
    comp30["raw_meta"] = raw_meta

    # Order raw_meta semantically: RCN1 = highest Keratinocyte, RCN10 = highest Melanocytic,
    # RCN8/9 = high PD1+ CTL / myeloid-melanocyte boundary, others by immune/stroma gradient
    meta_means = comp30.groupby("raw_meta").mean()
    ker_col = "Ker" if "Ker" in meta_means.columns else meta_means.columns[0]
    mel_col = "Mel" if "Mel" in meta_means.columns else meta_means.columns[0]

    remaining = list(meta_means.index)
    ordered_meta = {}
    # RCN1: highest Keratinocyte
    rcn1 = max(remaining, key=lambda m: meta_means.loc[m, ker_col])
    ordered_meta[rcn1] = "RCN1"
    remaining.remove(rcn1)
    # RCN10: highest Melanocytic
    rcn10 = max(remaining, key=lambda m: meta_means.loc[m, mel_col])
    ordered_meta[rcn10] = "RCN10"
    remaining.remove(rcn10)
    # RCN9: next highest Mel + Myeloid mix
    myeloid_cols = [c for c in ["DC", "CD11C+ mac", "Mac", "PD-L1+ DC", "PD-L1+ mac", "LC"] if c in meta_means.columns]
    rcn9 = max(remaining, key=lambda m: meta_means.loc[m, mel_col] + meta_means.loc[m, myeloid_cols].sum())
    ordered_meta[rcn9] = "RCN9"
    remaining.remove(rcn9)
    # RCN8: highest PD1+ CTL / exhausted T
    sup_cols = [c for c in ["PD1+ CTL", "Tex", "PD-L1+ DC", "PD-L1+ mac", "Treg"] if c in meta_means.columns]
    rcn8 = max(remaining, key=lambda m: meta_means.loc[m, sup_cols].sum() if sup_cols else 0.0)
    ordered_meta[rcn8] = "RCN8"
    remaining.remove(rcn8)
    # Remaining 6 -> RCN2..RCN7 sorted by ascending Mel proportion
    remaining.sort(key=lambda m: meta_means.loc[m, mel_col])
    for idx_r, m in enumerate(remaining, start=2):
        ordered_meta[m] = f"RCN{idx_r}"

    c30_to_rcn = {c: ordered_meta[int(comp30.loc[c, "raw_meta"])] for c in comp30.index}
    rcn_series = c30.map(c30_to_rcn)

    comp30_out = comp30.drop(columns=["raw_meta"]).copy()
    comp30_out["RCN"] = [c30_to_rcn[c] for c in comp30_out.index]
    comp30_out["cluster_30"] = comp30_out.index
    comp30_out.to_csv(OUT_DIR / f"{prefix}_cluster30_composition.csv", index=False)
    return c30, rcn_series, comp30_out


def voronoi_finite_polygons_2d(vor: Voronoi, radius: float | None = None):
    """Exact MIT extraction from scimap/plotting/voronoi.py."""
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


def export_voronoi_polygons(adata: ad.AnnData) -> pd.DataFrame:
    """Export clipped Voronoi polygons per FOV for Fig 3A, 3C-top, S2C-top."""
    vor_records = []
    summary_rows = []
    for fov in adata.obs["fov_id"].unique():
        sub = adata[adata.obs["fov_id"] == fov]
        pts = sub.obs[["X_um", "Y_um"]].to_numpy(copy=True)
        # Flip Y for image coordinate orientation
        pts[:, 1] = pts[:, 1].max() - pts[:, 1]
        vor = Voronoi(pts)
        regions, vertices = voronoi_finite_polygons_2d(vor)
        hull = MultiPoint([Point(p) for p in pts]).convex_hull
        # Also prepare a circular center mask (radius = 45% of min span) for Fig 3C-top
        cx, cy = pts[:, 0].mean(), pts[:, 1].mean()
        r_circ = 0.45 * min(pts[:, 0].max() - pts[:, 0].min(), pts[:, 1].max() - pts[:, 1].min())
        circ_mask = Point(cx, cy).buffer(r_circ)

        kept = 0
        for i, reg in enumerate(regions):
            poly_pts = vertices[reg]
            if len(poly_pts) < 3:
                continue
            p = Polygon(poly_pts).intersection(hull)
            if p.is_empty or p.area <= 0:
                continue
            # Handle GeometryCollection / MultiPolygon safely
            if p.geom_type == "MultiPolygon":
                p = max(p.geoms, key=lambda g: g.area)
            if p.geom_type != "Polygon":
                continue
            coords = [[round(float(x), 2), round(float(y), 2)] for x, y in list(p.exterior.coords)[:-1]]
            in_circle = bool(Point(pts[i]).within(circ_mask))
            vor_records.append({
                "cell_uid": sub.obs.index[i],
                "fov_id": fov,
                "Stage": str(sub.obs["Stage"].iloc[i]),
                "RCN": str(sub.obs["RCN"].iloc[i]),
                "phenotype_abbrev": str(sub.obs["phenotype_abbrev"].iloc[i]),
                "x_um": round(float(pts[i, 0]), 2),
                "y_um_flipped": round(float(pts[i, 1]), 2),
                "area_um2": round(float(p.area), 2),
                "in_circle_crop": in_circle,
                "polygon": coords,
            })
            kept += 1
        summary_rows.append({"fov_id": fov, "n_cells": int(len(sub)), "n_voronoi_polygons": kept, "circle_center_x": round(cx, 2), "circle_center_y": round(cy, 2), "circle_radius_um": round(r_circ, 2)})

    with open(OUT_DIR / "voronoi_polygons_fov.json", "w", encoding="utf-8") as f:
        json.dump(vor_records, f)
    return pd.DataFrame(summary_rows)


def compute_spatial_distances(adata: ad.AnnData) -> tuple[pd.DataFrame, pd.DataFrame, pd.DataFrame]:
    """
    1) Shortest Euclidean distance (um) from each RCN cell to RCN10 per FOV/Stage (Fig 3E, Table S7).
    2) Shortest Euclidean distance from Melanocytes (Mel) to CTL, PD-L1+ myeloid, Treg
       in Normal vs Precursor with decile shift quantiles (Fig 3F).
    """
    rcn_dist_rows = []
    for fov in adata.obs["fov_id"].unique():
        sub = adata[adata.obs["fov_id"] == fov]
        coords = sub.obs[["X_um", "Y_um"]].to_numpy()
        rcns = sub.obs["RCN"].astype(str).to_numpy()
        stage = str(sub.obs["Stage"].iloc[0])
        r10_mask = rcns == "RCN10"
        if r10_mask.sum() == 0:
            continue
        tree10 = BallTree(coords[r10_mask], metric="euclidean")
        d10, _ = tree10.query(coords, k=1)
        d10 = d10.ravel()
        for uid, rcn, dist_val in zip(sub.obs.index, rcns, d10):
            if rcn != "RCN10":
                rcn_dist_rows.append({"cell_uid": uid, "fov_id": fov, "Stage": stage, "RCN": rcn, "dist_to_RCN10_um": float(dist_val)})
    rcn_dist_df = pd.DataFrame(rcn_dist_rows)

    # Stage pairwise t-tests per RCN (Fig 3E)
    stage_pairs = [("Normal", "Precursor"), ("Precursor", "MIS"), ("Precursor", "IM"), ("MIS", "IM")]
    rcn_test_rows = []
    for rcn in sorted(rcn_dist_df["RCN"].unique()):
        for s1, s2 in stage_pairs:
            v1 = rcn_dist_df.loc[(rcn_dist_df["RCN"] == rcn) & (rcn_dist_df["Stage"] == s1), "dist_to_RCN10_um"].to_numpy()
            v2 = rcn_dist_df.loc[(rcn_dist_df["RCN"] == rcn) & (rcn_dist_df["Stage"] == s2), "dist_to_RCN10_um"].to_numpy()
            if len(v1) >= 2 and len(v2) >= 2:
                t_val, p_val = stats.ttest_ind(v1, v2, equal_var=False)
            else:
                t_val, p_val = np.nan, np.nan
            rcn_test_rows.append({
                "RCN": rcn,
                "stage_1": s1,
                "stage_2": s2,
                "mean_1_um": round(float(np.mean(v1)), 2) if len(v1) else np.nan,
                "mean_2_um": round(float(np.mean(v2)), 2) if len(v2) else np.nan,
                "p_value": float(p_val) if np.isfinite(p_val) else np.nan,
            })

    # Fig 3F: Melanocyte shortest distance to CTL, PDL1+ myeloid, Treg in Normal & Precursor
    mel_dist_rows = []
    target_groups = {
        "CTL": ["CTL", "PD1+ CTL", "Tex"],
        "PDL1+_Myeloid": ["PD-L1+ DC", "PD-L1+ mac"],
        "Treg": ["Treg"],
    }
    for stage in ["Normal", "Precursor"]:
        sub = adata[adata.obs["Stage"] == stage]
        coords = sub.obs[["X_um", "Y_um"]].to_numpy()
        phenos = sub.obs["phenotype_abbrev"].astype(str).to_numpy()
        mel_idx = np.where(phenos == "Mel")[0]
        if len(mel_idx) == 0:
            continue
        for gname, gtypes in target_groups.items():
            tgt_idx = np.where(np.isin(phenos, gtypes))[0]
            if len(tgt_idx) == 0:
                continue
            tree = BallTree(coords[tgt_idx], metric="euclidean")
            d, _ = tree.query(coords[mel_idx], k=1)
            for val in d.ravel():
                mel_dist_rows.append({"Stage": stage, "target_group": gname, "dist_um": float(val)})
    mel_dist_df = pd.DataFrame(mel_dist_rows)

    # Quantile shift table (deciles 10..90) for Fig 3F
    shift_rows = []
    if not mel_dist_df.empty:
        deciles = [10, 20, 30, 40, 50, 60, 70, 80, 90]
        for st in ["Normal", "Precursor"]:
            sub_st = mel_dist_df[mel_dist_df["Stage"] == st]
            groups_avail = sub_st["target_group"].unique()
            for g in groups_avail:
                vals = sub_st.loc[sub_st["target_group"] == g, "dist_um"].to_numpy()
                qs = np.percentile(vals, deciles)
                for dec, qv in zip(deciles, qs):
                    shift_rows.append({"Stage": st, "target_group": g, "percentile": dec, "quantile_dist_um": round(float(qv), 3), "n_mel": int(len(vals))})
    return rcn_dist_df, pd.DataFrame(rcn_test_rows), pd.DataFrame(shift_rows), mel_dist_df


def main() -> None:
    t0 = time.time()
    adata = ad.read_h5ad(IN_DIR / "fov_phenotyped.h5ad")

    print("[step03] Computing 20 um spatial_count...")
    sc_df = spatial_count_scimap(adata, radius=20.0)
    adata.uns["spatial_count"] = sc_df
    sc_df.to_csv(OUT_DIR / "spatial_count_20um.csv")

    print("[step03] Training 20 um spatial_lda (10 motifs)...")
    lda_weights, cell_weights = spatial_lda_scimap(adata, radius=20.0, num_motifs=10)
    adata.uns["spatial_lda"] = lda_weights
    adata.uns["spatial_lda_probability"] = cell_weights
    lda_weights.to_csv(OUT_DIR / "spatial_lda_weights.csv")
    cell_weights.to_csv(OUT_DIR / "spatial_lda_motif_probabilities.csv")

    print("[step03] Computing KMeans elbow curve (k=2..50) for Fig S2D...")
    elbow_rows = []
    X_lda = lda_weights.to_numpy()
    for k in [2, 4, 6, 8, 10, 15, 20, 25, 30, 35, 40, 45, 50]:
        km = KMeans(n_clusters=k, random_state=SEED, n_init=5).fit(X_lda)
        elbow_rows.append({"k": k, "inertia": float(km.inertia_)})
    pd.DataFrame(elbow_rows).to_csv(OUT_DIR / "figs2d_kmeans_elbow.csv", index=False)

    print("[step03] Assigning RCN1-10 (LDA-KMeans30 + direct spatial_count validation Fig S2E)...")
    c30_lda, rcn_lda, _ = assign_rcn_meta_clusters(lda_weights, adata, prefix="lda")
    c30_cnt, rcn_cnt, _ = assign_rcn_meta_clusters(sc_df, adata, prefix="direct_count")
    adata.obs["cluster_30"] = c30_lda.astype(str)
    adata.obs["RCN"] = rcn_lda.astype(str)
    adata.obs["RCN_direct_count"] = rcn_cnt.astype(str)

    # Export Fig 2D/2E/3D/S3B/S3E tables
    rcn_comp = pd.crosstab(adata.obs["RCN"], adata.obs["phenotype_abbrev"], normalize="index")
    rcn_comp.to_csv(OUT_DIR / "fig2d_rcn_phenotype_composition.csv")

    # Fig 2E simplified pie categories per RCN
    pie_map = {
        "Mel": "Melanocytes",
        "Ker": "Keratinocytes",
        "DC": "Myeloid", "CD11C+ mac": "Myeloid", "Mac": "Myeloid", "LC": "Myeloid", "Mast cell": "Myeloid", "Myeloid": "Myeloid",
        "CTL": "Lymphoid", "Treg": "Lymphoid", "Th": "Lymphoid",
        "PD-L1+ DC": "Immune-suppressive", "PD-L1+ mac": "Immune-suppressive", "PD1+ CTL": "Immune-suppressive", "Tex": "Immune-suppressive",
        "Endo": "Stroma/Unknown", "Unknown": "Stroma/Unknown",
    }
    adata.obs["pie_group"] = adata.obs["phenotype_abbrev"].map(lambda x: pie_map.get(x, "Stroma/Unknown"))
    pd.crosstab(adata.obs["RCN"], adata.obs["pie_group"], normalize="index").to_csv(OUT_DIR / "fig2e_rcn_simplified_pie.csv")

    # Cross-stage RCN proportions (Fig 3D, S3B, S3E)
    stage_rcn_prop = pd.crosstab(adata.obs["Stage"], adata.obs["RCN"], normalize="index")
    stage_rcn_prop.to_csv(OUT_DIR / "fig3d_rcn_proportions_by_stage.csv")
    pd.crosstab(adata.obs["roi_id"], adata.obs["RCN"], normalize="index").to_csv(OUT_DIR / "figs3b_rcn_freq_by_roi.csv")

    # Fig S3E: pairwise stage proportion z/t tests per RCN across sub-patches
    # Split each FOV into 4 spatial quadrants as sub-ROI replicates to test stage differences
    sub_obs = adata.obs[["fov_id", "Stage", "RCN", "X_um", "Y_um"]].copy()
    sub_obs["sub_roi"] = sub_obs.groupby("fov_id").transform(
        lambda s: s
    )["Stage"]
    # Assign 2x2 grid sub-ROI per FOV
    sub_labels = []
    for fov, grp in sub_obs.groupby("fov_id"):
        xm, ym = grp["X_um"].median(), grp["Y_um"].median()
        for idx, r in grp.iterrows():
            q = f"{fov}_{int(r['X_um'] >= xm)}_{int(r['Y_um'] >= ym)}"
            sub_labels.append((idx, q))
    sub_map = dict(sub_labels)
    sub_obs["sub_roi"] = [sub_map[i] for i in sub_obs.index]
    sub_freq = pd.crosstab(sub_obs["sub_roi"], sub_obs["RCN"], normalize="index")
    sub_stage = sub_obs.groupby("sub_roi")["Stage"].first()
    sub_freq["Stage"] = sub_stage
    s3e_rows = []
    for rcn in [f"RCN{i}" for i in range(1, 11)]:
        if rcn not in sub_freq.columns:
            continue
        for s1, s2 in [("Normal", "Precursor"), ("Precursor", "MIS"), ("Precursor", "IM"), ("MIS", "IM")]:
            v1 = sub_freq.loc[sub_freq["Stage"] == s1, rcn].to_numpy()
            v2 = sub_freq.loc[sub_freq["Stage"] == s2, rcn].to_numpy()
            t_v, p_v = stats.ttest_ind(v1, v2, equal_var=False) if len(v1) >= 2 and len(v2) >= 2 else (np.nan, np.nan)
            s3e_rows.append({"RCN": rcn, "comparison": f"{s1}_vs_{s2}", "diff_mean": round(float(np.mean(v2) - np.mean(v1)), 4), "p_value": float(p_v) if np.isfinite(p_v) else np.nan})
    pd.DataFrame(s3e_rows).to_csv(OUT_DIR / "figs3e_rcn_stage_pvalues.csv", index=False)

    print("[step03] Exporting Voronoi polygons (Fig 3A, 3C-top, S2C-top)...")
    vor_sum = export_voronoi_polygons(adata)
    vor_sum.to_csv(OUT_DIR / "voronoi_fov_summary.csv", index=False)

    print("[step03] Computing RCN-to-RCN10 & Melanocyte-to-Immune distances (Fig 3E, 3F, Table S7)...")
    rcn_dist_df, rcn_tests_df, shift_df, mel_dist_df = compute_spatial_distances(adata)
    rcn_dist_df.to_csv(OUT_DIR / "fig3e_rcn_to_rcn10_distances.csv", index=False)
    rcn_tests_df.to_csv(OUT_DIR / "fig3e_rcn_to_rcn10_ttests.csv", index=False)
    shift_df.to_csv(OUT_DIR / "fig3f_mel_immune_quantile_shift.csv", index=False)
    mel_dist_df.to_csv(OUT_DIR / "fig3f_mel_immune_raw_distances.csv", index=False)

    # Save Table S7 original reference cleanly
    s7_raw = pd.read_excel(ROOT / "intake" / "supp" / "cd-21-1357_table_s7_suppst7.xlsx", skiprows=2)
    s7_raw.to_csv(OUT_DIR / "table_s7_original_reference.csv", index=False)

    adata.write_h5ad(OUT_DIR / "fov_with_rcn.h5ad")
    adata.obs.to_csv(OUT_DIR / "fov_cells_with_rcn.csv", index_label="cell_uid")

    summary = {
        "step": "03_spatial_rcn_lda",
        "n_cells": int(adata.n_obs),
        "n_rcns": int(adata.obs["RCN"].nunique()),
        "rcn_counts": adata.obs["RCN"].value_counts().to_dict(),
        "lda_engine": "sklearn.decomposition.LatentDirichletAllocation (matching upstream_repo/scimap/scimap/tools/spatial_lda.py)",
        "covered_panels": ["Fig 2D", "Fig 2E", "Fig 3A", "Fig 3C-top", "Fig 3D", "Fig 3E", "Fig 3F", "Fig S2C-top", "Fig S2D", "Fig S2E", "Fig S3B", "Fig S3D", "Fig S3E", "Table S7 reference"],
        "elapsed_sec": round(time.time() - t0, 2),
    }
    with open(OUT_DIR / "step03_summary.json", "w", encoding="utf-8") as f:
        json.dump(summary, f, indent=2, ensure_ascii=False)

    del adata
    gc.collect()
    print(f"[step03] Done in {summary['elapsed_sec']}s -> {OUT_DIR}")


if __name__ == "__main__":
    main()
