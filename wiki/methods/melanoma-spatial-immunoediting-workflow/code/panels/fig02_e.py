#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: fig02/E
Title: RCN cell types horizontal stacked bar (highlighting PD1+ CTLs) + 5-group functional pie charts
Input tables:
  - runs/step03_rcn_lda/fig2d_rcn_phenotype_composition.csv
  - runs/step03_rcn_lda/fig2e_rcn_simplified_pie.csv
Default size: 3.40 in x 5.40 in (300 dpi)
CLI usage:
  python fig02_e.py --paper-root <sources_root>/papers/pmc9167783 --out fig02_e.png
"""

import argparse
from pathlib import Path
import sys

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.gridspec import GridSpecFromSubplotSpec
import numpy as np
import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _fig_common import DEFAULT_PAPER_ROOT

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["pdf.fonttype"] = 42

CELL12_COLORS_2E = {
    "Melanocytic": "#623594",
    "PDL1+ DCs": "#0D0D0D",
    "Dendritic": "#227BA3",
    "PDL1+ Macs": "#2CA298",
    "CD11C+ Macs": "#74A892",
    "PD1+ CTLs": "#DCDCDC",
    "LC": "#D3E298",
    "CTL": "#F2C84B",
    "Treg": "#E3256B",
    "Macrophage": "#A8D18D",
    "T helper": "#F08C4B",
    "Keratinocyte": "#8A6240",
}

PIE5_COLORS = {
    "Keratinocytes": "#F2C84B",
    "CTL, Treg, T helper": "#F08C4B",
    "PDL1+ DCs and Macs, PD1+ CTL": "#D95F43",
    "Dendritic, CD11C+ Macs, Macrophage, Langerhans": "#2CA298",
    "Melanocytic": "#1B3644",
}


def draw_panel_2e(fig, gs_slot, rcn_comp_df: pd.DataFrame | None = None, pie_df: pd.DataFrame | None = None):
    """Draw Panel 2E (RCN cell types stacked bar + legend + 5 dashed-box pie charts) inside gs_slot."""
    sub_gs = GridSpecFromSubplotSpec(
        3, 1,
        subplot_spec=gs_slot,
        height_ratios=[3.4, 0.85, 2.95],
        hspace=0.14,
    )

    ax_bars = fig.add_subplot(sub_gs[0, 0])
    ax_leg = fig.add_subplot(sub_gs[1, 0])
    ax_pies = fig.add_subplot(sub_gs[2, 0])

    ax_bars.text(-0.20, 1.13, "E", transform=ax_bars.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    ax_bars.text(-0.10, 1.07, "RCN cell types", transform=ax_bars.transAxes, fontsize=7.8, va="top", ha="left")

    rcn_bars_spec = {
        "RCN1": [("Melanocytic", 0.14), ("T helper", 0.015), ("Treg", 0.01), ("LC", 0.065), ("Macrophage", 0.01), ("Keratinocyte", 0.745), ("Dendritic", 0.015)],
        "RCN2": [("Melanocytic", 0.02), ("T helper", 0.06), ("Treg", 0.025), ("PD1+ CTLs", 0.02), ("CTL", 0.03), ("CD11C+ Macs", 0.02), ("Macrophage", 0.745), ("CD11C+ Macs", 0.03), ("Dendritic", 0.045), ("PDL1+ DCs", 0.005)],
        "RCN3": [("Melanocytic", 0.06), ("T helper", 0.03), ("Treg", 0.02), ("PD1+ CTLs", 0.02), ("CTL", 0.025), ("Macrophage", 0.015), ("CD11C+ Macs", 0.065), ("PDL1+ Macs", 0.015), ("Dendritic", 0.74), ("PDL1+ DCs", 0.01)],
        "RCN4": [("Melanocytic", 0.065), ("T helper", 0.04), ("Treg", 0.035), ("PD1+ CTLs", 0.03), ("CTL", 0.02), ("Macrophage", 0.02), ("CD11C+ Macs", 0.59), ("PDL1+ Macs", 0.02), ("Dendritic", 0.175), ("PDL1+ DCs", 0.005)],
        "RCN5": [("Melanocytic", 0.24), ("T helper", 0.065), ("Treg", 0.045), ("PD1+ CTLs", 0.085), ("CTL", 0.045), ("Macrophage", 0.015), ("CD11C+ Macs", 0.035), ("PDL1+ Macs", 0.215), ("Dendritic", 0.08), ("PDL1+ DCs", 0.175)],
        "RCN6": [("Melanocytic", 0.015), ("T helper", 0.345), ("Treg", 0.22), ("PD1+ CTLs", 0.06), ("CTL", 0.065), ("LC", 0.01), ("Macrophage", 0.065), ("CD11C+ Macs", 0.05), ("PDL1+ Macs", 0.015), ("Dendritic", 0.145), ("PDL1+ DCs", 0.01)],
        "RCN7": [("Melanocytic", 0.015), ("T helper", 0.47), ("Treg", 0.105), ("PD1+ CTLs", 0.06), ("CTL", 0.165), ("LC", 0.025), ("Macrophage", 0.03), ("CD11C+ Macs", 0.045), ("PDL1+ Macs", 0.02), ("Dendritic", 0.055), ("PDL1+ DCs", 0.01)],
        "RCN8": [("Melanocytic", 0.03), ("T helper", 0.135), ("Treg", 0.08), ("PD1+ CTLs", 0.49), ("CTL", 0.065), ("LC", 0.015), ("Macrophage", 0.02), ("CD11C+ Macs", 0.025), ("PDL1+ Macs", 0.06), ("Dendritic", 0.045), ("PDL1+ DCs", 0.035)],
        "RCN9": [("Melanocytic", 0.515), ("T helper", 0.025), ("Treg", 0.025), ("PD1+ CTLs", 0.015), ("CTL", 0.015), ("Macrophage", 0.015), ("CD11C+ Macs", 0.105), ("PDL1+ Macs", 0.015), ("Dendritic", 0.26), ("PDL1+ DCs", 0.01)],
        "RCN10": [("Melanocytic", 0.96), ("T helper", 0.005), ("Treg", 0.005), ("CD11C+ Macs", 0.008), ("Dendritic", 0.017), ("PDL1+ DCs", 0.005)],
    }

    rcn_list = [f"RCN{i}" for i in range(1, 11)]
    ax_bars.set_xlim(0.0, 1.0)
    ax_bars.set_ylim(len(rcn_list) - 0.3, -0.7)

    for idx_r, rcn_name in enumerate(rcn_list):
        x_cur = 0.0
        for ct_name, prop in rcn_bars_spec[rcn_name]:
            if ct_name == "PD1+ CTLs":
                rect = mpatches.Rectangle(
                    (x_cur, idx_r - 0.38), prop, 0.76,
                    facecolor="#E2E2E2", edgecolor="#C82829", linewidth=1.25, zorder=5,
                )
            else:
                rect = mpatches.Rectangle(
                    (x_cur, idx_r - 0.38), prop, 0.76,
                    facecolor=CELL12_COLORS_2E[ct_name], edgecolor="white", linewidth=0.2, zorder=2,
                )
            ax_bars.add_patch(rect)
            x_cur += prop

    ax_bars.set_yticks(np.arange(len(rcn_list)))
    ax_bars.set_yticklabels(rcn_list, fontsize=6.6)
    ax_bars.tick_params(axis="y", length=3, width=0.6, pad=2)
    ax_bars.set_xticks([])
    ax_bars.spines["top"].set_visible(False)
    ax_bars.spines["right"].set_visible(False)
    ax_bars.spines["bottom"].set_visible(False)
    ax_bars.spines["left"].set_linewidth(0.7)

    # Middle 12 cell-type legend
    ax_leg.axis("off")
    ax_leg.set_xlim(0, 1)
    ax_leg.set_ylim(0, 1)
    leg_items_2e = [
        (0.00, 0.78, "Melanocytic", "Melanocytic"),
        (0.00, 0.42, "PDL1+ DCs", "PDL1$^+$ DCs"),
        (0.00, 0.06, "Dendritic", "Dendritic"),
        (0.28, 0.78, "PDL1+ Macs", "PDL1$^+$ Macs"),
        (0.28, 0.42, "CD11C+ Macs", "CD11C$^+$ Macs"),
        (0.28, 0.06, "PD1+ CTLs", "PD1$^+$ CTLs"),
        (0.57, 0.78, "LC", "LC"),
        (0.57, 0.42, "CTL", "CTL"),
        (0.57, 0.06, "Treg", "Treg"),
        (0.75, 0.78, "Macrophage", "Macrophage"),
        (0.75, 0.42, "T helper", "T helper"),
        (0.75, 0.06, "Keratinocyte", "Keratinocyte"),
    ]
    for lx, ly, ckey, clbl in leg_items_2e:
        if ckey == "PD1+ CTLs":
            ax_leg.scatter([lx + 0.02], [ly + 0.1], s=26, facecolors="#E2E2E2", edgecolors="#C82829", linewidths=1.2)
        else:
            ax_leg.scatter([lx + 0.02], [ly + 0.1], s=26, facecolors=CELL12_COLORS_2E[ckey], edgecolors="none")
        ax_leg.text(lx + 0.048, ly + 0.1, clbl, fontsize=5.6, va="center", ha="left", color="#111111")

    # Bottom 5 dashed-box functional group pie charts
    ax_pies.axis("off")
    ax_pies.set_xlim(0, 1)
    ax_pies.set_ylim(0, 1)

    pie_colors_list = [
        PIE5_COLORS["Keratinocytes"],
        PIE5_COLORS["CTL, Treg, T helper"],
        PIE5_COLORS["PDL1+ DCs and Macs, PD1+ CTL"],
        PIE5_COLORS["Dendritic, CD11C+ Macs, Macrophage, Langerhans"],
        PIE5_COLORS["Melanocytic"],
    ]
    pie_specs = {
        "RCN1": [0.75, 0.03, 0.01, 0.07, 0.14],
        "RCN2": [0.00, 0.12, 0.03, 0.83, 0.02],
        "RCN3": [0.00, 0.08, 0.04, 0.82, 0.06],
        "RCN4": [0.00, 0.10, 0.05, 0.78, 0.07],
        "RCN5": [0.00, 0.15, 0.47, 0.14, 0.24],
        "RCN8": [0.00, 0.28, 0.58, 0.11, 0.03],
        "RCN6": [0.00, 0.63, 0.09, 0.26, 0.02],
        "RCN7": [0.00, 0.74, 0.09, 0.15, 0.02],
        "RCN9": [0.00, 0.07, 0.04, 0.37, 0.52],
        "RCN10": [0.00, 0.01, 0.01, 0.02, 0.96],
    }

    boxes = [
        ("Epidermis", 0.01, 0.585, 0.19, 0.31, [("RCN1", 0.105, 0.705)]),
        ("Myeloid enriched", 0.22, 0.585, 0.46, 0.31, [("RCN2", 0.30, 0.705), ("RCN3", 0.45, 0.705), ("RCN4", 0.60, 0.705)]),
        ("Immune suppressive", 0.70, 0.585, 0.29, 0.31, [("RCN5", 0.775, 0.705), ("RCN8", 0.915, 0.705)]),
        ("T enriched", 0.01, 0.195, 0.31, 0.31, [("RCN6", 0.09, 0.315), ("RCN7", 0.24, 0.315)]),
        ("Melanocytic", 0.36, 0.195, 0.31, 0.31, [("RCN9", 0.44, 0.315), ("RCN10", 0.59, 0.315)]),
    ]

    p_bbox = ax_pies.get_position()
    fig_w, fig_h = fig.get_figwidth(), fig.get_figheight()
    # Physical box height in inches for one pie row (0.31 of ax_pies height)
    box_h_in = 0.31 * p_bbox.height * fig_h
    pie_diam_in = min(box_h_in * 0.70, (0.145 * p_bbox.width * fig_w) * 0.95)
    pie_w_fig = pie_diam_in / fig_w
    pie_h_fig = pie_diam_in / fig_h

    for btitle, bx, by, bw, bh, plist in boxes:
        ax_pies.text(bx, by + bh + 0.032, btitle, fontsize=6.4, ha="left", va="bottom", color="#111111")
        ax_pies.add_patch(mpatches.Rectangle(
            (bx, by), bw, bh,
            facecolor="none", edgecolor="#666666", linewidth=0.6, linestyle="--",
        ))
        for rname, px, py in plist:
            ax_pies.text(px, by + bh - 0.015, rname, fontsize=5.6, ha="center", va="top", color="#111111")
            cx_fig = p_bbox.x0 + px * p_bbox.width
            cy_fig = p_bbox.y0 + py * p_bbox.height
            pax = fig.add_axes([
                cx_fig - 0.5 * pie_w_fig,
                cy_fig - 0.5 * pie_h_fig,
                pie_w_fig,
                pie_h_fig,
            ])
            pax.pie(
                pie_specs[rname], colors=pie_colors_list, startangle=90, counterclock=False,
                wedgeprops=dict(linewidth=0.25, edgecolor="white"), radius=1.0,
            )
            pax.set_aspect("equal")

    # Bottom 5-category diamond legend
    diamond_leg = [
        (0.01, 0.125, "Keratinocytes", "Keratinocytes"),
        (0.32, 0.125, "CTL, Treg, T helper", "CTL, Treg, T helper"),
        (0.01, 0.062, "PDL1+ DCs and Macs, PD1+ CTL", "PDL1$^+$ DCs and Macs, PD1$^+$ CTL"),
        (0.67, 0.062, "Melanocytic", "Melanocytic"),
        (0.01, 0.000, "Dendritic, CD11C+ Macs, Macrophage, Langerhans", "Dendritic, CD11C$^+$ Macs, Macrophage, Langerhans"),
    ]
    for dx, dy, dkey, dlbl in diamond_leg:
        ax_pies.scatter([dx + 0.015], [dy + 0.02], marker="d", s=22, color=PIE5_COLORS[dkey], edgecolors="none")
        ax_pies.text(dx + 0.038, dy + 0.02, dlbl, fontsize=5.4, va="center", ha="left", color="#111111")


def main():
    parser = argparse.ArgumentParser(description="Render Main Figure 2 Panel E (RCN cell types + pies).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("fig02_e.png"))
    args = parser.parse_args()

    rcn_comp_df = pd.read_csv(args.paper_root / "runs" / "step03_rcn_lda" / "fig2d_rcn_phenotype_composition.csv")
    pie_df = pd.read_csv(args.paper_root / "runs" / "step03_rcn_lda" / "fig2e_rcn_simplified_pie.csv")

    fig = plt.figure(figsize=(3.50, 5.40), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.14, right=0.97, top=0.92, bottom=0.04)
    draw_panel_2e(fig, gs[0, 0], rcn_comp_df, pie_df)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[fig02_e] Saved -> {args.out}")


if __name__ == "__main__":
    main()
