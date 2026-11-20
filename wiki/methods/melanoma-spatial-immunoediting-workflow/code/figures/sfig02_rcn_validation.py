#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Supplementary Figure S2 (1:1 Layout Replica of supp_..._p04.png).
Composes S2C-top (RCN1 Voronoi), S2D (K-means elbow curve), S2E (direct spatial_count 30-cluster RCN validation heatmap),
and marks S2A/S2B as excluded_schematic, S2C-mid/bottom as excluded_imaging.
Target size: 7.20 in x 9.32 in (W/H=0.7725 vs orig 0.7727).
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
from sfig02_c import draw_panel_s2c
from sfig02_d import draw_panel_s2d
from sfig02_e import draw_panel_s2e

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["pdf.fonttype"] = 42


def _draw_excluded(fig, gs_slot, letter: str, text: str, lx: float = -0.04, ly: float = 1.04):
    ax = fig.add_subplot(gs_slot)
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axis("off")
    ax.text(lx, ly, letter, transform=ax.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    ax.add_patch(mpatches.FancyBboxPatch(
        (0.02, 0.03), 0.96, 0.94,
        boxstyle="round,pad=0.02,rounding_size=0.02",
        facecolor="#F7F7F7", edgecolor="#999999", linestyle="--", linewidth=0.8,
    ))
    ax.text(0.50, 0.50, text, ha="center", va="center", fontsize=6.0, color="#555555")


def main():
    root = DEFAULT_PAPER_ROOT
    runs = root / "runs" / "step03_rcn_lda"

    with open(runs / "voronoi_polygons_fov.json", "r", encoding="utf-8") as f:
        vor_records = json.load(f)
    elbow_df = pd.read_csv(runs / "figs2d_kmeans_elbow.csv")
    dc30_df = pd.read_csv(runs / "direct_count_cluster30_composition.csv")
    fov_df = pd.read_csv(runs / "fov_cells_with_rcn.csv")

    fig = plt.figure(figsize=(7.20, 9.32), dpi=300, facecolor="white")
    main_gs = GridSpec(
        2, 2, figure=fig,
        height_ratios=[1.05, 1.45],
        width_ratios=[1.0, 1.15],
        hspace=0.18,
        wspace=0.16,
        left=0.08, right=0.965, top=0.96, bottom=0.06,
    )

    # Top row: S2A (excluded_schematic) | S2B (excluded_schematic)
    _draw_excluded(fig, main_gs[0, 0], "A", "S2A: Spatial LDA neighborhood modeling schematic\n(20 μm neighborhoods → LDA → K-means 30 → 10 RCNs)\n\n[Excluded per schematic policy (excluded_schematic)]")
    _draw_excluded(fig, main_gs[0, 1], "B", "S2B: Panel-2 single-cell phenotyping gating tree\n(See S1C for quantitative Panel-2 tree)\n\n[Excluded per schematic policy (excluded_schematic)]")

    # Bottom-left: S2C + S2D | Bottom-right: S2E
    left_bot = GridSpecFromSubplotSpec(2, 1, subplot_spec=main_gs[1, 0], height_ratios=[1.20, 1.00], hspace=0.26)
    draw_panel_s2c(fig, left_bot[0, 0], vor_records)
    draw_panel_s2d(fig, left_bot[1, 0], elbow_df)
    draw_panel_s2e(fig, main_gs[1, 1], dc30_df, fov_df)

    out_png, out_cmp = save_replica_and_compare(
        fig, root, "sfig02",
        "extracted/pages/supp_cd-21-1357-supplementary-figures-s1-s7-suppsf1-sf7_p04.png",
        panel_boxes_frac={"C": (0.00, 0.42, 0.48, 0.72), "D": (0.00, 0.70, 0.48, 1.00), "E": (0.46, 0.42, 1.00, 1.00)},
    )
    plt.close(fig)
    del vor_records, fov_df, dc30_df
    gc.collect()
    print(f"[sfig02] Done -> {out_png} | compare -> {out_cmp}")


if __name__ == "__main__":
    main()
