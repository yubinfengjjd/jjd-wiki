#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: fig05/C
Title: TCC1-10 clustered protein expression & morphology heatmap + left Stage stacked bars
Input tables:
  - runs/step05_tcc_spatial_lag/fig5c_tcc_protein_morph_heatmap.csv
  - runs/step05_tcc_spatial_lag/fig5c_tcc_stage_proportions.csv
Default size: 4.30 in x 3.20 in (300 dpi)
CLI usage:
  python fig05_c.py --paper-root <sources_root>/papers/pmc9167783 --out fig05_c.png
"""

import argparse
from pathlib import Path
import sys

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.colors import LinearSegmentedColormap, Normalize
from matplotlib.gridspec import GridSpecFromSubplotSpec
import numpy as np
import pandas as pd
from scipy.cluster.hierarchy import dendrogram, linkage
from scipy.spatial.distance import pdist

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _fig_common import DEFAULT_PAPER_ROOT

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["pdf.fonttype"] = 42

STAGE_COLORS_5C = {
    "IM": "#B8862D",
    "MIS": "#1D9A6C",
    "Normal": "#3F3D6B",
    "Precursor": "#D96B43",
}


def _zscore_cols(mat: np.ndarray) -> np.ndarray:
    mu = mat.mean(axis=0, keepdims=True)
    sd = np.where(mat.std(axis=0, keepdims=True) > 1e-8, mat.std(axis=0, keepdims=True), 1.0)
    return np.clip((mat - mu) / sd, -2.0, 2.0)


def draw_panel_5c(fig, gs_slot, hm_df: pd.DataFrame, st_df: pd.DataFrame):
    """Draw Panel 5C (Stage bars + protein heatmap + morphology heatmap + dendrograms + Scale bar) inside gs_slot."""
    hm_df = hm_df.set_index("TCC")
    st_df = st_df.set_index("TCC")

    prot_cols = [c for c in ["S100a", "HLADPB1", "CCND1", "SOX10", "MART1", "MYC", "pERK", "pS6", "HLADR", "PDL1", "CD45RO"] if c in hm_df.columns]
    morph_cols = [c for c in ["Extent", "Area", "Solidity", "Eccentricity"] if c in hm_df.columns]

    prot_z = _zscore_cols(hm_df[prot_cols].to_numpy(dtype=float))
    morph_z = _zscore_cols(hm_df[morph_cols].to_numpy(dtype=float))

    # Hierarchical clustering of TCC rows and columns
    row_Z = linkage(pdist(np.hstack([prot_z, morph_z]), metric="euclidean"), method="ward")
    row_order_idx = dendrogram(row_Z, no_plot=True)["leaves"]
    tcc_ordered = [hm_df.index[i] for i in row_order_idx]

    prot_col_Z = linkage(pdist(prot_z.T, metric="euclidean"), method="ward")
    prot_col_order = dendrogram(prot_col_Z, no_plot=True)["leaves"]
    morph_col_Z = linkage(pdist(morph_z.T, metric="euclidean"), method="ward")
    morph_col_order = dendrogram(morph_col_Z, no_plot=True)["leaves"]

    prot_z = prot_z[row_order_idx, :][:, prot_col_order]
    morph_z = morph_z[row_order_idx, :][:, morph_col_order]
    prot_names = [prot_cols[i] for i in prot_col_order]
    morph_names = [morph_cols[i] for i in morph_col_order]

    cmap_5c = LinearSegmentedColormap.from_list(
        "fig5c_scale", ["#36634C", "#83AA87", "#F7F3DC", "#DDB67C", "#B47A3C"]
    )
    norm_5c = Normalize(vmin=-2.0, vmax=2.0)

    sub_gs = GridSpecFromSubplotSpec(
        3, 4,
        subplot_spec=gs_slot,
        height_ratios=[0.42, 2.35, 0.72],
        width_ratios=[0.30, 0.55, 2.25, 0.85],
        hspace=0.05,
        wspace=0.06,
    )

    ax_leg_st = fig.add_subplot(sub_gs[1, 0])
    ax_st_bars = fig.add_subplot(sub_gs[1, 1])
    ax_d_prot = fig.add_subplot(sub_gs[0, 2])
    ax_d_morph = fig.add_subplot(sub_gs[0, 3])
    ax_h_prot = fig.add_subplot(sub_gs[1, 2])
    ax_h_morph = fig.add_subplot(sub_gs[1, 3])
    ax_scale = fig.add_subplot(sub_gs[2, :2])

    ax_leg_st.text(-0.32, 1.18, "C", transform=ax_leg_st.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")

    # Stage legend on far left
    ax_leg_st.axis("off")
    ax_leg_st.set_xlim(0, 1)
    ax_leg_st.set_ylim(0, 1)
    for idx_s, st_k in enumerate(["IM", "MIS", "Normal", "Precursor"]):
        y0 = 0.88 - idx_s * 0.16
        ax_leg_st.add_patch(mpatches.Rectangle((0.05, y0 - 0.08), 0.70, 0.08, facecolor=STAGE_COLORS_5C[st_k], edgecolor="none"))
        lbl_s = "N" if st_k == "Normal" else ("P" if st_k == "Precursor" else st_k)
        ax_leg_st.text(0.40, y0 - 0.11, lbl_s, ha="center", va="top", fontsize=5.6, color="#222222")

    # Stage proportion horizontal bars
    n_rows = len(tcc_ordered)
    ax_st_bars.set_xlim(0, 1)
    ax_st_bars.set_ylim(n_rows, 0)
    for r_i, tname in enumerate(tcc_ordered):
        xc = 0.0
        for st_k in ["IM", "MIS", "Normal", "Precursor"]:
            w = float(st_df.loc[tname, st_k]) if st_k in st_df.columns else 0.0
            if w > 0:
                ax_st_bars.add_patch(mpatches.Rectangle((xc, r_i + 0.08), w, 0.84, facecolor=STAGE_COLORS_5C[st_k], edgecolor="#333333", lw=0.25))
                xc += w
    ax_st_bars.axis("off")

    # Top dendrograms
    for ax_d, Z_mat in [(ax_d_prot, prot_col_Z), (ax_d_morph, morph_col_Z)]:
        dendrogram(Z_mat, ax=ax_d, color_threshold=0, above_threshold_color="#222222")
        for line in ax_d.get_lines():
            line.set_linewidth(0.75)
        ax_d.axis("off")

    # Protein & Morphology heatmaps
    for ax_h, mat, colnames, show_y in [
        (ax_h_prot, prot_z, prot_names, False),
        (ax_h_morph, morph_z, morph_names, True),
    ]:
        nr, nc = mat.shape
        ax_h.set_xlim(0, nc)
        ax_h.set_ylim(nr, 0)
        for ri in range(nr):
            for ci in range(nc):
                ax_h.add_patch(mpatches.Rectangle(
                    (ci, ri), 1.0, 1.0,
                    facecolor=cmap_5c(norm_5c(mat[ri, ci])),
                    edgecolor="#555555", linewidth=0.30,
                ))
        ax_h.set_xticks(np.arange(nc) + 0.5)
        ax_h.set_xticklabels(colnames, rotation=90, fontsize=5.8, va="top", ha="center")
        ax_h.tick_params(axis="x", length=0, pad=2)
        if show_y:
            ax_h.set_yticks(np.arange(nr) + 0.5)
            ax_h.set_yticklabels(tcc_ordered, fontsize=6.0)
            ax_h.yaxis.tick_right()
            ax_h.tick_params(axis="y", length=0, pad=2)
        else:
            ax_h.set_yticks([])
        for sp in ax_h.spines.values():
            sp.set_linewidth(0.5)
            sp.set_color("#444444")

    # Horizontal Scale colorbar at bottom-left
    sc_pos = ax_scale.get_position()
    ax_scale.axis("off")
    cb_ax = fig.add_axes([sc_pos.x0 + 0.01, sc_pos.y0 + 0.015, sc_pos.width * 0.85, 0.012])
    sm = plt.cm.ScalarMappable(cmap=cmap_5c.reversed(), norm=norm_5c)
    cb = fig.colorbar(sm, cax=cb_ax, orientation="horizontal")
    cb.set_ticks([-2, 0, 2])
    cb.set_ticklabels(["2", "0", "−2"])
    cb.ax.xaxis.set_ticks_position("top")
    cb.ax.tick_params(labelsize=5.4, length=1.8, pad=1)
    cb.outline.set_linewidth(0.4)
    cb_ax.set_xlabel("Scale", fontsize=6.0, labelpad=1)


def main():
    parser = argparse.ArgumentParser(description="Render Main Figure 5 Panel C (TCC clustered heatmap).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("fig05_c.png"))
    args = parser.parse_args()

    hm_df = pd.read_csv(args.paper_root / "runs" / "step05_tcc_spatial_lag" / "fig5c_tcc_protein_morph_heatmap.csv")
    st_df = pd.read_csv(args.paper_root / "runs" / "step05_tcc_spatial_lag" / "fig5c_tcc_stage_proportions.csv")

    fig = plt.figure(figsize=(4.40, 3.20), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.06, right=0.90, top=0.92, bottom=0.14)
    draw_panel_5c(fig, gs[0, 0], hm_df, st_df)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[fig05_c] Saved -> {args.out}")


if __name__ == "__main__":
    main()
