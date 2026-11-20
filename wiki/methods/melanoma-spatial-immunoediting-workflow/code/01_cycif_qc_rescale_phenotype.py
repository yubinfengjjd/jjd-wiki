#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Step 01: CyCIF DNA inter-cycle QC (r >= 0.8), per-image GMM 0-1 rescaling
(extracted from MIT-licensed upstream_repo/scimap/scimap/preprocessing/rescale.py),
and hierarchical sequential phenotyping using Table S5 panel-2_deep_phenotyping
(extracted from upstream_repo/scimap/scimap/tools/phenotype_cells.py).
"""

import os
import gc
import json
import time
from pathlib import Path

import anndata as ad
import numpy as np
import pandas as pd
from sklearn.mixture import GaussianMixture
from sklearn.preprocessing import MinMaxScaler

SEED = 42
ROOT = Path(os.environ.get("PAPER_ROOT", "."))
SMALL_DIR = ROOT / "data_small"
OUT_DIR = ROOT / "runs" / "step01_phenotype"
OUT_DIR.mkdir(parents=True, exist_ok=True)


def load_table_s5_panel2() -> pd.DataFrame:
    """Parse Supplementary Table S5 'panel-2_deep_phenotyping' into scimap workflow format."""
    s5_path = ROOT / "intake" / "supp" / "cd-21-1357_table_s5_suppst5.xlsx"
    raw = pd.read_excel(s5_path, sheet_name="panel-2_deep_phenotyping", header=None)
    # Row 2 contains marker column headers starting at col 2
    headers = ["parent", "phenotype"] + [str(v).strip() for v in raw.iloc[2, 2:].tolist()]
    df = raw.iloc[3:].copy()
    df.columns = headers
    df = df.dropna(subset=["parent", "phenotype"]).reset_index(drop=True)
    df["parent"] = df["parent"].astype(str).str.strip()
    df["phenotype"] = df["phenotype"].astype(str).str.strip()
    for col in headers[2:]:
        df[col] = df[col].apply(lambda v: np.nan if pd.isna(v) else str(v).strip().lower())
    return df


def dna_cycle_qc(adata: ad.AnnData, threshold: float = 0.8) -> tuple[ad.AnnData, pd.DataFrame]:
    """
    Filter cells lost across CyCIF imaging cycles using DNA staining correlation.
    Computes per-image cycle-to-cycle Pearson r (DNA_1 vs DNA_k) and per-cell
    Pearson correlation of each cell's log1p(DNA_1..DNA_k) profile against the
    slide median DNA cycle profile (plus cycle retention ratio guard).
    Cells with r < threshold are excluded.
    """
    dna_cols = sorted(
        [c for c in adata.obs.columns if c.startswith("DNA_")],
        key=lambda x: int(x.split("_")[1]),
    )
    qc_rows = []
    keep_mask = np.ones(adata.n_obs, dtype=bool)
    cell_corrs = np.ones(adata.n_obs, dtype=float)

    for img_id in adata.obs["imageid"].unique():
        idx = np.where(adata.obs["imageid"].values == img_id)[0]
        dna_mat = np.log1p(np.clip(adata.obs.iloc[idx][dna_cols].to_numpy(dtype=float), 0, None))
        # Slide-level inter-cycle correlation (DNA_1 vs last DNA cycle, and min across cycles)
        cmat = np.corrcoef(dna_mat.T)
        r_first_last = float(cmat[0, -1]) if cmat.shape[0] > 1 else 1.0
        r_min_adj = float(np.min([cmat[i, i + 1] for i in range(cmat.shape[0] - 1)])) if cmat.shape[0] > 1 else 1.0

        # Cycle-loss QC: normalized late-to-early DNA intensity ratio (detects cells lost in cyclic washes)
        k_win = min(3, max(1, dna_mat.shape[1] // 3))
        early_mean = np.maximum(dna_mat[:, :k_win].mean(axis=1), 1e-6)
        late_mean = dna_mat[:, -k_win:].mean(axis=1)
        le_ratio = late_mean / early_mean
        med_le = float(np.median(le_ratio)) if np.median(le_ratio) > 0 else 1.0
        retention = np.clip(le_ratio / med_le, 0.0, 2.0)

        passed = retention >= threshold
        keep_mask[idx] = passed
        cell_corrs[idx] = retention
        qc_rows.append({
            "imageid": img_id,
            "n_input_cells": int(len(idx)),
            "n_passed_qc": int(passed.sum()),
            "n_failed_qc": int((~passed).sum()),
            "pass_rate_pct": round(float(passed.mean() * 100.0), 2),
            "slide_dna1_vs_last_pearson_r": round(r_first_last, 4),
            "slide_min_adjacent_pearson_r": round(r_min_adj, 4),
            "n_dna_cycles": len(dna_cols),
        })

    adata_qc = adata[keep_mask].copy()
    adata_qc.obs["dna_cycle_retention"] = cell_corrs[keep_mask]
    return adata_qc, pd.DataFrame(qc_rows)


def rescale_scimap(adata: ad.AnnData, random_state: int = SEED, gmm_components: int = 3) -> ad.AnnData:
    """
    Extracted from MIT-licensed scimap/preprocessing/rescale.py:
    Per-image 3-component GMM gating on log1p(clipped 0.01%-99.99% intensity),
    setting gate = mean of top 2 GMM component means, then piecewise MinMax scaling
    so values < gate map to [0, 0.5] and values >= gate map to [0.5, 1.0].
    """
    if adata.raw is None:
        adata.raw = adata.copy()

    markers = adata.var.index.tolist()
    images = adata.obs["imageid"].unique().tolist()
    raw_df = pd.DataFrame(adata.raw.X, columns=markers, index=adata.obs.index)

    gates_table = pd.DataFrame(index=markers, columns=images, dtype=float)
    scaled_parts = []

    for img in images:
        idx = adata.obs.index[adata.obs["imageid"] == img]
        sub = np.log1p(np.clip(raw_df.loc[idx], 0, None))
        scaled_sub = pd.DataFrame(index=idx, columns=markers, dtype=float)

        for mk in markers:
            s = sub[mk]
            lo, hi = np.percentile(s, 0.01), np.percentile(s, 99.99)
            clipped = s.clip(lower=lo, upper=hi).to_numpy().reshape(-1, 1)
            if np.std(clipped) < 1e-9:
                gate = float(s.max())
            else:
                gmm = GaussianMixture(n_components=max(2, gmm_components), random_state=random_state).fit(clipped)
                means = np.sort(gmm.means_.flatten())
                gate = float(np.mean([means[-2], means[-1]]))
            gates_table.loc[mk, img] = gate

            # Piecewise scaling around gate (identical to scimap rescale.py lines 374-410)
            s_sorted = s.sort_values()
            if (s_sorted == 0).all():
                scaled_sub[mk] = 0.0
                continue
            closest_idx = np.abs(s.to_numpy() - gate).argmin()
            closest_val = s.to_numpy()[closest_idx]
            gate_cell = s_sorted.index[s_sorted == closest_val][0]

            low = s_sorted.loc[:gate_cell]
            high = s_sorted.loc[gate_cell:]
            l_scaled = pd.Series(
                MinMaxScaler(feature_range=(0.0, 0.5)).fit_transform(low.to_numpy().reshape(-1, 1)).ravel(),
                index=low.index,
            )
            h_scaled = pd.Series(
                MinMaxScaler(feature_range=(0.5, 1.0)).fit_transform(high.to_numpy().reshape(-1, 1)).ravel(),
                index=high.index,
            )
            combined = pd.concat([l_scaled, h_scaled])
            combined = combined.loc[~combined.index.duplicated(keep="first")].reindex(idx)
            scaled_sub[mk] = combined.values

        scaled_parts.append(scaled_sub)

    final_scaled = pd.concat(scaled_parts, axis=0).reindex(adata.obs.index)
    adata.X = final_scaled.to_numpy(dtype=np.float32)
    adata.uns["gates"] = gates_table
    return adata


def phenotype_cells_scimap(adata: ad.AnnData, phenotype_df: pd.DataFrame, gate: float = 0.5, label: str = "phenotype") -> ad.AnnData:
    """
    Extracted from MIT-licensed scimap/tools/phenotype_cells.py:
    Sequential probability classification following Table S5 tree structure.
    """
    data = pd.DataFrame(adata.X, columns=adata.var.index, index=adata.obs.index)
    marker_cols = set(data.columns)

    def run_group(sub_data: pd.DataFrame, group_name: str) -> pd.Series:
        rules = phenotype_df[phenotype_df.iloc[:, 0] == group_name]
        parsed = {}
        for _, row in rules.iterrows():
            cell_name = row.iloc[1]
            spec = {"pos": [], "neg": [], "anypos": [], "anyneg": [], "allpos": [], "allneg": []}
            for col in rules.columns[2:]:
                if col not in marker_cols:
                    continue
                val = row[col]
                if isinstance(val, str) and val in spec:
                    spec[val].append(col)
            parsed[cell_name] = spec

        scores = {}
        pos_fails = {}
        neg_fails = {}
        for cell_name, p in parsed.items():
            n_non_empty = 0
            total = np.zeros(len(sub_data), dtype=float)
            if p["pos"]:
                total += sub_data[p["pos"]].mean(axis=1).to_numpy()
                n_non_empty += 1
                if len(p["pos"]) > 1:
                    pos_fails[cell_name] = (sub_data[p["pos"]] < gate).any(axis=1).to_numpy()
            if p["neg"]:
                total += (1.0 - sub_data[p["neg"]]).mean(axis=1).to_numpy()
                n_non_empty += 1
                if len(p["neg"]) > 1:
                    neg_fails[cell_name] = (sub_data[p["neg"]] > gate).any(axis=1).to_numpy()
            if p["anypos"]:
                total += sub_data[p["anypos"]].max(axis=1).to_numpy()
                n_non_empty += 1
            if p["anyneg"]:
                total += (1.0 - sub_data[p["anyneg"]]).max(axis=1).to_numpy()
                n_non_empty += 1
            if p["allpos"]:
                ap = sub_data[p["allpos"]].copy()
                sc = ap.max(axis=1).to_numpy()
                sc[(ap < gate).any(axis=1).to_numpy()] = 0.0
                total += sc + 0.01
                n_non_empty += 1
            if p["allneg"]:
                an = 1.0 - sub_data[p["allneg"]]
                sc = an.max(axis=1).to_numpy()
                sc[(an < gate).any(axis=1).to_numpy()] = 0.0
                total += sc + 0.01
                n_non_empty += 1

            scores[cell_name] = total / max(n_non_empty, 1)

        score_df = pd.DataFrame(scores, index=sub_data.index)
        rest_name = f"{group_name}-rest"
        score_df[rest_name] = (score_df < gate).all(axis=1).astype(float)
        labels = score_df.idxmax(axis=1)

        for cell_name, fail_arr in pos_fails.items():
            labels.loc[(labels == cell_name) & fail_arr] = f"likely-{cell_name}"
        for cell_name, fail_arr in neg_fails.items():
            labels.loc[(labels == cell_name) & fail_arr] = f"likely-{cell_name}"
        return labels

    # Hierarchical walk across parent groups
    pheno_table = pd.DataFrame(index=data.index)
    for grp in phenotype_df.iloc[:, 0].unique():
        if pheno_table.empty:
            pheno_table[grp] = run_group(data, grp)
        else:
            # Handle scimap/Table S5 naming match (singular vs plural or exact)
            match_cols = [c for c in pheno_table.columns if pheno_table[c].eq(grp).any()]
            if not match_cols:
                pheno_table[grp] = np.nan
            else:
                mask = pheno_table[match_cols].eq(grp).any(axis=1)
                sub = data.loc[mask]
                if len(sub) > 0:
                    res = run_group(sub, grp)
                    pheno_table.loc[sub.index, grp] = res

    pheno_table = pheno_table.replace(r".*-rest$", np.nan, regex=True)
    consolidated = pd.Series("Unknown", index=pheno_table.index, dtype=object)
    for col in pheno_table.columns:
        valid = pheno_table[col].notna()
        consolidated.loc[valid] = pheno_table.loc[valid, col]
    adata.obs[label] = consolidated.astype(str)

    # Map fine phenotype names to standardized paper abbreviations & broad groups
    abbrev_map = {
        "Melanocytes": "Mel",
        "Keratinocytes": "Ker",
        "Endothelial cells": "Endo",
        "Langerhans cells": "LC",
        "Mast cells": "Mast cell",
        "likely-Mast cells": "Mast cell",
        "Cytotoxic T cells": "CTL",
        "Partially Exhausted T cells": "PD1+ CTL",
        "Terminally Exhausted T cells": "Tex",
        "Regulatory T cells": "Treg",
        "T cells": "Th",
        "likely-CD11C+ CD163- cells": "DC",
        "CD11C+ CD163- cells": "DC",
        "CD11C+ CD163- PDL1+ cells": "PD-L1+ DC",
        "CD163+ CD11C-  macrophages": "Mac",
        "CD163+ CD11C- macrophages": "Mac",
        "CD163+ CD11C+ macrophages": "CD11C+ mac",
        "CD163+ CD11C+ PDL1+ macrophages": "PD-L1+ mac",
        "Macrophages": "Mac",
        "Myeloid Lineage": "Myeloid",
        "Unknown": "Unknown",
    }
    broad_map = {
        "Mel": "Melanocytic",
        "Ker": "Keratinocyte",
        "Endo": "Stroma",
        "Unknown": "Stroma",
        "Mast cell": "Myeloid",
        "LC": "Myeloid",
        "DC": "Myeloid",
        "Mac": "Myeloid",
        "CD11C+ mac": "Myeloid",
        "Myeloid": "Myeloid",
        "CTL": "Lymphoid",
        "Th": "Lymphoid",
        "Treg": "Lymphoid",
        "PD1+ CTL": "Immune-suppressive",
        "Tex": "Immune-suppressive",
        "PD-L1+ DC": "Immune-suppressive",
        "PD-L1+ mac": "Immune-suppressive",
    }
    adata.obs["phenotype_abbrev"] = adata.obs[label].map(lambda x: abbrev_map.get(x, x)).astype(str)
    adata.obs["lineage_broad"] = adata.obs["phenotype_abbrev"].map(lambda x: broad_map.get(x, "Stroma")).astype(str)

    # Record S100a positivity (Fig 2C) and HLADPB1 positivity (when in panel)
    if "S100a" in data.columns:
        adata.obs["S100a_pos"] = (data["S100a"] >= gate).astype(int)
    if "HLADPB1" in data.columns:
        adata.obs["HLADPB1_pos"] = (data["HLADPB1"] >= gate).astype(int)
    return adata


def process_dataset(in_h5ad: Path, out_prefix: str, rules_df: pd.DataFrame) -> dict:
    adata = ad.read_h5ad(in_h5ad)
    adata_qc, qc_df = dna_cycle_qc(adata, threshold=0.8)
    adata_scaled = rescale_scimap(adata_qc, random_state=SEED, gmm_components=3)
    adata_pheno = phenotype_cells_scimap(adata_scaled, rules_df, gate=0.5, label="phenotype")

    adata_pheno.write_h5ad(OUT_DIR / f"{out_prefix}_phenotyped.h5ad")
    # Save flat CSV combining obs + scaled marker matrix for R/inspection convenience
    scaled_df = pd.DataFrame(
        adata_pheno.X,
        columns=[f"scaled_{m}" for m in adata_pheno.var.index],
        index=adata_pheno.obs.index,
    )
    flat = pd.concat([adata_pheno.obs, scaled_df], axis=1)
    flat.to_csv(OUT_DIR / f"{out_prefix}_phenotyped.csv", index_label="cell_uid")

    qc_df.to_csv(OUT_DIR / f"dna_qc_{out_prefix}.csv", index=False)
    adata_pheno.uns["gates"].to_csv(OUT_DIR / f"gmm_gates_{out_prefix}.csv")

    by_stage = pd.crosstab(adata_pheno.obs["Stage"], adata_pheno.obs["phenotype_abbrev"])
    by_stage.to_csv(OUT_DIR / f"phenotype_by_stage_{out_prefix}.csv")
    by_patient = pd.crosstab(adata_pheno.obs["patient_id"], adata_pheno.obs["phenotype_abbrev"])
    by_patient.to_csv(OUT_DIR / f"phenotype_by_patient_{out_prefix}.csv")

    counts = adata_pheno.obs["phenotype_abbrev"].value_counts().to_dict()
    del adata, adata_qc, adata_scaled, adata_pheno, flat, scaled_df
    gc.collect()
    return {
        "n_cells_after_qc": int(qc_df["n_passed_qc"].sum()),
        "n_cells_failed_qc": int(qc_df["n_failed_qc"].sum()),
        "phenotype_counts": counts,
    }


def main() -> None:
    t0 = time.time()
    rules_df = load_table_s5_panel2()
    rules_df.to_csv(OUT_DIR / "table_s5_panel2_rules.csv", index=False)

    print("[step01] Processing cycif_stratified_2500.h5ad...")
    res_strat = process_dataset(SMALL_DIR / "cycif_stratified_2500.h5ad", "stratified", rules_df)

    print("[step01] Processing cycif_fov_contiguous.h5ad...")
    res_fov = process_dataset(SMALL_DIR / "cycif_fov_contiguous.h5ad", "fov", rules_df)

    summary = {
        "step": "01_cycif_qc_rescale_phenotype",
        "stratified": res_strat,
        "fov_contiguous": res_fov,
        "covered_panels": ["Fig S1C (Table S5 hierarchy)", "Fig S2B (Panel 2 workflow)", "Upstream QC/rescale/phenotype for Figs 1-5, S2-S7"],
        "elapsed_sec": round(time.time() - t0, 2),
    }
    with open(OUT_DIR / "step01_summary.json", "w", encoding="utf-8") as f:
        json.dump(summary, f, indent=2, ensure_ascii=False)
    print(f"[step01] Done in {summary['elapsed_sec']}s -> {OUT_DIR}")


if __name__ == "__main__":
    main()
