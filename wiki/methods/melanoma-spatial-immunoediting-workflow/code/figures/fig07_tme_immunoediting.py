#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Main Figure 7 (1:1 Scientific Visual Replica of Nirmal et al., Cancer Discovery 2022, 1518fig7.jpg).
Composes 5 computational panels (B, E, F, G-bars, H) and marks excluded_imaging (7A, 7C, 7D, 7G-middle)
and excluded_schematic (7I, 7J) boxes cleanly.
Target size: 7.20 in x 9.18 in (W/H=0.7843 vs 1518fig7.jpg 0.7842).
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
from fig07_b import draw_panel_7b
from fig07_e import draw_panel_7e
from fig07_f import draw_panel_7f
from fig07_g import draw_panel_7g
from fig07_h import draw_panel_7h

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["svg.fonttype"] = "none"
plt.rcParams["pdf.fonttype"] = 42


def _draw_excluded_box(fig, gs_slot, letter: str, text: str, lx: float = -0.06, ly: float = 1.08):
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
    runs = root / "runs"

    meta_df = pd.read_csv(root / "data_small" / "mrseq_meta_small.csv")
    df_7b = pd.read_csv(runs / "step06_mrseq_deseq2" / "fig7b_immune_chemokines_long.csv")
    df_7e = pd.read_csv(runs / "step04_spatial_interaction" / "figs7d_boundary_intensity_gradient.csv")
    df_7fg = pd.read_csv(runs / "step04_spatial_interaction" / "fig7fg_compartment_cell_composition.csv")
    z_7h = pd.read_csv(runs / "step06_mrseq_deseq2" / "fig7h_checkpoints_zscore_proxy.csv", index_col=0)
    sig_7h = pd.read_csv(runs / "step06_mrseq_deseq2" / "fig7h_up_vs_em_sig_proxy.csv")

    fig = plt.figure(figsize=(7.20, 9.18), dpi=300, facecolor="white")
    main_gs = GridSpec(
        4, 1,
        figure=fig,
        height_ratios=[1.38, 1.05, 1.02, 0.90],
        hspace=0.26,
        left=0.060, right=0.965, top=0.960, bottom=0.035,
    )

    # Row 0: 7A (excluded imaging) | 7B (5 chemokines)
    r0_gs = GridSpecFromSubplotSpec(1, 2, subplot_spec=main_gs[0, 0], width_ratios=[1.00, 1.38], wspace=0.24)
    _draw_excluded_box(fig, r0_gs[0, 0], "A", "7A: Invasive tumor boundary CyCIF\n(DNA, SOX10, S100B, CD3D, PD1, CD11C)\n\n[Excluded per imaging policy]")
    draw_panel_7b(fig, r0_gs[0, 1], df_7b)

    # Row 1: 7C (excluded) | 7D (excluded) | 7E (boundary gradient)
    r1_gs = GridSpecFromSubplotSpec(1, 3, subplot_spec=main_gs[1, 0], width_ratios=[1.15, 1.15, 0.90], wspace=0.22)
    _draw_excluded_box(fig, r1_gs[0, 0], "C", "7C: MHC-II-expressing\ntumor cells CyCIF\n(DNA, SOX10, MHC-I/II)\n\n[Excluded per imaging policy]")
    _draw_excluded_box(fig, r1_gs[0, 1], "D", "7D: SOX10 / CD11C / IRF1\n/ MART1 CyCIF\n\n[Excluded per imaging policy]")
    draw_panel_7e(fig, r1_gs[0, 2], df_7e)

    # Row 2: 7F (immune composition) | 7G (Epidermis/Dermis bars + excluded mid) | 7H (checkpoints heatmap + sig)
    r2_gs = GridSpecFromSubplotSpec(1, 3, subplot_spec=main_gs[2, 0], width_ratios=[1.22, 0.85, 1.38], wspace=0.18)
    draw_panel_7f(fig, r2_gs[0, 0], df_7fg)
    draw_panel_7g(fig, r2_gs[0, 1], df_7fg)
    draw_panel_7h(fig, r2_gs[0, 2], z_7h, sig_7h, meta_df)

    # Row 3: 7I & 7J (excluded schematics)
    r3_gs = GridSpecFromSubplotSpec(1, 2, subplot_spec=main_gs[3, 0], width_ratios=[1.65, 1.00], wspace=0.14)
    _draw_excluded_box(fig, r3_gs[0, 0], "I", "7I: Remodeling of the TME during progression\n(Normal → Precursor → MIS → Invasive melanoma conceptual diagram)\n\n[Excluded per schematic policy (excluded_schematic)]", lx=-0.04)
    _draw_excluded_box(fig, r3_gs[0, 1], "J", "7J: Tumor–Interface–Stroma\nsignaling model schematic\n(MIF/CD74, CXCL12/CXCR4, IFNγ/IDO1)\n\n[Excluded per schematic policy]", lx=-0.06)

    panel_boxes = {
        "B": (0.40, 0.00, 1.00, 0.34),
        "E": (0.70, 0.32, 1.00, 0.58),
        "F": (0.00, 0.56, 0.36, 0.82),
        "G": (0.34, 0.56, 0.60, 0.82),
        "H": (0.58, 0.56, 1.00, 0.82),
    }
    out_png, out_cmp = save_replica_and_compare(
        fig, root, "fig07", "1518fig7.jpg", panel_boxes_frac=panel_boxes
    )
    plt.close(fig)

    del meta_df, df_7b, df_7e, df_7fg, z_7h, sig_7h
    gc.collect()
    print(f"[fig07] Done -> {out_png} | compare -> {out_cmp}")


if __name__ == "__main__":
    main()
