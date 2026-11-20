#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Step 02: UMAP embedding (extracted from MIT-licensed scimap/tools/umap.py),
cross-stage S100a+ tumor fraction (Fig 2C), tumor PCA scree & loadings (Fig S5A),
2D density quadrant & proliferation/cell-cycle summary (Fig S5D, S6A, 6K proxy).
"""

import os
import gc
import json
import time
from pathlib import Path

import anndata as ad
import numpy as np
import pandas as pd
import umap as um
from scipy import stats
from sklearn.decomposition import PCA

SEED = 42
ROOT = Path(os.environ.get("PAPER_ROOT", "."))
IN_DIR = ROOT / "runs" / "step01_phenotype"
OUT_DIR = ROOT / "runs" / "step02_umap_gradients"
OUT_DIR.mkdir(parents=True, exist_ok=True)


def run_umap_scimap(adata: ad.AnnData, n_neighbors: int = 15, min_dist: float = 0.1) -> pd.DataFrame:
    """Extracted from scimap/tools/umap.py: fit UMAP on rescaled adata.X."""
    embedding = um.UMAP(
        n_neighbors=n_neighbors,
        n_components=2,
        metric="euclidean",
        min_dist=min_dist,
        random_state=SEED,
    ).fit_transform(adata.X)
    adata.obsm["umap"] = embedding

    umap_df = pd.DataFrame(
        {
            "cell_uid": adata.obs.index,
            "UMAP_1": embedding[:, 0],
            "UMAP_2": embedding[:, 1],
            "phenotype_abbrev": adata.obs["phenotype_abbrev"].values,
            "lineage_broad": adata.obs["lineage_broad"].values,
            "Stage": adata.obs["Stage"].values,
            "patient_id": adata.obs["patient_id"].values,
            "imageid": adata.obs["imageid"].values,
        }
    )
    # Attach key 9+6 markers (Fig 1D & 2B)
    wanted_markers = [
        "SOX10", "pan-CK", "CD3d", "CD8a", "FOXP3", "CD163", "CD11c", "PD1", "PDL1",
        "S100a", "HLAA", "HLADR", "TIM3", "LAG3", "CD31",
    ]
    scaled_df = pd.DataFrame(adata.X, columns=adata.var.index, index=adata.obs.index)
    for mk in wanted_markers:
        if mk in scaled_df.columns:
            umap_df[mk] = scaled_df[mk].values
    return umap_df


def compute_s100a_by_stage(adata: ad.AnnData) -> tuple[pd.DataFrame, pd.DataFrame]:
    """Compute per-ROI % of SOX10+ melanocytes/tumor cells expressing S100a (Fig 2C)."""
    scaled_df = pd.DataFrame(adata.X, columns=adata.var.index, index=adata.obs.index)
    mel_mask = (adata.obs["phenotype_abbrev"] == "Mel") | (scaled_df["SOX10"] >= 0.5)
    sub = adata.obs.loc[mel_mask, ["roi_id", "patient_id", "Stage"]].copy()
    sub["S100a_pos"] = (scaled_df.loc[mel_mask, "S100a"] >= 0.5).astype(float)

    roi_df = (
        sub.groupby(["roi_id", "patient_id", "Stage"], observed=True)["S100a_pos"]
        .agg(n_mel="count", pct_s100a_pos=lambda s: float(s.mean() * 100.0))
        .reset_index()
    )
    stage_order = ["Normal", "Precursor", "MIS", "IM"]
    tests = []
    for i in range(len(stage_order)):
        for j in range(i + 1, len(stage_order)):
            s1, s2 = stage_order[i], stage_order[j]
            v1 = roi_df.loc[roi_df["Stage"] == s1, "pct_s100a_pos"].to_numpy()
            v2 = roi_df.loc[roi_df["Stage"] == s2, "pct_s100a_pos"].to_numpy()
            if len(v1) >= 2 and len(v2) >= 2:
                t_stat, p_val = stats.ttest_ind(v1, v2, equal_var=False)
            else:
                t_stat, p_val = np.nan, np.nan
            tests.append({
                "stage_1": s1,
                "stage_2": s2,
                "n_roi_1": int(len(v1)),
                "n_roi_2": int(len(v2)),
                "mean_1": round(float(np.mean(v1)), 3) if len(v1) else np.nan,
                "mean_2": round(float(np.mean(v2)), 3) if len(v2) else np.nan,
                "t_stat": round(float(t_stat), 4) if np.isfinite(t_stat) else np.nan,
                "p_value": float(p_val) if np.isfinite(p_val) else np.nan,
            })
    return roi_df, pd.DataFrame(tests)


def compute_tumor_pca(adata: ad.AnnData) -> tuple[pd.DataFrame, pd.DataFrame]:
    """PCA scree & PC1/PC2 loadings within SOX10+ tumor/melanocytic cells (Fig S5A)."""
    scaled_df = pd.DataFrame(adata.X, columns=adata.var.index, index=adata.obs.index)
    mel_mask = (adata.obs["phenotype_abbrev"] == "Mel") | (scaled_df["SOX10"] >= 0.5)
    mat = scaled_df.loc[mel_mask].copy()
    # Drop background channels if any slipped in
    mat = mat[[c for c in mat.columns if not c.startswith("bg")]]
    n_pcs = min(15, mat.shape[1], mat.shape[0] - 1)
    pca = PCA(n_components=n_pcs, random_state=SEED)
    pca.fit(mat.to_numpy())

    scree_df = pd.DataFrame({
        "PC": [f"PC{i + 1}" for i in range(n_pcs)],
        "pc_num": list(range(1, n_pcs + 1)),
        "explained_variance_ratio": pca.explained_variance_ratio_,
        "cumulative_variance_ratio": np.cumsum(pca.explained_variance_ratio_),
    })
    loadings_df = pd.DataFrame({
        "marker": mat.columns,
        "PC1_loading": pca.components_[0],
        "PC2_loading": pca.components_[1],
        "abs_PC1": np.abs(pca.components_[0]),
        "abs_PC2": np.abs(pca.components_[1]),
    }).sort_values("abs_PC1", ascending=False).reset_index(drop=True)
    return scree_df, loadings_df


def compute_2d_density_and_cycle_proxy(adata_fov: ad.AnnData) -> tuple[pd.DataFrame, pd.DataFrame, pd.DataFrame]:
    """
    2D density quadrant & proliferation summary (Fig S5D, S6A, 6K proxy).
    Note: Panel 2 (MEL02..MEL13) does not include Panel 1/3/4/5-exclusive KI67/MITF/PMEL/CD63,
    so CCND1 (proliferation/G1 cyclin) vs MART1/SOX10 (melanocytic differentiation) in
    MEL09/MEL11 (73-col) is computed as Panel 2 proxy and tagged evidence_tier='proxy'.
    """
    scaled_df = pd.DataFrame(adata_fov.X, columns=adata_fov.var.index, index=adata_fov.obs.index)
    mel_mask = (adata_fov.obs["phenotype_abbrev"] == "Mel") | (scaled_df["SOX10"] >= 0.5)
    sub_obs = adata_fov.obs.loc[mel_mask, ["Stage", "patient_id", "fov_id"]].copy()
    x_col = "CCND1" if "CCND1" in scaled_df.columns else "MYC"
    y_col = "MART1" if "MART1" in scaled_df.columns else "SOX10"
    sub_obs["x_marker"] = x_col
    sub_obs["y_marker"] = y_col
    sub_obs["x_scaled"] = scaled_df.loc[mel_mask, x_col].values
    sub_obs["y_scaled"] = scaled_df.loc[mel_mask, y_col].values
    sub_obs["S100a_scaled"] = scaled_df.loc[mel_mask, "S100a"].values
    sub_obs["SOX10_scaled"] = scaled_df.loc[mel_mask, "SOX10"].values

    def quad(r):
        xh = "high" if r["x_scaled"] >= 0.5 else "low"
        yh = "high" if r["y_scaled"] >= 0.5 else "low"
        return f"{x_col}_{xh}__{y_col}_{yh}"

    sub_obs["quadrant"] = sub_obs.apply(quad, axis=1)
    quad_summary = (
        sub_obs.groupby(["Stage", "quadrant"], observed=True)
        .size()
        .reset_index(name="n_cells")
    )
    quad_summary["pct_in_stage"] = (
        quad_summary["n_cells"]
        / quad_summary.groupby("Stage")["n_cells"].transform("sum")
        * 100.0
    )

    # Proliferation / signaling marker positivity across stages (Fig S6A proxy)
    cycle_markers = [m for m in ["CCND1", "MYC", "pERK", "pS6", "SOX10", "MART1", "S100a"] if m in scaled_df.columns]
    rows = []
    for st in sub_obs["Stage"].unique():
        st_idx = sub_obs.index[sub_obs["Stage"] == st]
        for mk in cycle_markers:
            pct = float((scaled_df.loc[st_idx, mk] >= 0.5).mean() * 100.0)
            rows.append({"Stage": st, "marker": mk, "n_cells": int(len(st_idx)), "pct_positive": round(pct, 2)})
    cycle_df = pd.DataFrame(rows)
    return sub_obs.reset_index(names="cell_uid"), quad_summary, cycle_df


def main() -> None:
    t0 = time.time()
    adata_strat = ad.read_h5ad(IN_DIR / "stratified_phenotyped.h5ad")
    adata_fov = ad.read_h5ad(IN_DIR / "fov_phenotyped.h5ad")

    print("[step02] Computing UMAP on stratified 2,500-cell CyCIF matrix...")
    umap_df = run_umap_scimap(adata_strat)
    umap_df.to_csv(OUT_DIR / "umap_coords_markers.csv", index=False)

    print("[step02] Computing S100a+ fraction across stages (Fig 2C)...")
    s100a_roi, s100a_tests = compute_s100a_by_stage(adata_strat)
    s100a_roi.to_csv(OUT_DIR / "fig2c_s100a_by_roi_stage.csv", index=False)
    s100a_tests.to_csv(OUT_DIR / "fig2c_s100a_stage_ttests.csv", index=False)

    print("[step02] Computing tumor PCA scree & loadings (Fig S5A)...")
    scree_df, loadings_df = compute_tumor_pca(adata_strat)
    scree_df.to_csv(OUT_DIR / "figs5a_tumor_pca_scree.csv", index=False)
    loadings_df.to_csv(OUT_DIR / "figs5a_tumor_pca_loadings.csv", index=False)

    print("[step02] Computing 2D density quadrants & proliferation marker rates (Fig S5D/S6A/6K proxy)...")
    dens_cells, quad_summary, cycle_df = compute_2d_density_and_cycle_proxy(adata_fov)
    dens_cells.to_csv(OUT_DIR / "figs5d_2d_density_cells_proxy.csv", index=False)
    quad_summary.to_csv(OUT_DIR / "figs5d_quadrant_proportions_proxy.csv", index=False)
    cycle_df.to_csv(OUT_DIR / "figs6a_proliferation_markers_by_stage_proxy.csv", index=False)

    adata_strat.write_h5ad(OUT_DIR / "stratified_with_umap.h5ad")

    summary = {
        "step": "02_umap_marker_gradients",
        "n_cells_umap": int(len(umap_df)),
        "pc1_var_ratio": round(float(scree_df.loc[0, "explained_variance_ratio"]), 4),
        "pc2_var_ratio": round(float(scree_df.loc[1, "explained_variance_ratio"]), 4),
        "covered_panels": {
            "Fig 1D / 2A / 2B": "local_recompute (UMAP cell_type, Stage, patient_id + 15 markers)",
            "Fig 2C": "local_recompute (S100a+ % of SOX10+ cells across Normal/Precursor/MIS/IM)",
            "Fig S5A": "local_recompute (PCA scree & PC1/PC2 loadings on Panel 2 tumor cells)",
            "Fig S5D / S6A / 6K": "proxy (Panel 2 uses CCND1 vs MART1/SOX10/S100a because KI67/MITF/PMEL/CD63/cyclins A2/B1/E2 are Panel 1/3/4/5-exclusive on MEL01-1)",
        },
        "elapsed_sec": round(time.time() - t0, 2),
    }
    with open(OUT_DIR / "step02_summary.json", "w", encoding="utf-8") as f:
        json.dump(summary, f, indent=2, ensure_ascii=False)

    del adata_strat, adata_fov
    gc.collect()
    print(f"[step02] Done in {summary['elapsed_sec']}s -> {OUT_DIR}")


if __name__ == "__main__":
    main()
