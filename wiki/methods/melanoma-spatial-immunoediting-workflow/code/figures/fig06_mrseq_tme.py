#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Main Figure 6 (1:1 Scientific Visual Replica of Nirmal et al., Cancer Discovery 2022, 1518fig6.jpg).
Composes 10 computational panels (A, B, C, D, E, F, G, I, J, K) and marks excluded microscopy plate 6H.
Target size: 7.20 in x 7.82 in (W/H=0.9207 vs 1518fig6.jpg 0.9203).
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
from fig06_a import draw_panel_6a
from fig06_b import draw_panel_6b
from fig06_c import draw_panel_6c
from fig06_d import draw_panel_6d
from fig06_e import draw_panel_6e
from fig06_f import draw_panel_6f
from fig06_g import draw_panel_6g
from fig06_i import draw_panel_6i
from fig06_j import draw_panel_6j
from fig06_k import draw_panel_6k

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["svg.fonttype"] = "none"
plt.rcParams["pdf.fonttype"] = 42


def draw_excluded_6h(fig, gs_slot):
    """Draw clean placeholder noting 6H raw CyCIF microscopy is excluded per imaging policy."""
    ax = fig.add_subplot(gs_slot)
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axis("off")
    ax.text(-0.08, 1.06, "H", transform=ax.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    rect = mpatches.FancyBboxPatch(
        (0.03, 0.05), 0.94, 0.90,
        boxstyle="round,pad=0.02,rounding_size=0.03",
        facecolor="#F7F7F7", edgecolor="#999999", linestyle="--", linewidth=0.8,
    )
    ax.add_patch(rect)
    ax.text(
        0.50, 0.50,
        "6H: Raw CyCIF\nmicroscopy\n(MIS / EM imaging)\n\n[Excluded per\nimaging policy]",
        ha="center", va="center", fontsize=6.5, color="#555555",
    )


def main():
    root = DEFAULT_PAPER_ROOT
    runs = root / "runs"

    meta_df = pd.read_csv(root / "data_small" / "mrseq_meta_small.csv")
    pca_df = pd.read_csv(runs / "step06_mrseq_deseq2" / "fig6a_pca_coords_proxy.csv")
    df_6b = pd.read_csv(runs / "step06_mrseq_deseq2" / "fig6b_melanoma_markers_long.csv")
    ss_df = pd.read_csv(runs / "step06_mrseq_deseq2" / "fig6c_ssgsea_scores.csv", index_col=0)
    deg_df = pd.read_csv(runs / "step06_mrseq_deseq2" / "deseq2_mis_vs_emim_symbol.csv")
    curves_df = pd.read_csv(runs / "step06_mrseq_deseq2" / "gsea_running_es_curves.csv")
    gsea_sum = pd.read_csv(runs / "step06_mrseq_deseq2" / "gsea_summary.csv")
    df_6f = pd.read_csv(runs / "step06_mrseq_deseq2" / "fig6f_im_vs_em_genes_long.csv")
    z_6g = pd.read_csv(runs / "step06_mrseq_deseq2" / "fig6g_emt_zscore_im_em.csv", index_col=0)
    nodes_df = pd.read_csv(runs / "step07_network_survival" / "fig6i_network_nodes.csv")
    edges_df = pd.read_csv(runs / "step07_network_survival" / "fig6i_network_edges.csv")
    curve_6j = pd.read_csv(runs / "step07_network_survival" / "fig6j_s100b_module_curve.csv")
    df_6k = pd.read_csv(runs / "step06_mrseq_deseq2" / "fig6k_pmel_cd63_density_proxy.csv")

    fig = plt.figure(figsize=(7.20, 7.82), dpi=300, facecolor="white")
    main_gs = GridSpec(
        4, 1,
        figure=fig,
        height_ratios=[1.25, 1.05, 1.08, 1.12],
        hspace=0.34,
        left=0.070, right=0.960, top=0.955, bottom=0.055,
    )

    # Row 0: A (left 25%) | B (middle 36%) | C (right 39%)
    r0_gs = GridSpecFromSubplotSpec(1, 3, subplot_spec=main_gs[0, 0], width_ratios=[1.05, 1.45, 1.55], wspace=0.32)
    draw_panel_6a(fig, r0_gs[0, 0], pca_df)
    draw_panel_6b(fig, r0_gs[0, 1], df_6b)
    draw_panel_6c(fig, r0_gs[0, 2], ss_df, meta_df)

    # Row 1: D (left 34%) | E (middle 23%) | F (right 43%)
    r1_gs = GridSpecFromSubplotSpec(1, 3, subplot_spec=main_gs[1, 0], width_ratios=[1.35, 0.92, 1.73], wspace=0.36)
    draw_panel_6d(fig, r1_gs[0, 0], deg_df)
    draw_panel_6e(fig, r1_gs[0, 1], curves_df, gsea_sum)
    draw_panel_6f(fig, r1_gs[0, 2], df_6f)

    # Row 2: G (left 59%) | I (right 41%)
    r2_gs = GridSpecFromSubplotSpec(1, 2, subplot_spec=main_gs[2, 0], width_ratios=[1.45, 1.00], wspace=0.20)
    draw_panel_6g(fig, r2_gs[0, 0], z_6g, meta_df)
    draw_panel_6i(fig, r2_gs[0, 1], nodes_df, edges_df)

    # Row 3: H excluded box (23%) | J (42%) | K (35%)
    r3_gs = GridSpecFromSubplotSpec(1, 3, subplot_spec=main_gs[3, 0], width_ratios=[0.90, 1.65, 1.45], wspace=0.28)
    draw_excluded_6h(fig, r3_gs[0, 0])
    draw_panel_6j(fig, r3_gs[0, 1], curve_6j)
    draw_panel_6k(fig, r3_gs[0, 2], df_6k)

    panel_boxes = {
        "A": (0.00, 0.00, 0.28, 0.29),
        "B": (0.26, 0.00, 0.63, 0.29),
        "C": (0.61, 0.00, 1.00, 0.29),
        "D": (0.00, 0.27, 0.36, 0.52),
        "E": (0.34, 0.27, 0.59, 0.52),
        "F": (0.57, 0.27, 1.00, 0.52),
        "G": (0.00, 0.50, 0.60, 0.76),
        "I": (0.58, 0.50, 1.00, 0.76),
        "J": (0.23, 0.74, 0.66, 1.00),
        "K": (0.64, 0.74, 1.00, 1.00),
    }
    out_png, out_cmp = save_replica_and_compare(
        fig, root, "fig06", "1518fig6.jpg", panel_boxes_frac=panel_boxes
    )
    plt.close(fig)

    del meta_df, pca_df, df_6b, ss_df, deg_df, curves_df
    gc.collect()
    print(f"[fig06] Done -> {out_png} | compare -> {out_cmp}")


if __name__ == "__main__":
    main()
