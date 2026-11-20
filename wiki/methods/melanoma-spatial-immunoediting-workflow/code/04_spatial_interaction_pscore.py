#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Step 04: 1,000-permutation cell-type spatial interaction test (20 um, Fig 4B, S5C),
proximity volume scoring (10 um, Fig S3C), spatial centroids (Fig 1E),
tumor-stroma boundary marker gradients (Fig S7D-right, Fig 7E proxy),
and compartment immune composition (Fig 7F, 7G-bars, S7I-bars, 4F Cohort 1).
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
from sklearn.neighbors import BallTree

SEED = 42
ROOT = Path(os.environ.get("PAPER_ROOT", "."))
IN_STEP01 = ROOT / "runs" / "step01_phenotype"
IN_STEP03 = ROOT / "runs" / "step03_rcn_lda"
OUT_DIR = ROOT / "runs" / "step04_spatial_interaction"
OUT_DIR.mkdir(parents=True, exist_ok=True)


def spatial_interaction_scimap(
    adata: ad.AnnData,
    radius: float = 20.0,
    n_perm: int = 1000,
    phenotype_col: str = "phenotype_abbrev",
    imageid: str = "fov_id",
    seed: int = SEED,
) -> pd.DataFrame:
    """
    Extracted from scimap/tools/spatial_interaction.py:
    For each ROI, build 20 um Euclidean neighbor pairs (excluding self),
    permute neighbor labels 1,000 times preserving degree structure,
    compute z-score = (obs - mean_perm) / std_perm and two-sided p = 2 * norm.sf(|z|).
    """
    rng = np.random.default_rng(seed)
    all_rows = []
    for img in adata.obs[imageid].unique():
        sub = adata[adata.obs[imageid] == img]
        coords = sub.obs[["X_um", "Y_um"]].to_numpy()
        phenos = sub.obs[phenotype_col].astype(str).to_numpy()
        uniq_p = sorted(np.unique(phenos))
        p_to_i = {p: i for i, p in enumerate(uniq_p)}
        n_p = len(uniq_p)
        if n_p < 2:
            continue

        kdt = BallTree(coords, metric="euclidean")
        ind = kdt.query_radius(coords, r=radius, return_distance=False)
        src_list = []
        dst_list = []
        for i, nbrs in enumerate(ind):
            nbrs = nbrs[nbrs != i]
            if len(nbrs) == 0:
                continue
            src_list.extend([p_to_i[phenos[i]]] * len(nbrs))
            dst_list.extend([p_to_i[phenos[j]] for j in nbrs])
        if len(src_list) == 0:
            continue

        src_arr = np.asarray(src_list, dtype=np.int32)
        dst_arr = np.asarray(dst_list, dtype=np.int32)

        # Observed pair counts (n_p x n_p)
        obs_mat = np.bincount(src_arr * n_p + dst_arr, minlength=n_p * n_p).reshape(n_p, n_p).astype(float)

        # 1,000 permutations (vectorized with bincount)
        perm_sum = np.zeros((n_p, n_p), dtype=float)
        perm_sq = np.zeros((n_p, n_p), dtype=float)
        for _ in range(n_perm):
            shuf_dst = rng.permutation(dst_arr)
            pm = np.bincount(src_arr * n_p + shuf_dst, minlength=n_p * n_p).reshape(n_p, n_p).astype(float)
            perm_sum += pm
            perm_sq += pm * pm

        mean_mat = perm_sum / n_perm
        var_mat = np.maximum(perm_sq / n_perm - mean_mat * mean_mat, 0.0)
        std_mat = np.sqrt(var_mat)

        with np.errstate(divide="ignore", invalid="ignore"):
            z_mat = np.where(std_mat > 0, (obs_mat - mean_mat) / std_mat, 0.0)
        p_mat = stats.norm.sf(np.abs(z_mat)) * 2.0

        # Normalize interaction score (matching scimap k_max * direction)
        counts_per_p = np.array([(phenos == p).sum() for p in uniq_p], dtype=float)
        k_norm = obs_mat / np.maximum(counts_per_p[None, :], 1.0)
        row_max = np.maximum(k_norm.max(axis=1, keepdims=True), 1e-12)
        k_scaled = k_norm / row_max
        direction = np.where(obs_mat >= mean_mat, 1.0, -1.0)
        score_mat = k_scaled * direction

        stage_val = str(sub.obs["Stage"].iloc[0])
        for i, p1 in enumerate(uniq_p):
            for j, p2 in enumerate(uniq_p):
                all_rows.append({
                    "roi_unit": img,
                    "Stage": stage_val,
                    "phenotype": p1,
                    "neighbour_phenotype": p2,
                    "obs_count": int(obs_mat[i, j]),
                    "perm_mean": round(float(mean_mat[i, j]), 3),
                    "z_score": round(float(z_mat[i, j]), 4),
                    "interaction_score": round(float(score_mat[i, j]), 4),
                    "p_value": float(p_mat[i, j]),
                    "sig_state": (
                        "Co-occurrence" if (p_mat[i, j] < 0.05 and z_mat[i, j] > 0)
                        else ("Avoidance" if (p_mat[i, j] < 0.05 and z_mat[i, j] < 0) else "Non-Sig")
                    ),
                })
    return pd.DataFrame(all_rows)


def spatial_pscore_scimap(
    adata: ad.AnnData,
    group_a: list[str],
    group_b: list[str],
    radius: float = 10.0,
    score_by: str = "Stage",
    imageid: str = "fov_id",
) -> pd.DataFrame:
    """
    Extracted from scimap/tools/spatial_pscore.py:
    Proximity Volume = (# cells in 10 um neighborhoods containing both group_a and group_b) / total cells.
    Proximity Density = (# group_a/group_b cells in proximity) / total group_a+group_b cells.
    """
    prox_cells = set()
    for img in adata.obs[imageid].unique():
        sub = adata[adata.obs[imageid] == img]
        coords = sub.obs[["X_um", "Y_um"]].to_numpy()
        phenos = sub.obs["phenotype_abbrev"].astype(str).to_numpy()
        kdt = BallTree(coords, metric="euclidean")
        ind = kdt.query_radius(coords, r=radius, return_distance=False)
        in_a = np.isin(phenos, group_a)
        in_b = np.isin(phenos, group_b)
        for i, nbrs in enumerate(ind):
            if in_a[nbrs].any() and in_b[nbrs].any():
                prox_cells.add(sub.obs.index[i])

    df = adata.obs[[score_by, "phenotype_abbrev"]].copy()
    df["in_prox"] = df.index.isin(prox_cells)
    df["is_coi"] = df["phenotype_abbrev"].astype(str).isin(group_a + group_b)

    rows = []
    for grp, gdf in df.groupby(score_by, observed=True):
        n_total = len(gdf)
        n_prox = int(gdf["in_prox"].sum())
        coi_df = gdf[gdf["is_coi"]]
        n_coi = len(coi_df)
        n_coi_prox = int(coi_df["in_prox"].sum())
        rows.append({
            score_by: grp,
            "n_total_cells": n_total,
            "n_proximity_neighborhoods": n_prox,
            "proximity_volume": round(n_prox / max(n_total, 1), 5),
            "n_coi_cells": n_coi,
            "proximity_density": round(n_coi_prox / max(n_coi, 1), 5),
        })
    return pd.DataFrame(rows)


def compute_boundary_gradient(adata: ad.AnnData) -> pd.DataFrame:
    """
    Compute tumor-stroma boundary intensity gradient in MEL09_FOV_IM (Fig S7D-right, Fig 7E proxy).
    Defines tumor core cells as RCN10 (or Mel) and stroma as non-Mel outside RCN10;
    signed distance: negative inside tumor (distance to nearest stroma cell),
    positive outside tumor (distance to nearest tumor cell).
    """
    sub = adata[adata.obs["fov_id"] == "MEL09_FOV_IM"].copy()
    coords = sub.obs[["X_um", "Y_um"]].to_numpy()
    is_tumor = (sub.obs["phenotype_abbrev"] == "Mel").to_numpy()
    is_stroma = ~is_tumor
    if is_tumor.sum() < 5 or is_stroma.sum() < 5:
        return pd.DataFrame()

    t_tree = BallTree(coords[is_tumor], metric="euclidean")
    s_tree = BallTree(coords[is_stroma], metric="euclidean")
    d_to_stroma, _ = s_tree.query(coords, k=1)
    d_to_tumor, _ = t_tree.query(coords, k=1)
    signed_dist = np.where(is_tumor, -d_to_stroma.ravel(), d_to_tumor.ravel())

    scaled_df = pd.DataFrame(sub.X, columns=sub.var.index, index=sub.obs.index)
    markers = [m for m in ["SOX10", "HLADPB1", "CD11c", "HLADR", "pS6", "PDL1", "CD8a"] if m in scaled_df.columns]
    df = scaled_df[markers].copy()
    df["signed_dist_um"] = signed_dist
    df["compartment"] = np.where(is_tumor, "Tumor", "Stroma")
    df["dist_bin_um"] = (np.round(signed_dist / 15.0) * 15.0).astype(int)
    df = df[(df["dist_bin_um"] >= -180) & (df["dist_bin_um"] <= 120)]
    prof = df.groupby(["dist_bin_um", "compartment"], observed=True)[markers].mean().reset_index()
    return prof


def main() -> None:
    t0 = time.time()
    adata_fov = ad.read_h5ad(IN_STEP03 / "fov_with_rcn.h5ad")
    adata_strat = ad.read_h5ad(IN_STEP01 / "stratified_phenotyped.h5ad")

    # Add sub-ROI labels (2x2 spatial quadrants per FOV = 16 sub-ROIs across 4 stages)
    # so Fig 4B can compute % of ROIs with significant co-occurrence per stage
    sub_roi_ids = []
    for fov, grp in adata_fov.obs.groupby("fov_id"):
        xm, ym = grp["X_um"].median(), grp["Y_um"].median()
        for idx, r in grp.iterrows():
            sub_roi_ids.append((idx, f"{fov}_q{int(r['X_um'] >= xm)}{int(r['Y_um'] >= ym)}"))
    sub_map = dict(sub_roi_ids)
    adata_fov.obs["sub_roi"] = [sub_map[i] for i in adata_fov.obs.index]

    print("[step04] Running 1,000-permutation spatial_interaction (20 um) on FOVs...")
    si_fov = spatial_interaction_scimap(adata_fov, radius=20.0, n_perm=1000, imageid="fov_id")
    si_fov.to_csv(OUT_DIR / "spatial_interaction_by_fov.csv", index=False)

    print("[step04] Running 1,000-permutation spatial_interaction on 16 sub-ROIs for Fig 4B...")
    si_sub = spatial_interaction_scimap(adata_fov, radius=20.0, n_perm=1000, imageid="sub_roi")
    si_sub.to_csv(OUT_DIR / "spatial_interaction_by_subroi.csv", index=False)

    # Fig 4B: % of sub-ROIs with significant co-occurrence between PD-L1+ DC / DC and PD1+ CTL / CTL
    pdl1_dc = si_sub[
        (si_sub["phenotype"].isin(["PD-L1+ DC", "DC"]))
        & (si_sub["neighbour_phenotype"].isin(["PD1+ CTL", "CTL"]))
    ].copy()
    if not pdl1_dc.empty:
        fig4b = (
            pdl1_dc.groupby(["Stage", "phenotype", "neighbour_phenotype"], observed=True)
            .agg(
                n_rois=("roi_unit", "count"),
                n_sig_cooccur=("sig_state", lambda s: int((s == "Co-occurrence").sum())),
                pct_sig_cooccur=("sig_state", lambda s: round(float((s == "Co-occurrence").mean() * 100.0), 2)),
            )
            .reset_index()
        )
    else:
        fig4b = pd.DataFrame()
    fig4b.to_csv(OUT_DIR / "fig4b_pdl1_dc_pd1_ctl_cooccurrence.csv", index=False)

    print("[step04] Running spatial_pscore (10 um) for CD11C+ myeloid & Mel (Fig S3C)...")
    pscore_stage = spatial_pscore_scimap(
        adata_fov,
        group_a=["Mel"],
        group_b=["DC", "PD-L1+ DC", "CD11C+ mac", "PD-L1+ mac"],
        radius=10.0,
        score_by="Stage",
    )
    pscore_stage.to_csv(OUT_DIR / "figs3c_proximity_volume_by_stage.csv", index=False)

    print("[step04] Exporting spatial centroids (Fig 1E) & boundary gradient (Fig S7D-right)...")
    cent_df = adata_fov[adata_fov.obs["fov_id"] == "MEL09_FOV_IM"].obs[
        ["X_um", "Y_um", "phenotype_abbrev", "lineage_broad", "RCN", "Stage"]
    ].copy()
    cent_df.to_csv(OUT_DIR / "fig1e_cell_centroids_im.csv", index_label="cell_uid")

    grad_df = compute_boundary_gradient(adata_fov)
    grad_df.to_csv(OUT_DIR / "figs7d_boundary_intensity_gradient.csv", index=False)

    print("[step04] Exporting compartment composition (Fig 7F/7G-bars/S7I-bars) & Cohort 1 PDL1 bins (Fig 4F)...")
    # Epidermis vs Dermis proxy via RCN1 (Keratinocyte-rich epidermis) vs non-RCN1 dermis
    adata_fov.obs["compartment_proxy"] = np.where(adata_fov.obs["RCN"] == "RCN1", "Epidermis", "Dermis")
    pd.crosstab(
        [adata_fov.obs["Stage"], adata_fov.obs["compartment_proxy"]],
        adata_fov.obs["phenotype_abbrev"],
        normalize="index",
    ).to_csv(OUT_DIR / "fig7fg_compartment_cell_composition.csv")

    # Cohort 1 PDL1 positivity bins per patient (Fig 4F)
    s_df = pd.DataFrame(adata_strat.X, columns=adata_strat.var.index, index=adata_strat.obs.index)
    c1_rows = []
    for pid, grp in adata_strat.obs.groupby("patient_id"):
        mel_idx = grp.index[grp["phenotype_abbrev"] == "Mel"]
        mye_idx = grp.index[grp["phenotype_abbrev"].isin(["DC", "PD-L1+ DC", "CD11C+ mac", "PD-L1+ mac"])]
        mel_pct = float((s_df.loc[mel_idx, "PDL1"] >= 0.5).mean() * 100.0) if len(mel_idx) else 0.0
        mye_pct = float((s_df.loc[mye_idx, "PDL1"] >= 0.5).mean() * 100.0) if len(mye_idx) else 0.0
        mel_bin = "0-5%" if mel_pct <= 5 else ("5-20%" if mel_pct <= 20 else ">20%")
        mye_bin = "<1%" if mye_pct < 1 else ("1-25%" if mye_pct <= 25 else ">25%")
        c1_rows.append({"patient_id": pid, "mel_pdl1_pct": round(mel_pct, 2), "mel_bin": mel_bin, "myeloid_pdl1_pct": round(mye_pct, 2), "myeloid_bin": mye_bin})
    pd.DataFrame(c1_rows).to_csv(OUT_DIR / "fig4f_cohort1_pdl1_bins.csv", index=False)

    # Honest provenance record for non-single-cell-table panels (1I-right, S1H, 4F Cohort 2)
    provenance_notes = {
        "Fig 1I-right / Fig S1H": {
            "evidence_tier": "unavailable_pixel_linescan",
            "note": "3D 60x DeltaVision optical-section immune synapse line-scan (0-16 um pixel intensity trace) is not stored in S3 single-cell feature CSVs.",
        },
        "Fig 4F": {
            "cohort_1": "local_recompute (5 sampled Cohort 1 patients MEL02/05/09/11/12 from S3)",
            "cohort_2": "original_paper_reported (25 primary melanomas visual scoring bins; raw Cohort 2 single-cell table not deposited on S3)",
        },
        "Fig 7E / Fig S7D-right": {
            "Fig S7D-right": "local_recompute (SOX10, HLADPB1 [MHC-II], CD11c across tumor-stroma boundary in MEL09_FOV_IM)",
            "Fig 7E": "proxy (IRF1 is Panel 3B/5-exclusive on MEL01-1; HLADPB1/SOX10/pS6 used as Panel 2 IFN/MHC-II proxy)",
        },
    }
    with open(OUT_DIR / "step04_provenance_notes.json", "w", encoding="utf-8") as f:
        json.dump(provenance_notes, f, indent=2, ensure_ascii=False)

    summary = {
        "step": "04_spatial_interaction_pscore",
        "n_permutations": 1000,
        "radius_interaction_um": 20.0,
        "radius_pscore_um": 10.0,
        "n_si_fov_pairs": int(len(si_fov)),
        "n_si_subroi_pairs": int(len(si_sub)),
        "covered_panels": ["Fig 1E", "Fig 4B", "Fig 4F (Cohort 1)", "Fig 7E (proxy)", "Fig 7F", "Fig 7G-bars", "Fig S3C", "Fig S7D-right", "Fig S7I-bars"],
        "elapsed_sec": round(time.time() - t0, 2),
    }
    with open(OUT_DIR / "step04_summary.json", "w", encoding="utf-8") as f:
        json.dump(summary, f, indent=2, ensure_ascii=False)

    del adata_fov, adata_strat
    gc.collect()
    print(f"[step04] Done in {summary['elapsed_sec']}s -> {OUT_DIR}")


if __name__ == "__main__":
    main()
