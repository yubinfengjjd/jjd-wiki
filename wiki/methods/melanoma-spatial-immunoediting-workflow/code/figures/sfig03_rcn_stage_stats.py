#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Supplementary Figure S3 (1:1 Layout Replica of supp_..._p06.png).
Composes S3B (RCN9 stage frequency), S3C (10 um Proximity Volume Score), S3D (RCN2 & RCN3/4 spatial maps),
S3E (RCN1-10 stage comparison p-value heatmap), and marks S3A as excluded_imaging.
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
from sfig03_b import draw_panel_s3b
from sfig03_c import draw_panel_s3c
from sfig03_d import draw_panel_s3d
from sfig03_e import draw_panel_s3e

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["pdf.fonttype"] = 42


def main():
    root = DEFAULT_PAPER_ROOT
    fov_df = pd.read_csv(root / "runs" / "step03_rcn_lda" / "fov_cells_with_rcn.csv")
    pval_df = pd.read_csv(root / "runs" / "step03_rcn_lda" / "figs3e_rcn_stage_pvalues.csv")
    df_s3c = pd.read_csv(root / "runs" / "step04_spatial_interaction" / "figs3c_proximity_volume_by_stage.csv")

    fig = plt.figure(figsize=(7.20, 9.32), dpi=300, facecolor="white")
    main_gs = GridSpec(
        2, 1, figure=fig, height_ratios=[1.25, 1.00], hspace=0.16,
        left=0.085, right=0.94, top=0.96, bottom=0.05,
    )

    # Top: S3A (excluded_imaging)
    ax_a = fig.add_subplot(main_gs[0, 0])
    ax_a.set_xlim(0, 1)
    ax_a.set_ylim(0, 1)
    ax_a.axis("off")
    ax_a.text(-0.02, 1.03, "A", transform=ax_a.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    ax_a.add_patch(mpatches.FancyBboxPatch(
        (0.01, 0.02), 0.98, 0.96,
        boxstyle="round,pad=0.02,rounding_size=0.02",
        facecolor="#F7F7F7", edgecolor="#999999", linestyle="--", linewidth=0.8,
    ))
    ax_a.text(0.50, 0.50, "S3A: Matched H&E & high-plex CyCIF microscopy\n(MEL11, MEL1, MEL8: CD163, CD3D, PanCK, CD11C, SOX10, PD1, CD8A, PDL1)\n\n[Excluded per imaging policy (excluded_imaging)]",
              ha="center", va="center", fontsize=6.5, color="#555555")

    # Bottom: Left (S3B + S3C) | Middle (S3D) | Right (S3E)
    bot_gs = GridSpecFromSubplotSpec(1, 3, subplot_spec=main_gs[1, 0], width_ratios=[1.0, 1.0, 1.05], wspace=0.22)
    bc_gs = GridSpecFromSubplotSpec(2, 1, subplot_spec=bot_gs[0, 0], height_ratios=[1.05, 0.90], hspace=0.45)
    draw_panel_s3b(fig, bc_gs[0, 0], fov_df, pval_df)
    draw_panel_s3c(fig, bc_gs[1, 0], df_s3c)
    draw_panel_s3d(fig, bot_gs[0, 1], fov_df)
    draw_panel_s3e(fig, bot_gs[0, 2], pval_df)

    out_png, out_cmp = save_replica_and_compare(
        fig, root, "sfig03",
        "extracted/pages/supp_cd-21-1357-supplementary-figures-s1-s7-suppsf1-sf7_p06.png",
        panel_boxes_frac={
            "B": (0.00, 0.55, 0.36, 0.80),
            "C": (0.00, 0.78, 0.36, 1.00),
            "D": (0.34, 0.55, 0.68, 1.00),
            "E": (0.66, 0.55, 1.00, 1.00),
        },
    )
    plt.close(fig)
    del fov_df, pval_df, df_s3c
    gc.collect()
    print(f"[sfig03] Done -> {out_png} | compare -> {out_cmp}")


if __name__ == "__main__":
    main()
