#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Supplementary Figure S7 (1:1 Layout Replica of supp_..._p14.png).
Composes all 8 computational panels (S7A, S7B, S7C, S7D-right, S7E, S7F/G, S7H, S7I-bars)
and marks S7D-left & S7I-images as excluded_imaging.
Target size: 7.20 in x 9.32 in (W/H=0.7725 vs orig 0.7727).
"""

import gc
from pathlib import Path
import sys

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec, GridSpecFromSubplotSpec
import pandas as pd

SRC_FIGURES = Path(__file__).resolve().parent
sys.path.insert(0, str(SRC_FIGURES.parent / "panels"))

from _fig_common import DEFAULT_PAPER_ROOT, save_replica_and_compare
from sfig07_a import draw_panel_s7a
from sfig07_b import draw_panel_s7b
from sfig07_c import draw_panel_s7c
from sfig07_d import draw_panel_s7d
from sfig07_e import draw_panel_s7e
from sfig07_f import draw_panel_s7f
from sfig07_g import draw_panel_s7g
from sfig07_h import draw_panel_s7h
from sfig07_i import draw_panel_s7i

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["pdf.fonttype"] = 42


def main():
    root = DEFAULT_PAPER_ROOT
    runs06 = root / "runs" / "step06_mrseq_deseq2"
    runs04 = root / "runs" / "step04_spatial_interaction"

    meta_df = pd.read_csv(root / "data_small" / "mrseq_meta_small.csv")
    df_s7a = pd.read_csv(runs06 / "figs7a_ifng_proxy.csv")
    curves_df = pd.read_csv(runs06 / "gsea_running_es_curves.csv")
    summary_df = pd.read_csv(runs06 / "gsea_summary.csv")
    ss_df = pd.read_csv(runs06 / "figs7c_jakstat_ssgsea_scores_proxy.csv", index_col=0)
    df_s7d = pd.read_csv(runs04 / "figs7d_boundary_intensity_gradient.csv")
    df_s7e = pd.read_csv(runs06 / "figs7e_irf1_bTIL_IB_IM.csv")
    df_fg = pd.read_csv(runs06 / "figs7fg_mif_cd74_proxy.csv")
    z_h = pd.read_csv(runs06 / "figs7h_cxcl12_cxcr4_zscore_proxy.csv", index_col=0)
    df_7fg = pd.read_csv(runs04 / "fig7fg_compartment_cell_composition.csv")

    fig = plt.figure(figsize=(7.20, 9.32), dpi=300, facecolor="white")
    main_gs = GridSpec(
        3, 1, figure=fig, height_ratios=[0.95, 1.65, 1.30], hspace=0.22,
        left=0.065, right=0.935, top=0.955, bottom=0.035,
    )

    # Row 0: S7A | S7B | S7C
    r0_gs = GridSpecFromSubplotSpec(1, 3, subplot_spec=main_gs[0, 0], width_ratios=[0.85, 1.00, 1.65], wspace=0.28)
    draw_panel_s7a(fig, r0_gs[0, 0], df_s7a)
    draw_panel_s7b(fig, r0_gs[0, 1], curves_df, summary_df)
    draw_panel_s7c(fig, r0_gs[0, 2], ss_df, meta_df)

    # Row 1: Left (S7D top + S7E bottom) | Right (S7F + S7G top + S7H bottom)
    r1_gs = GridSpecFromSubplotSpec(1, 2, subplot_spec=main_gs[1, 0], width_ratios=[1.00, 1.05], wspace=0.22)
    left_r1 = GridSpecFromSubplotSpec(2, 1, subplot_spec=r1_gs[0, 0], height_ratios=[1.30, 0.90], hspace=0.48)
    draw_panel_s7d(fig, left_r1[0, 0], df_s7d)
    draw_panel_s7e(fig, left_r1[1, 0], df_s7e)

    right_r1 = GridSpecFromSubplotSpec(2, 1, subplot_spec=r1_gs[0, 1], height_ratios=[1.30, 0.90], hspace=0.40)
    fg_gs = GridSpecFromSubplotSpec(1, 2, subplot_spec=right_r1[0, 0], wspace=0.20)
    draw_panel_s7f(fig, fg_gs[0, 0], df_fg)
    draw_panel_s7g(fig, fg_gs[0, 1], df_fg, show_ylabels=False)
    draw_panel_s7h(fig, right_r1[1, 0], z_h, meta_df)

    # Row 2: S7I full width
    draw_panel_s7i(fig, main_gs[2, 0], df_7fg)

    out_png, out_cmp = save_replica_and_compare(
        fig, root, "sfig07",
        "extracted/pages/supp_cd-21-1357-supplementary-figures-s1-s7-suppsf1-sf7_p14.png",
        panel_boxes_frac={
            "A": (0.00, 0.00, 0.25, 0.27),
            "B": (0.24, 0.00, 0.52, 0.27),
            "C": (0.50, 0.00, 1.00, 0.27),
            "D": (0.00, 0.26, 0.50, 0.52),
            "E": (0.00, 0.50, 0.50, 0.68),
            "F": (0.48, 0.26, 0.74, 0.52),
            "G": (0.72, 0.26, 1.00, 0.52),
            "H": (0.48, 0.50, 1.00, 0.68),
            "I": (0.00, 0.66, 1.00, 1.00),
        },
    )
    plt.close(fig)
    del meta_df, curves_df, ss_df, df_7fg
    gc.collect()
    print(f"[sfig07] Done -> {out_png} | compare -> {out_cmp}")


if __name__ == "__main__":
    main()
