#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Main Figure 4 (1:1 Scientific Visual Replica of Nirmal et al., Cancer Discovery 2022, 1518fig4.jpg).
Composes computational panels 4B (stage co-occurrence trend) and 4F (Cohort 1 local n=5 vs Cohort 2 paper visual n=25),
and marks 4A, 4C (3D Imaris), 4D, 4E, 4G cleanly as excluded_imaging.
Target size: 7.20 in x 7.33 in (W/H=0.9823 vs 1518fig4.jpg 0.9826).
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
from fig04_b import draw_panel_4b
from fig04_f import draw_panel_4f

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["svg.fonttype"] = "none"
plt.rcParams["pdf.fonttype"] = 42


def _draw_excluded(fig, gs_slot, letter: str, text: str, lx: float = -0.04, ly: float = 1.05):
    ax = fig.add_subplot(gs_slot)
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axis("off")
    ax.text(lx, ly, letter, transform=ax.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    ax.add_patch(mpatches.FancyBboxPatch(
        (0.02, 0.04), 0.96, 0.92,
        boxstyle="round,pad=0.02,rounding_size=0.02",
        facecolor="#F7F7F7", edgecolor="#999999", linestyle="--", linewidth=0.8,
    ))
    ax.text(0.50, 0.50, text, ha="center", va="center", fontsize=6.0, color="#555555")


def main():
    root = DEFAULT_PAPER_ROOT
    runs = root / "runs" / "step04_spatial_interaction"

    sub_df = pd.read_csv(runs / "spatial_interaction_by_subroi.csv")
    df_4f = pd.read_csv(runs / "fig4f_cohort1_pdl1_bins.csv")

    fig = plt.figure(figsize=(7.20, 7.33), dpi=300, facecolor="white")
    main_gs = GridSpec(
        3, 1,
        figure=fig,
        height_ratios=[1.00, 1.55, 1.00],
        hspace=0.26,
        left=0.115, right=0.965, top=0.955, bottom=0.045,
    )

    # Row 0: 4A (excluded) | 4B (trend line) | 4D (excluded)
    r0_gs = GridSpecFromSubplotSpec(1, 3, subplot_spec=main_gs[0, 0], width_ratios=[1.35, 0.95, 1.25], wspace=0.22)
    _draw_excluded(fig, r0_gs[0, 0], "A", "4A: PDL1+ tumor cell–PD1+ CTL\nCyCIF microscopy\n\n[Excluded per imaging policy]")
    draw_panel_4b(fig, r0_gs[0, 1], sub_df)
    _draw_excluded(fig, r0_gs[0, 2], "D", "4D: TIM3 / CD8A / CD11C / CD163\nCyCIF microscopy\n\n[Excluded per imaging policy]")

    # Row 1: 4C (excluded 3D Imaris + CyCIF) | 4E (excluded CyCIF)
    r1_gs = GridSpecFromSubplotSpec(1, 2, subplot_spec=main_gs[1, 0], width_ratios=[1.25, 1.00], wspace=0.14)
    _draw_excluded(fig, r1_gs[0, 0], "C", "4C: Macrophage–T cell synapse CyCIF & Imaris 3D surface render\n(SOX10, CD163, CD8, PDL1, PD1, DNA)\n\n[Excluded per imaging policy]")
    _draw_excluded(fig, r1_gs[0, 1], "E", "4E: Co-inhibitory ligand/receptor CyCIF\n(CD163, CD3D, CD4, CD8A, PD1, PDL1, LAG3, TIM3)\n\n[Excluded per imaging policy]")

    # Row 2: 4F (Cohort 1 vs Cohort 2 bars) | 4G (excluded Primary vs Metastatic CyCIF)
    r2_gs = GridSpecFromSubplotSpec(1, 2, subplot_spec=main_gs[2, 0], width_ratios=[0.90, 2.35], wspace=0.22)
    draw_panel_4f(fig, r2_gs[0, 0], df_4f)
    _draw_excluded(fig, r2_gs[0, 1], "G", "4G: Primary vs Metastatic melanoma PDL1 CyCIF\n(DNA, SOX10, PDL1, CD11C across IB & metastasis)\n\n[Excluded per imaging policy]")

    panel_boxes = {
        "B": (0.35, 0.00, 0.65, 0.31),
        "F": (0.00, 0.68, 0.34, 1.00),
    }
    out_png, out_cmp = save_replica_and_compare(
        fig, root, "fig04", "1518fig4.jpg", panel_boxes_frac=panel_boxes
    )
    plt.close(fig)

    del sub_df, df_4f
    gc.collect()
    print(f"[fig04] Done -> {out_png} | compare -> {out_cmp}")


if __name__ == "__main__":
    main()
