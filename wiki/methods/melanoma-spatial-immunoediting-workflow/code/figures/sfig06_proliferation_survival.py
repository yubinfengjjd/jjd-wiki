#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Supplementary Figure S6 (1:1 Layout Replica of supp_..._p12.png).
Composes S6A (proliferation proxy), S6C (JECHLINGER EMT UP GSEA), S6D-table (mROI counts),
S6E (DDX58/RIGI IM vs EM), S6F (8-gene TCGA-SKCM KM survival grid), and marks S6B/S6D-images as excluded_imaging.
Target size: 7.20 in x 9.32 in (W/H=0.7725 vs orig 0.7727).
"""

import gc
from pathlib import Path
import sys

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.gridspec import GridSpec, GridSpecFromSubplotSpec
import pandas as pd

SRC_FIGURES = Path(__file__).resolve().parent
sys.path.insert(0, str(SRC_FIGURES.parent / "panels"))

from _fig_common import DEFAULT_PAPER_ROOT, save_replica_and_compare
from sfig06_a import draw_panel_s6a
from sfig06_c import draw_panel_s6c
from sfig06_d import draw_panel_s6d
from sfig06_e import draw_panel_s6e
from sfig06_f import draw_panel_s6f

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["pdf.fonttype"] = 42


def main():
    root = DEFAULT_PAPER_ROOT
    df_s6a = pd.read_csv(root / "runs" / "step02_umap_gradients" / "figs6a_proliferation_markers_by_stage_proxy.csv")
    curves_df = pd.read_csv(root / "runs" / "step06_mrseq_deseq2" / "gsea_running_es_curves.csv")
    summary_df = pd.read_csv(root / "runs" / "step06_mrseq_deseq2" / "gsea_summary.csv")
    tab_df = pd.read_csv(root / "runs" / "step06_mrseq_deseq2" / "figs6d_mroi_counts_table.csv")
    log2_df = pd.read_csv(root / "runs" / "step06_mrseq_deseq2" / "deseq2_log2_norm_counts_symbol.csv", index_col=0)
    meta_df = pd.read_csv(root / "data_small" / "mrseq_meta_small.csv")
    km_df = pd.read_csv(root / "runs" / "step07_network_survival" / "figs6f_tcga_km_curves.csv")
    stats_df = pd.read_csv(root / "runs" / "step07_network_survival" / "figs6f_tcga_survival_stats.csv")

    fig = plt.figure(figsize=(7.20, 9.32), dpi=300, facecolor="white")
    main_gs = GridSpec(1, 2, figure=fig, width_ratios=[1.05, 1.00], wspace=0.22,
                       left=0.055, right=0.965, top=0.955, bottom=0.04)

    # Left column: S6A | S6B (excluded) | S6D
    left_gs = GridSpecFromSubplotSpec(3, 1, subplot_spec=main_gs[0, 0], height_ratios=[0.95, 1.05, 1.40], hspace=0.22)
    draw_panel_s6a(fig, left_gs[0, 0], df_s6a)

    ax_b = fig.add_subplot(left_gs[1, 0])
    ax_b.set_xlim(0, 1)
    ax_b.set_ylim(0, 1)
    ax_b.axis("off")
    ax_b.text(-0.06, 1.06, "B", transform=ax_b.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    ax_b.add_patch(mpatches.FancyBboxPatch(
        (0.02, 0.04), 0.96, 0.92,
        boxstyle="round,pad=0.02,rounding_size=0.02",
        facecolor="#F7F7F7", edgecolor="#999999", linestyle="--", linewidth=0.8,
    ))
    ax_b.text(0.50, 0.50, "S6B: IM vs EM CyCIF proliferation microscopy\n(DNA, SOX10, KI67, Cyclin D1/B1, pRB)\n\n[Excluded per imaging policy (excluded_imaging)]",
              ha="center", va="center", fontsize=5.8, color="#555555")

    draw_panel_s6d(fig, left_gs[2, 0], tab_df)

    # Right column: Top (S6C + S6E) | Bottom (S6F 8-panel KM grid)
    right_gs = GridSpecFromSubplotSpec(2, 1, subplot_spec=main_gs[0, 1], height_ratios=[0.95, 2.55], hspace=0.22)
    ce_gs = GridSpecFromSubplotSpec(1, 2, subplot_spec=right_gs[0, 0], width_ratios=[1.45, 0.90], wspace=0.36)
    draw_panel_s6c(fig, ce_gs[0, 0], curves_df, summary_df)
    draw_panel_s6e(fig, ce_gs[0, 1], log2_df, meta_df)
    draw_panel_s6f(fig, right_gs[1, 0], km_df, stats_df)

    out_png, out_cmp = save_replica_and_compare(
        fig, root, "sfig06",
        "extracted/pages/supp_cd-21-1357-supplementary-figures-s1-s7-suppsf1-sf7_p12.png",
        panel_boxes_frac={
            "A": (0.00, 0.00, 0.52, 0.28),
            "C": (0.50, 0.00, 0.80, 0.28),
            "D": (0.00, 0.58, 0.52, 1.00),
            "E": (0.78, 0.00, 1.00, 0.28),
            "F": (0.50, 0.27, 1.00, 1.00),
        },
    )
    plt.close(fig)
    del df_s6a, curves_df, log2_df, km_df
    gc.collect()
    print(f"[sfig06] Done -> {out_png} | compare -> {out_cmp}")


if __name__ == "__main__":
    main()
