#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Main Figure 5 (1:1 Scientific Visual Replica of Nirmal et al., Cancer Discovery 2022, 1518fig5.jpg).
Composes 5 computational panels (B, C, D, E-top/zoom, F) and marks excluded microscopy plates (5A, 5E-bottom).
Target size: 7.20 in x 8.98 in (W/H=0.8018 vs 1518fig5.jpg 0.8018).
"""

import gc
import json
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
from fig05_b import draw_panel_5b
from fig05_c import draw_panel_5c
from fig05_d import draw_panel_5d
from fig05_e import draw_panel_5e
from fig05_f import draw_panel_5f

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["svg.fonttype"] = "none"
plt.rcParams["pdf.fonttype"] = 42


def draw_excluded_5a(fig, gs_slot):
    """Draw clean placeholder noting 5A raw CyCIF microscopy is excluded per imaging policy."""
    ax = fig.add_subplot(gs_slot)
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axis("off")
    ax.text(-0.08, 1.04, "A", transform=ax.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    ax.add_patch(mpatches.FancyBboxPatch(
        (0.02, 0.03), 0.96, 0.94,
        boxstyle="round,pad=0.02,rounding_size=0.02",
        facecolor="#F7F7F7", edgecolor="#999999", linestyle="--", linewidth=0.8,
    ))
    ax.text(
        0.50, 0.50,
        "5A: Whole-slide CyCIF\nmicroscopy\n(S100A, MITF, S100B)\n\n[Excluded per\nimaging policy]",
        ha="center", va="center", fontsize=6.5, color="#555555",
    )


def main():
    root = DEFAULT_PAPER_ROOT
    runs = root / "runs"

    contour_df = pd.read_csv(runs / "step05_tcc_spatial_lag" / "fig5b_s5b_spatial_contours_proxy.csv")
    hm_df = pd.read_csv(runs / "step05_tcc_spatial_lag" / "fig5c_tcc_protein_morph_heatmap.csv")
    st_df = pd.read_csv(runs / "step05_tcc_spatial_lag" / "fig5c_tcc_stage_proportions.csv")
    d5d = pd.read_csv(runs / "step05_tcc_spatial_lag" / "fig5d_tcc_spatial_map.csv")
    df_5f = pd.read_csv(runs / "step05_tcc_spatial_lag" / "fig5f_tcc_marker_positivity.csv")
    fov_df = pd.read_csv(runs / "step03_rcn_lda" / "fov_cells_with_rcn.csv")

    with open(runs / "step05_tcc_spatial_lag" / "fig5e_tcc_voronoi_im.json", "r", encoding="utf-8") as f:
        tcc_vor = json.load(f)
    with open(runs / "step03_rcn_lda" / "voronoi_polygons_fov.json", "r", encoding="utf-8") as f:
        all_vor = json.load(f)

    fig = plt.figure(figsize=(7.20, 8.98), dpi=300, facecolor="white")
    main_gs = GridSpec(
        2, 1,
        figure=fig,
        height_ratios=[2.35, 1.00],
        hspace=0.22,
        left=0.055, right=0.965, top=0.955, bottom=0.055,
    )

    # Top block: Left (58%: 5A+5B on top, 5C below) | Right (42%: 5D full height)
    top_gs = GridSpecFromSubplotSpec(1, 2, subplot_spec=main_gs[0, 0], width_ratios=[1.42, 1.00], wspace=0.14)
    left_top_gs = GridSpecFromSubplotSpec(2, 1, subplot_spec=top_gs[0, 0], height_ratios=[1.15, 1.00], hspace=0.16)
    ab_gs = GridSpecFromSubplotSpec(1, 2, subplot_spec=left_top_gs[0, 0], width_ratios=[0.78, 1.00], wspace=0.12)

    draw_excluded_5a(fig, ab_gs[0, 0])
    draw_panel_5b(fig, ab_gs[0, 1], contour_df, fov_df)
    draw_panel_5c(fig, left_top_gs[1, 0], hm_df, st_df)
    draw_panel_5d(fig, top_gs[0, 1], d5d, fov_df)

    # Bottom block: 5E (left 62%) | 5F (right 38%)
    bot_gs = GridSpecFromSubplotSpec(1, 2, subplot_spec=main_gs[1, 0], width_ratios=[1.55, 1.00], wspace=0.22)
    draw_panel_5e(fig, bot_gs[0, 0], tcc_vor, all_vor)
    draw_panel_5f(fig, bot_gs[0, 1], df_5f)

    panel_boxes = {
        "B": (0.24, 0.00, 0.59, 0.37),
        "C": (0.00, 0.36, 0.60, 0.70),
        "D": (0.58, 0.00, 1.00, 0.70),
        "E": (0.00, 0.68, 0.63, 1.00),
        "F": (0.61, 0.68, 1.00, 1.00),
    }
    out_png, out_cmp = save_replica_and_compare(
        fig, root, "fig05", "1518fig5.jpg", panel_boxes_frac=panel_boxes
    )
    plt.close(fig)

    del contour_df, hm_df, d5d, fov_df, tcc_vor, all_vor
    gc.collect()
    print(f"[fig05] Done -> {out_png} | compare -> {out_cmp}")


if __name__ == "__main__":
    main()
