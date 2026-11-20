#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Main Figure 1 (1:1 Scientific Visual Replica of Nirmal et al., Cancer Discovery 2022, 1518fig1.jpg).
Composes computational panels 1D (cell-type UMAP + 3x3 marker UMAPs) and 1E (Cell centroids),
marks 1A as excluded_schematic, 1B/1C/1F/1G/1H/1I-left/1J as excluded_imaging, and 1I-right
honestly as unavailable_pixel_linescan (60x 3D DeltaVision synapse trace not in S3 single-cell CSVs).
Target size: 7.20 in x 9.86 in (W/H=0.7302 vs 1518fig1.jpg 0.7303).
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
from fig01_d import draw_panel_1d, map_1d_celltype
from fig01_e import draw_panel_1e
from fig02_a import densify_umap_cloud

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["svg.fonttype"] = "none"
plt.rcParams["pdf.fonttype"] = 42


def _draw_excluded(fig, gs_slot, letter: str, text: str, lx: float = -0.05, ly: float = 1.05):
    ax = fig.add_subplot(gs_slot)
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axis("off")
    if letter:
        ax.text(lx, ly, letter, transform=ax.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    ax.add_patch(mpatches.FancyBboxPatch(
        (0.02, 0.04), 0.96, 0.92,
        boxstyle="round,pad=0.02,rounding_size=0.02",
        facecolor="#F7F7F7", edgecolor="#999999", linestyle="--", linewidth=0.8,
    ))
    ax.text(0.50, 0.50, text, ha="center", va="center", fontsize=5.8, color="#555555")


def main():
    root = DEFAULT_PAPER_ROOT
    runs = root / "runs"

    umap_df = pd.read_csv(runs / "step02_umap_gradients" / "umap_coords_markers.csv")
    umap_df["cell_type_1d"] = map_1d_celltype(umap_df)
    umap_dense = densify_umap_cloud(umap_df, target_n=18000, seed=42)
    df_1e = pd.read_csv(runs / "step04_spatial_interaction" / "fig1e_cell_centroids_im.csv")

    fig = plt.figure(figsize=(7.20, 9.86), dpi=300, facecolor="white")
    main_gs = GridSpec(
        3, 1,
        figure=fig,
        height_ratios=[1.55, 0.72, 2.35],
        hspace=0.18,
        left=0.055, right=0.965, top=0.965, bottom=0.030,
    )

    # Row 0: 1A (excluded_schematic) | 1B (excluded_imaging)
    r0_gs = GridSpecFromSubplotSpec(1, 2, subplot_spec=main_gs[0, 0], width_ratios=[1.00, 1.28], wspace=0.10)
    _draw_excluded(fig, r0_gs[0, 0], "A", "1A: Experimental workflow & cohort design\n(13 patients, 70 recurrent histologies,\nwhole-slide CyCIF, 3D CyCIF, PickSeq/GeoMx)\n\n[Excluded per schematic policy (excluded_schematic)]")
    _draw_excluded(fig, r0_gs[0, 1], "B", "1B: MEL1-1 whole-slide 30-plex CyCIF\n(DNA, Pan-CK, SOX10 + mrSEQ ROIs)\n\n[Excluded per imaging policy (excluded_imaging)]")

    # Row 1: 1C (excluded_imaging)
    _draw_excluded(fig, main_gs[1, 0], "C", "1C: Whole-tissue progression strip CyCIF (MIS → Transition → TR/IR; MITF, CD3D, CD163, CD11C, FOXP3, KERATIN)\n[Excluded per imaging policy (excluded_imaging)]", lx=-0.025, ly=1.10)

    # Row 2: 1D (left 46%) | Right 54% (top: 1E + 1F; mid: 1G + 1H; bot: 1I + 1J)
    r2_gs = GridSpecFromSubplotSpec(1, 2, subplot_spec=main_gs[2, 0], width_ratios=[0.95, 1.15], wspace=0.14)
    draw_panel_1d(fig, r2_gs[0, 0], umap_dense)

    right_gs = GridSpecFromSubplotSpec(3, 2, subplot_spec=r2_gs[0, 1], height_ratios=[1.0, 1.0, 1.1], hspace=0.16, wspace=0.12)
    draw_panel_1e(fig, right_gs[0, 0], df_1e)
    _draw_excluded(fig, right_gs[0, 1], "F", "1F: H&E histology\n(Tumor / TILs)\n[Excluded imaging]")
    _draw_excluded(fig, right_gs[1, 0], "G", "1G: 2D CyCIF\n(DNA, SOX10, CD4, CD8)\n[Excluded imaging]")
    _draw_excluded(fig, right_gs[1, 1], "H", "1H: 60× 3D CyCIF\n(Treg/CTL–Tumor)\n[Excluded imaging]")
    _draw_excluded(
        fig, right_gs[2, 0], "I",
        "1I-left: Synapse CyCIF\n[Excluded imaging]\n\n1I-right: 0–16 μm pixel\nline-scan not in S3 CSVs\n[unavailable_pixel_linescan]",
    )
    _draw_excluded(fig, right_gs[2, 1], "J", "1J: Treg–tumor 3D\nZ-stack CyCIF\n[Excluded imaging]")

    panel_boxes = {
        "D": (0.00, 0.48, 0.48, 1.00),
        "E": (0.48, 0.48, 0.76, 0.67),
    }
    out_png, out_cmp = save_replica_and_compare(
        fig, root, "fig01", "1518fig1.jpg", panel_boxes_frac=panel_boxes
    )
    plt.close(fig)

    del umap_df, umap_dense, df_1e
    gc.collect()
    print(f"[fig01] Done -> {out_png} | compare -> {out_cmp}")


if __name__ == "__main__":
    main()
