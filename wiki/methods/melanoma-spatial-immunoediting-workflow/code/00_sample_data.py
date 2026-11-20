#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Step 00: Download public P1 datasets (S3 CyCIF feature tables, GEO GSE171888 PickSeq mrSEQ,
UCSC Xena TCGA-SKCM expression & survival) and perform fixed-seed (seed=42) stratified
scale-down sampling into data_small/.
"""

import gc
import gzip
import hashlib
import json
import os
import subprocess
import time
import zipfile
from pathlib import Path

import anndata as ad
import numpy as np
import pandas as pd
from sklearn.cluster import KMeans

SEED = 42
PIXELS_TO_UM = 0.65  # HTA-MELATLAS-1: 650 nm/pixel (0.65 um/pixel)

ROOT = Path(os.environ.get("PAPER_ROOT", "."))
RAW_DIR = ROOT / "data_raw"
SMALL_DIR = ROOT / "data_small"
RUN_DIR = ROOT / "runs" / "step00_sample_data"
RAW_DIR.mkdir(parents=True, exist_ok=True)
SMALL_DIR.mkdir(parents=True, exist_ok=True)
RUN_DIR.mkdir(parents=True, exist_ok=True)

SOURCES = {
    "MEL02-1-1-features.zip": "https://hta-melatlas-1.s3.amazonaws.com/data/MEL02-1-1-features.zip",
    "MEL05-1-1-features.zip": "https://hta-melatlas-1.s3.amazonaws.com/data/MEL05-1-1-features.zip",
    "MEL09-1-1-features.zip": "https://hta-melatlas-1.s3.amazonaws.com/data/MEL09-1-1-features.zip",
    "MEL11-1-1-features.zip": "https://hta-melatlas-1.s3.amazonaws.com/data/MEL11-1-1-features.zip",
    "MEL12-1-1-features.zip": "https://hta-melatlas-1.s3.amazonaws.com/data/MEL12-1-1-features.zip",
    "GSE171888_HTA-MELATLAS-1.counts.txt.gz": "https://ftp.ncbi.nlm.nih.gov/geo/series/GSE171nnn/GSE171888/suppl/GSE171888_HTA-MELATLAS-1.counts.txt.gz",
    "GSE171888_series_matrix.txt.gz": "https://ftp.ncbi.nlm.nih.gov/geo/series/GSE171nnn/GSE171888/matrix/GSE171888_series_matrix.txt.gz",
    "SKCM_survival.txt": "https://tcga-xena-hub.s3.us-east-1.amazonaws.com/download/survival%2FSKCM_survival.txt",
    "TCGA.SKCM.HiSeqV2.gz": "https://tcga-xena-hub.s3.us-east-1.amazonaws.com/download/TCGA.SKCM.sampleMap%2FHiSeqV2.gz",
}


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def ensure_downloads() -> dict:
    info = {}
    for fname, url in SOURCES.items():
        fpath = RAW_DIR / fname
        if not fpath.exists() or fpath.stat().st_size == 0:
            print(f"[download] {fname} <- {url}")
            cmd = [
                "curl.exe", "-sSL", "--retry", "3",
                "--connect-timeout", "30", "--max-time", "180",
                "-o", str(fpath), url,
            ]
            subprocess.run(cmd, check=True)
        info[fname] = {
            "url": url,
            "path": str(fpath),
            "bytes": fpath.stat().st_size,
            "sha256": sha256_file(fpath),
        }
    return info


def read_cycif_zip(zip_name: str, patient_id: str, slide_id: str) -> pd.DataFrame:
    zpath = RAW_DIR / zip_name
    with zipfile.ZipFile(zpath) as zf:
        csv_name = [n for n in zf.namelist() if n.endswith(".csv")][0]
        with zf.open(csv_name) as f:
            df = pd.read_csv(f)
    df["patient_id"] = patient_id
    df["imageid"] = slide_id
    df["X_um"] = df["X_centroid"] * PIXELS_TO_UM
    df["Y_um"] = df["Y_centroid"] * PIXELS_TO_UM
    return df


def assign_proxy_stages(df: pd.DataFrame, slide_id: str) -> pd.DataFrame:
    """
    Table S3 specifies the number of ROIs per stage for each patient:
      - MEL02-1-1: 1 ROI -> IM (100% IM, slide-level exact)
      - MEL05-1-1: 2 ROIs -> IM (100% IM, slide-level exact)
      - MEL09-1-1: 7 ROIs -> 5 MIS, 2 IM
      - MEL11-1-1: 4 ROIs -> 1 Normal, 1 Precursor, 2 IM
      - MEL12-1-1: 4 ROIs -> 1 Normal, 3 MIS
    Because S3 feature CSVs do not embed H&E polygon masks, multi-stage slides are
    spatially partitioned into tissue sub-regions via KMeans on (X_centroid, Y_centroid)
    and mapped to stages by pan-CK/SOX10 composition (marked as proxy_spatial_roi_partition).
    """
    df = df.copy()
    if slide_id in ("MEL02-1-1", "MEL05-1-1"):
        df["Stage"] = "IM"
        df["stage_source"] = "table_s3_slide_level_exact"
        df["roi_id"] = slide_id + "_IM_1"
        return df

    coords = df[["X_centroid", "Y_centroid"]].to_numpy()
    if slide_id == "MEL09-1-1":
        n_rois = 7
        km = KMeans(n_clusters=n_rois, random_state=SEED, n_init=10).fit(coords)
        df["_tile"] = km.labels_
        # Rank tiles by log1p(pan-CK) - log1p(SOX10): higher pan-CK/epidermis -> MIS, lower -> IM
        stats = df.groupby("_tile").agg(
            panck=("pan-CK_cellRingMask", lambda s: np.log1p(s).mean()),
            sox10=("SOX10_cellRingMask", lambda s: np.log1p(s).mean()),
        )
        stats["epi_score"] = stats["panck"] - stats["sox10"]
        ranked = stats.sort_values("epi_score", ascending=False).index.tolist()
        tile_map = {t: "MIS" for t in ranked[:5]}
        for t in ranked[5:]:
            tile_map[t] = "IM"
        df["Stage"] = df["_tile"].map(tile_map)
        df["roi_id"] = df.apply(lambda r: f"{slide_id}_{r['Stage']}_{r['_tile']}", axis=1)
        df["stage_source"] = "table_s3_proxy_spatial_roi_partition"
        df.drop(columns=["_tile"], inplace=True)
        return df

    if slide_id == "MEL11-1-1":
        n_rois = 4
        km = KMeans(n_clusters=n_rois, random_state=SEED, n_init=10).fit(coords)
        df["_tile"] = km.labels_
        stats = df.groupby("_tile").agg(
            panck=("pan-CK_cellRingMask", lambda s: np.log1p(s).mean()),
            sox10=("SOX10_cellRingMask", lambda s: np.log1p(s).mean()),
        )
        stats["epi_score"] = stats["panck"] - stats["sox10"]
        ranked = stats.sort_values("epi_score", ascending=False).index.tolist()
        tile_map = {ranked[0]: "Normal", ranked[1]: "Precursor", ranked[2]: "IM", ranked[3]: "IM"}
        df["Stage"] = df["_tile"].map(tile_map)
        df["roi_id"] = df.apply(lambda r: f"{slide_id}_{r['Stage']}_{r['_tile']}", axis=1)
        df["stage_source"] = "table_s3_proxy_spatial_roi_partition"
        df.drop(columns=["_tile"], inplace=True)
        return df

    if slide_id == "MEL12-1-1":
        n_rois = 4
        km = KMeans(n_clusters=n_rois, random_state=SEED, n_init=10).fit(coords)
        df["_tile"] = km.labels_
        stats = df.groupby("_tile").agg(
            panck=("pan-CK_cellRingMask", lambda s: np.log1p(s).mean()),
            sox10=("SOX10_cellRingMask", lambda s: np.log1p(s).mean()),
        )
        stats["epi_score"] = stats["panck"] - stats["sox10"]
        ranked = stats.sort_values("epi_score", ascending=False).index.tolist()
        tile_map = {ranked[0]: "Normal", ranked[1]: "MIS", ranked[2]: "MIS", ranked[3]: "MIS"}
        df["Stage"] = df["_tile"].map(tile_map)
        df["roi_id"] = df.apply(lambda r: f"{slide_id}_{r['Stage']}_{r['_tile']}", axis=1)
        df["stage_source"] = "table_s3_proxy_spatial_roi_partition"
        df.drop(columns=["_tile"], inplace=True)
        return df

    raise ValueError(f"Unknown slide_id: {slide_id}")


def rough_lineage(df: pd.DataFrame) -> pd.Series:
    """Coarse pre-QC lineage tag ONLY for stratified sampling balance."""
    sox10 = np.log1p(df["SOX10_cellRingMask"])
    pck = np.log1p(df["pan-CK_cellRingMask"])
    imm = np.maximum(
        np.log1p(df["CD3d_cellRingMask"]),
        np.maximum(np.log1p(df["CD11c_cellRingMask"]), np.log1p(df["CD163_cellRingMask"])),
    )
    sox_thr = np.quantile(sox10, 0.70)
    pck_thr = np.quantile(pck, 0.75)
    imm_thr = np.quantile(imm, 0.75)
    out = np.full(len(df), "Stroma_Other", dtype=object)
    out[pck >= pck_thr] = "Keratinocyte"
    out[imm >= imm_thr] = "Immune"
    out[sox10 >= sox_thr] = "Melanocyte_Tumor"
    return pd.Series(out, index=df.index)


def df_to_adata(df: pd.DataFrame, marker_cols: list[str], obs_cols: list[str]) -> ad.AnnData:
    X = df[marker_cols].to_numpy(dtype=np.float32)
    clean_names = [c.replace("_cellRingMask", "") for c in marker_cols]
    obs = df[obs_cols].copy()
    obs.index = [f"cell_{i}" for i in range(len(df))]
    for c in obs.select_dtypes(include="object").columns:
        obs[c] = obs[c].astype(str)
    var = pd.DataFrame(index=clean_names)
    var["raw_column"] = marker_cols
    adata = ad.AnnData(X=X, obs=obs, var=var)
    adata.raw = adata.copy()
    return adata


def find_richest_window(df_sub: pd.DataFrame, target_n: int, rng: np.random.Generator) -> pd.DataFrame:
    """
    Find a contiguous square spatial window containing roughly `target_n` cells
    (and strictly <= target_n + 80) maximizing lineage diversity (SOX10, pan-CK, CD3d, CD11c).
    Keeps 100% of cells inside the window (never drops cells inside the box).
    """
    x = df_sub["X_um"].to_numpy()
    y = df_sub["Y_um"].to_numpy()
    # Estimate cell density to choose square side length
    area = max((x.max() - x.min()) * (y.max() - y.min()), 1.0)
    density = len(df_sub) / area
    side = np.sqrt(target_n / max(density, 1e-6))

    # Candidate centers on a coarse grid of actual cells
    cand_idx = rng.choice(len(df_sub), size=min(120, len(df_sub)), replace=False)
    sox = np.log1p(df_sub["SOX10_cellRingMask"].to_numpy()) > np.quantile(np.log1p(df_sub["SOX10_cellRingMask"]), 0.70)
    pck = np.log1p(df_sub["pan-CK_cellRingMask"].to_numpy()) > np.quantile(np.log1p(df_sub["pan-CK_cellRingMask"]), 0.75)
    cd3 = np.log1p(df_sub["CD3d_cellRingMask"].to_numpy()) > np.quantile(np.log1p(df_sub["CD3d_cellRingMask"]), 0.75)
    cd11c = np.log1p(df_sub["CD11c_cellRingMask"].to_numpy()) > np.quantile(np.log1p(df_sub["CD11c_cellRingMask"]), 0.75)

    best_score = -1.0
    best_mask = None
    for idx in cand_idx:
        cx, cy = x[idx], y[idx]
        for scale in (0.7, 0.9, 1.1, 1.3):
            half = 0.5 * side * scale
            mask = (x >= cx - half) & (x <= cx + half) & (y >= cy - half) & (y <= cy + half)
            n = int(mask.sum())
            if n < int(target_n * 0.65) or n > target_n:
                continue
            props = np.array([sox[mask].mean(), pck[mask].mean(), cd3[mask].mean(), cd11c[mask].mean()])
            score = float(np.min(props) * 10.0 + np.sum(props > 0.05) + n / target_n * 0.5)
            if score > best_score:
                best_score = score
                best_mask = mask

    if best_mask is None:
        # Fallback: pick nearest target_n cells around median centroid (convex contiguous patch)
        cx, cy = np.median(x), np.median(y)
        d2 = (x - cx) ** 2 + (y - cy) ** 2
        order = np.argsort(d2)[:target_n]
        best_mask = np.zeros(len(df_sub), dtype=bool)
        best_mask[order] = True

    return df_sub.loc[best_mask].copy()


def sample_cycif(rng: np.random.Generator) -> dict:
    slides = [
        ("MEL02-1-1-features.zip", "MEL02", "MEL02-1-1"),
        ("MEL05-1-1-features.zip", "MEL05", "MEL05-1-1"),
        ("MEL09-1-1-features.zip", "MEL09", "MEL09-1-1"),
        ("MEL11-1-1-features.zip", "MEL11", "MEL11-1-1"),
        ("MEL12-1-1-features.zip", "MEL12", "MEL12-1-1"),
    ]
    dfs = []
    raw_counts = {}
    for zname, pid, sid in slides:
        df = read_cycif_zip(zname, pid, sid)
        raw_counts[sid] = len(df)
        df = assign_proxy_stages(df, sid)
        df["_lineage"] = rough_lineage(df)
        dfs.append(df)
        print(f"  loaded {sid}: {len(df)} rows, stages={df['Stage'].value_counts().to_dict()}")

    common_cols = list(dfs[0].columns)
    for d in dfs[1:]:
        common_cols = [c for c in common_cols if c in d.columns]

    # Separate 73-col slides for contiguous FOVs (MEL09 + MEL11)
    df_mel09 = dfs[2].copy()
    df_mel11 = dfs[3].copy()

    # 1) Stratified 2,500-cell table across all 5 patients x stage x lineage
    all_common = pd.concat([d[common_cols] for d in dfs], ignore_index=True)
    strata = all_common.groupby(["patient_id", "Stage", "_lineage"]).size()
    total_target = 2500
    n_strata = len(strata)
    # Allocate proportional with floor=min(count, max(12, ...)) and trim/top-up to 2500
    alloc = {}
    for k, cnt in strata.items():
        alloc[k] = min(int(cnt), max(12, int(round(total_target * cnt / len(all_common)))))
    # Adjust to hit <= 2500 cleanly
    cur = sum(alloc.values())
    keys_sorted = sorted(alloc.keys(), key=lambda k: alloc[k], reverse=True)
    i = 0
    while cur > total_target:
        k = keys_sorted[i % len(keys_sorted)]
        if alloc[k] > 8:
            alloc[k] -= 1
            cur -= 1
        i += 1
    while cur < total_target:
        k = keys_sorted[i % len(keys_sorted)]
        if alloc[k] < int(strata[k]):
            alloc[k] += 1
            cur += 1
        i += 1

    sampled_parts = []
    for k, n_take in alloc.items():
        sub = all_common[
            (all_common["patient_id"] == k[0])
            & (all_common["Stage"] == k[1])
            & (all_common["_lineage"] == k[2])
        ]
        take_idx = rng.choice(sub.index.to_numpy(), size=n_take, replace=False)
        sampled_parts.append(all_common.loc[take_idx])
    df_strat = pd.concat(sampled_parts, ignore_index=True)
    df_strat = df_strat.sample(frac=1.0, random_state=SEED).reset_index(drop=True)
    df_strat.drop(columns=["_lineage"], inplace=True)

    # Identify marker, DNA, and obs columns
    dna_cols_common = [c for c in common_cols if c.startswith("DNA_")]
    bg_cols_common = [c for c in common_cols if c.startswith("bg")]
    morph_cols = ["Area", "MajorAxisLength", "MinorAxisLength", "Eccentricity", "Solidity", "Extent", "Orientation"]
    coord_cols = ["CellID", "X_centroid", "Y_centroid", "X_um", "Y_um", "patient_id", "imageid", "Stage", "stage_source", "roi_id"]
    marker_cols_common = [
        c for c in common_cols
        if c.endswith("_cellRingMask") and c not in dna_cols_common and c not in bg_cols_common
    ]
    obs_cols_strat = coord_cols + morph_cols + dna_cols_common + bg_cols_common

    adata_strat = df_to_adata(df_strat, marker_cols_common, obs_cols_strat)
    adata_strat.write_h5ad(SMALL_DIR / "cycif_stratified_2500.h5ad")
    df_strat.to_csv(SMALL_DIR / "cycif_stratified_2500.csv", index=False)

    # 2) Contiguous spatial FOVs (<= 2,000 cells total) across 4 stages (N, P, MIS, IM)
    # Using MEL11 (N, P) + MEL09 (MIS, IM) which BOTH share all 73 columns (15 cycles)!
    fov_n = find_richest_window(df_mel11[df_mel11["Stage"] == "Normal"], target_n=400, rng=rng)
    fov_n["fov_id"] = "MEL11_FOV_Normal"
    fov_p = find_richest_window(df_mel11[df_mel11["Stage"] == "Precursor"], target_n=400, rng=rng)
    fov_p["fov_id"] = "MEL11_FOV_Precursor"
    fov_mis = find_richest_window(df_mel09[df_mel09["Stage"] == "MIS"], target_n=550, rng=rng)
    fov_mis["fov_id"] = "MEL09_FOV_MIS"
    fov_im = find_richest_window(df_mel09[df_mel09["Stage"] == "IM"], target_n=600, rng=rng)
    fov_im["fov_id"] = "MEL09_FOV_IM"

    df_fov = pd.concat([fov_n, fov_p, fov_mis, fov_im], ignore_index=True)
    if len(df_fov) > 2000:
        # Trim largest FOV border cleanly if needed (keep <=2000 while keeping spatial contiguity)
        excess = len(df_fov) - 2000
        im_mask = df_fov["fov_id"] == "MEL09_FOV_IM"
        im_sub = df_fov[im_mask].sort_values("X_um")
        keep_im = im_sub.iloc[:-excess]
        df_fov = pd.concat([df_fov[~im_mask], keep_im], ignore_index=True)

    df_fov.drop(columns=["_lineage"], inplace=True)
    fov_cols = list(df_fov.columns)
    dna_cols_73 = [c for c in fov_cols if c.startswith("DNA_")]
    bg_cols_73 = [c for c in fov_cols if c.startswith("bg")]
    marker_cols_73 = [
        c for c in fov_cols
        if c.endswith("_cellRingMask") and c not in dna_cols_73 and c not in bg_cols_73
    ]
    obs_cols_fov = coord_cols + ["fov_id"] + morph_cols + dna_cols_73 + bg_cols_73

    adata_fov = df_to_adata(df_fov, marker_cols_73, obs_cols_fov)
    adata_fov.write_h5ad(SMALL_DIR / "cycif_fov_contiguous.h5ad")
    df_fov.to_csv(SMALL_DIR / "cycif_fov_contiguous.csv", index=False)

    stage_counts_strat = df_strat["Stage"].value_counts().to_dict()
    patient_counts_strat = df_strat["patient_id"].value_counts().to_dict()
    fov_counts = df_fov["fov_id"].value_counts().to_dict()

    del dfs, all_common, df_mel09, df_mel11
    gc.collect()

    return {
        "raw_total_cells_5_slides": int(sum(raw_counts.values())),
        "raw_cells_per_slide": raw_counts,
        "stratified_2500": {
            "n_cells": int(len(df_strat)),
            "n_markers_common": int(len(marker_cols_common)),
            "n_dna_cycles_common": int(len(dna_cols_common)),
            "by_patient": patient_counts_strat,
            "by_stage": stage_counts_strat,
            "evidence_tier": "local_recompute (raw single-cell intensities from HTA-MELATLAS-1 S3; multi-stage ROI partition uses Table S3 counts as proxy because H&E ROI polygons are not in S3 CSVs)",
        },
        "fov_contiguous": {
            "n_cells": int(len(df_fov)),
            "n_markers_73col": int(len(marker_cols_73)),
            "n_dna_cycles_73col": int(len(dna_cols_73)),
            "by_fov": fov_counts,
            "by_stage": df_fov["Stage"].value_counts().to_dict(),
            "evidence_tier": "local_recompute (100% un-subsampled contiguous rectangular FOVs from MEL11 and MEL09)",
        },
    }


def parse_gse171888_series_matrix() -> pd.DataFrame:
    rows = {}
    chars = []
    with gzip.open(RAW_DIR / "GSE171888_series_matrix.txt.gz", "rt", encoding="utf-8", errors="ignore") as f:
        for line in f:
            if not line.startswith("!"):
                continue
            parts = line.rstrip("\n").split("\t")
            key = parts[0]
            vals = [p.strip('"') for p in parts[1:]]
            if key in ("!Sample_title", "!Sample_geo_accession", "!Sample_source_name_ch1", "!Sample_description"):
                rows[key] = vals
            elif key == "!Sample_characteristics_ch1":
                chars.append(vals)

    meta = pd.DataFrame({
        "gsm_id": rows["!Sample_geo_accession"],
        "sample_id": rows["!Sample_description"],
        "title": rows["!Sample_title"],
        "histology_full": rows["!Sample_source_name_ch1"],
    })
    for ch in chars:
        prefix = ch[0].split(":", 1)[0].strip()
        meta[prefix] = [v.split(":", 1)[1].strip() if ":" in v else v for v in ch]

    site_map = {
        "Melanoma in situ": "MIS",
        "Inflammatory regression": "IR",
        "Exophytic melanoma": "EM",
        "Brisk TIL": "bTIL",
        "Invasive melanoma": "IM",
        "Invasive melanoma boundary": "IB",
    }
    meta["site"] = meta["histology_full"].map(site_map)
    return meta


def sample_mrseq(rng: np.random.Generator) -> dict:
    meta = parse_gse171888_series_matrix()
    counts = pd.read_csv(RAW_DIR / "GSE171888_HTA-MELATLAS-1.counts.txt.gz", sep="\t")
    counts = counts.set_index("id")

    # Target <= 120 mROIs keeping all IM (16), IB (12), bTIL (16), and stratified MIS/IR/EM
    target_per_site = {"IM": 16, "IB": 12, "bTIL": 16, "EM": 26, "IR": 24, "MIS": 26}
    sampled_rows = []
    for site, n_take in target_per_site.items():
        sub = meta[meta["site"] == site]
        take = min(n_take, len(sub))
        idx = rng.choice(sub.index.to_numpy(), size=take, replace=False)
        sampled_rows.append(sub.loc[idx])
    meta_small = pd.concat(sampled_rows, ignore_index=True)
    # Sort in deterministic site order
    site_order = ["MIS", "IR", "bTIL", "IB", "IM", "EM"]
    meta_small["site"] = pd.Categorical(meta_small["site"], categories=site_order, ordered=True)
    meta_small = meta_small.sort_values(["site", "sample_id"]).reset_index(drop=True)

    keep_samples = meta_small["sample_id"].tolist()
    counts_small = counts[keep_samples].copy()
    # Filter zero-only genes across sampled mROIs? No, keep all genes that have >= 1 count overall
    # so DESeq2 and Table S6 comparisons match gene universe cleanly
    counts_small = counts_small.loc[counts_small.sum(axis=1) > 0].copy()
    counts_small.index.name = "gene_symbol"

    counts_small.to_csv(SMALL_DIR / "mrseq_counts_small.csv")
    meta_small.to_csv(SMALL_DIR / "mrseq_meta_small.csv", index=False)

    # Also record Table S6 sheet counts for cross-check
    s6_path = ROOT / "intake" / "supp" / "cd-21-1357_table_s6_suppst6.xlsx"
    s6_em_im = pd.read_excel(s6_path, sheet_name="DEG_EM_vs_IM", skiprows=3)
    s6_mis_emim = pd.read_excel(s6_path, sheet_name="DEG_MIS_vs_EM-IM", skiprows=3)

    del counts
    gc.collect()

    return {
        "raw_mrois_pickseq": int(len(meta)),
        "raw_counts_genes": int(counts_small.shape[0]),
        "raw_site_counts": meta["site"].value_counts().to_dict(),
        "sampled_mrois": int(len(meta_small)),
        "sampled_site_counts": meta_small["site"].astype(str).value_counts().to_dict(),
        "table_s6_deg_em_vs_im_rows": int(len(s6_em_im)),
        "table_s6_deg_mis_vs_emim_rows": int(len(s6_mis_emim)),
        "geomx_audit": {
            "paper_n_mrois": 70,
            "present_in_gse171888": False,
            "present_in_s3_hta_melatlas1": False,
            "present_in_table_s6": False,
            "conclusion": "GSE171888 contains ONLY the 222 PickSeq mROIs (40 um). GeoMx 70 mROIs (NanoString CTA) were not publicly deposited in GSE171888, HTA-MELATLAS-1 S3, or Table S6; downstream GeoMx panels (6A, 7H, S6E, S7A, S7C, S7H) will run on PickSeq mROI counts from the same 6 histologic sites of MEL1 and be tagged evidence_tier='proxy'.",
        },
    }


def sample_tcga_skcm(rng: np.random.Generator) -> dict:
    surv = pd.read_csv(RAW_DIR / "SKCM_survival.txt", sep="\t")
    surv = surv.dropna(subset=["OS", "OS.time"]).copy()
    surv = surv[(surv["OS"].isin([0, 1, 0.0, 1.0])) & (surv["OS.time"] > 0)].copy()
    surv["OS"] = surv["OS"].astype(int)

    # Target S100B module genes from Fig S6F (+ S100B itself)
    # Note: PMEL is stored under legacy symbol SILV in TCGA.SKCM.HiSeqV2; MT-ND2 is absent in legacy HiSeqV2
    wanted = {"BRI3", "CDK2", "SILV", "SOX10", "TBC1D7", "TSPAN10", "TYR", "S100B", "MT-ND2"}
    expr_rows = {}
    samples_header = None
    with gzip.open(RAW_DIR / "TCGA.SKCM.HiSeqV2.gz", "rt", encoding="utf-8") as f:
        samples_header = f.readline().rstrip("\n").split("\t")[1:]
        for line in f:
            gene = line.split("\t", 1)[0]
            if gene in wanted:
                vals = line.rstrip("\n").split("\t")[1:]
                expr_rows[gene] = [float(v) if v != "NA" else np.nan for v in vals]

    expr_df = pd.DataFrame(expr_rows, index=samples_header)
    if "SILV" in expr_df.columns and "PMEL" not in expr_df.columns:
        expr_df.rename(columns={"SILV": "PMEL"}, inplace=True)
    expr_df.index.name = "sample"
    expr_df.reset_index(inplace=True)

    merged = pd.merge(surv[["sample", "_PATIENT", "OS", "OS.time"]], expr_df, on="sample", how="inner")
    merged = merged.drop_duplicates(subset=["_PATIENT"]).reset_index(drop=True)

    # Stratified sample <= 120 patients preserving OS event ratio
    n_total = 120
    p_event = merged["OS"].mean()
    n_pos = int(round(n_total * p_event))
    n_neg = n_total - n_pos
    idx_pos = rng.choice(merged[merged["OS"] == 1].index.to_numpy(), size=n_pos, replace=False)
    idx_neg = rng.choice(merged[merged["OS"] == 0].index.to_numpy(), size=n_neg, replace=False)
    tcga_small = pd.concat([merged.loc[idx_pos], merged.loc[idx_neg]], ignore_index=True)
    tcga_small = tcga_small.sample(frac=1.0, random_state=SEED).reset_index(drop=True)
    tcga_small.to_csv(SMALL_DIR / "tcga_skcm_s100b_120.csv", index=False)

    return {
        "raw_survival_rows": int(len(surv)),
        "raw_merged_unique_patients": int(len(merged)),
        "sampled_patients": int(len(tcga_small)),
        "os_event_counts": tcga_small["OS"].value_counts().to_dict(),
        "genes_present": sorted([c for c in expr_df.columns if c != "sample"]),
        "genes_missing": ["MT-ND2 (absent in UCSC Xena Legacy TCGA.SKCM.HiSeqV2 RSEM matrix)"],
        "pmel_alias_note": "PMEL mapped from legacy HGNC symbol SILV in TCGA.SKCM.HiSeqV2",
    }


def main() -> None:
    t0 = time.time()
    rng = np.random.default_rng(SEED)
    print("[step00] Checking raw downloads...")
    downloads = ensure_downloads()

    print("[step00] Sampling CyCIF datasets...")
    cycif_info = sample_cycif(rng)

    print("[step00] Sampling GSE171888 PickSeq mrSEQ...")
    mrseq_info = sample_mrseq(rng)

    print("[step00] Sampling TCGA-SKCM S100B module cohort...")
    tcga_info = sample_tcga_skcm(rng)

    manifest = {
        "paper_id": "pmc9167783",
        "seed": SEED,
        "pixels_to_um": PIXELS_TO_UM,
        "downloads": downloads,
        "datasets": {
            "cycif": cycif_info,
            "mrseq": mrseq_info,
            "tcga_skcm": tcga_info,
        },
        "scale_down_boundary": [
            "CyCIF stratified subset: 2,500 cells (from 181,222 cells across 5 lightweight S3 slides MEL02, MEL05, MEL09, MEL11, MEL12; original full atlas ~1.7M cells across MEL1-MEL13).",
            "CyCIF contiguous FOV subset: <=2,000 cells across 4 unbroken physical rectangular FOVs (Normal, Precursor from MEL11; MIS, IM from MEL09).",
            "CyCIF Panel 2 vs Panel 1/3/4/5 boundary: S3 MEL02..MEL13 slides were profiled with CyCIF Panel 2 (21-plex), so Panel 1/3/4/5-exclusive markers (S100B, MITF, KI67, PMEL, CD63, IRF1, MIF, CD74, CCNE2/A2/B1, pHH3, pRB) are absent in S3 MEL02..MEL13 and documented as panel2_proxy or unmeasured where applicable.",
            "CyCIF EM stage boundary: Exophytic melanoma (EM) exists only in MEL01 (200-350 MB S3 files without ROI polygon masks); MEL02/05/09/11/12 cover N, P, MIS, IM. PickSeq mrSEQ (GSE171888) covers all 6 histological sites including EM.",
            "mrSEQ PickSeq subset: 120 mROIs stratified from 222 PickSeq mROIs in GSE171888 (preserving all 16 IM, 12 IB, 16 bTIL mROIs).",
            "GeoMx 70 mROIs absence: GeoMx NanoString CTA counts were not deposited in GSE171888, HTA-MELATLAS-1 S3, or Table S6; GeoMx-labeled panels use PickSeq mROIs as proxy.",
            "TCGA-SKCM survival subset: 120 unique patients stratified by OS status from 479 UCSC Xena TCGA-SKCM patients (7/8 Fig S6F genes present; MT-ND2 absent in Legacy HiSeqV2 RSEM).",
        ],
        "elapsed_sec": round(time.time() - t0, 2),
    }

    with open(SMALL_DIR / "sampling_manifest.json", "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=2, ensure_ascii=False)
    with open(RUN_DIR / "step00_summary.json", "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=2, ensure_ascii=False)

    print(f"[step00] Done in {manifest['elapsed_sec']}s -> {SMALL_DIR}")


if __name__ == "__main__":
    main()
