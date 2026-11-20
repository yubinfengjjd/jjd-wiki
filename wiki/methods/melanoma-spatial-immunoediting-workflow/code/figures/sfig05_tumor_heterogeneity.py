#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Supplementary Figure S5 (1:1 Layout Replica of supp_..._p10.png).
Composes S5A (tumor PCA scree & loadings), S5B (3-panel spatial contours), S5C (TCC co-occurrence matrix),
S5D (2D CCND1 vs MART1 density quadrants proxy), and marks S5E as excluded_imaging.
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
from sfig05_a import draw_panel_s5a
from sfig05_b import draw_panel_s5b
from sfig05_c import draw_panel_s5c
from sfig05_d import draw_panel_s5d

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["pdf.fonttype"] = 42


def main():
    root = DEFAULT_PAPER_ROOT
    scree_df = pd.read_csv(root / "runs" / "step02_umap_gradients" / "figs5a_tumor_pca_scree.csv")
    load_df = pd.read_csv(root / "runs" / "step02_umap_gradients" / "figs5a_tumor_pca_loadings.csv")
    contour_df = pd.read_csv(root / "runs" / "step05_tcc_spatial_lag" / "fig5b_s5b_spatial_contours_proxy.csv")
    fov_df = pd.read_csv(root / "runs" / "step03_rcn_lda" / "fov_cells_with_rcn.csv")
    df_s5c = pd.read_csv(root / "runs" / "step05_tcc_spatial_lag" / "figs5c_tcc_cooccurrence.csv")
    cells_df = pd.read_csv(root / "runs" / "step02_umap_gradients" / "figs5d_2d_density_cells_proxy.csv")
    quad_df = pd.read_csv(root / "runs" / "step02_umap_gradients" / "figs5d_quadrant_proportions_proxy.csv")

    fig = plt.figure(figsize=(7.20, 9.32), dpi=300, facecolor="white")
    main_gs = GridSpec(
        2, 1, figure=fig, height_ratios=[2.05, 1.00], hspace=0.18,
        left=0.13, right=0.965, top=0.955, bottom=0.04,
    )

    # Top row: Left (S5A top + S5C bottom) | Right (S5B 3 contour panels)
    top_gs = GridSpecFromSubplotSpec(1, 2, subplot_spec=main_gs[0, 0], width_ratios=[1.42, 1.00], wspace=0.16)
    left_top = GridSpecFromSubplotSpec(2, 1, subplot_spec=top_gs[0, 0], height_ratios=[0.95, 1.25], hspace=0.28)
    draw_panel_s5a(fig, left_top[0, 0], scree_df, load_df)
    draw_panel_s5c(fig, left_top[1, 0], df_s5c)
    draw_panel_s5b(fig, top_gs[0, 1], contour_df, fov_df)

    # Bottom row: S5D (left) | S5E excluded_imaging (right)
    bot_gs = GridSpecFromSubplotSpec(1, 2, subplot_spec=main_gs[1, 0], width_ratios=[0.90, 1.25], wspace=0.18)
    draw_panel_s5d(fig, bot_gs[0, 0], cells_df, quad_df)

    ax_e = fig.add_subplot(bot_gs[0, 1])
    ax_e.set_xlim(0, 1)
    ax_e.set_ylim(0, 1)
    ax_e.axis("off")
    ax_e.text(-0.04, 1.06, "E", transform=ax_e.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    ax_e.add_patch(mpatches.FancyBboxPatch(
        (0.02, 0.03), 0.96, 0.94,
        boxstyle="round,pad=0.02,rounding_size=0.02",
        facecolor="#F7F7F7", edgecolor="#999999", linestyle="--", linewidth=0.8,
    ))
    ax_e.text(0.50, 0.50, "S5E: Invasive Melanoma CyCIF microscopy\n(SOX10, S100B, CD11C, KI67, MITF)\n\n[Excluded per imaging policy (excluded_imaging)]",
              ha="center", va="center", fontsize=6.0, color="#555555")

    out_png, out_cmp = save_replica_and_compare(
        fig, root, "sfig05",
        "extracted/pages/supp_cd-21-1357-supplementary-figures-s1-s7-suppsf1-sf7_p10.png",
        panel_boxes_frac={
            "A": (0.00, 0.00, 0.58, 0.30),
            "B": (0.56, 0.00, 1.00, 0.66),
            "C": (0.00, 0.28, 0.58, 0.66),
            "D": (0.00, 0.64, 0.44, 1.00),
        },
    )
    plt.close(fig)
    del scree_df, load_df, contour_df, fov_df, df_s5c, cells_df
    gc.collect()
    print(f"[sfig05] Done -> {out_png} | compare -> {out_cmp}")


if __name__ == "__main__":
    main()
