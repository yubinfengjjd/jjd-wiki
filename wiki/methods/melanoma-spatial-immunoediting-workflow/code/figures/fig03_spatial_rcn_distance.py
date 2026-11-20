#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Main Figure 3 (1:1 Scientific Visual Replica of Nirmal et al., Cancer Discovery 2022, 1518fig3.jpg).
Composes 5 computational panels (A, C-top, D, E, F) and marks excluded microscopy plates (3B, 3C-bottom).
Target size: 7.20 in x 9.64 in (W/H=0.7469 vs 1518fig3.jpg 0.7467).
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
from fig03_a import draw_panel_3a
from fig03_c import draw_panel_3c
from fig03_d import draw_panel_3d
from fig03_e import draw_panel_3e
from fig03_f import draw_panel_3f

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["svg.fonttype"] = "none"
plt.rcParams["pdf.fonttype"] = 42


def draw_excluded_3b(fig, gs_slot):
    """Draw clean placeholder noting 3B raw CyCIF & H&E microscopy is excluded per imaging policy."""
    ax = fig.add_subplot(gs_slot)
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axis("off")
    ax.text(-0.04, 1.06, "B", transform=ax.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    rect = mpatches.FancyBboxPatch(
        (0.02, 0.04), 0.96, 0.92,
        boxstyle="round,pad=0.02,rounding_size=0.02",
        facecolor="#F7F7F7", edgecolor="#999999", linestyle="--", linewidth=0.8,
    )
    ax.add_patch(rect)
    ax.text(
        0.50, 0.50,
        "3B: Matched CyCIF & H&E microscopy\n(RCN10 / RCN9 / RCN3/4 / RCN5/8 zooms:\nDNA, S100B, CD163, CD3, CD11C, PD1)\n\n[Excluded per imaging policy]",
        ha="center", va="center", fontsize=7.0, color="#555555",
    )


def main():
    root = DEFAULT_PAPER_ROOT
    runs = root / "runs" / "step03_rcn_lda"

    with open(runs / "voronoi_polygons_fov.json", "r", encoding="utf-8") as f:
        vor_records = json.load(f)
    prop_df = pd.read_csv(runs / "fig3d_rcn_proportions_by_stage.csv")
    dist_df = pd.read_csv(runs / "fig3e_rcn_to_rcn10_distances.csv")
    ttest_df = pd.read_csv(runs / "fig3e_rcn_to_rcn10_ttests.csv")
    fov_df = pd.read_csv(runs / "fov_cells_with_rcn.csv")
    raw_3f = pd.read_csv(runs / "fig3f_mel_immune_raw_distances.csv")

    fig = plt.figure(figsize=(7.20, 9.64), dpi=300, facecolor="white")
    main_gs = GridSpec(
        3, 1,
        figure=fig,
        height_ratios=[2.35, 1.25, 2.05],
        hspace=0.22,
        left=0.060, right=0.965, top=0.965, bottom=0.045,
    )

    # Row 0: 3A (left 43%) | 3B excluded placeholder (right 57%)
    r0_gs = GridSpecFromSubplotSpec(1, 2, subplot_spec=main_gs[0, 0], width_ratios=[1.0, 1.25], wspace=0.12)
    draw_panel_3a(fig, r0_gs[0, 0], vor_records)
    draw_excluded_3b(fig, r0_gs[0, 1])

    # Row 1: 3C-top (full width) + 3C-bottom excluded strip
    draw_panel_3c(fig, main_gs[1, 0], vor_records)

    # Row 2: 3D (left 22%) | Right column (78%: top=3E, bottom=3F)
    r2_gs = GridSpecFromSubplotSpec(1, 2, subplot_spec=main_gs[2, 0], width_ratios=[0.95, 3.25], wspace=0.24)
    draw_panel_3d(fig, r2_gs[0, 0], prop_df)

    right_bot_gs = GridSpecFromSubplotSpec(2, 1, subplot_spec=r2_gs[0, 1], height_ratios=[1.10, 0.95], hspace=0.64)
    draw_panel_3e(fig, right_bot_gs[0, 0], dist_df, ttest_df)
    draw_panel_3f(fig, right_bot_gs[1, 0], fov_df, raw_3f)

    panel_boxes = {
        "A": (0.00, 0.00, 0.46, 0.42),
        "C": (0.00, 0.40, 1.00, 0.65),
        "D": (0.00, 0.63, 0.25, 1.00),
        "E": (0.24, 0.63, 1.00, 0.83),
        "F": (0.24, 0.81, 1.00, 1.00),
    }
    out_png, out_cmp = save_replica_and_compare(
        fig, root, "fig03", "1518fig3.jpg", panel_boxes_frac=panel_boxes
    )
    plt.close(fig)

    del vor_records, fov_df, dist_df
    gc.collect()
    print(f"[fig03] Done -> {out_png} | compare -> {out_cmp}")


if __name__ == "__main__":
    main()
