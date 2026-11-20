#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: fig07/F
Title: Immune & myeloid/T-cell fraction across progression stages (Normal, MIS, IM Dermis proxy for IR/MIS/bTIL)
Input tables: runs/step04_spatial_interaction/fig7fg_compartment_cell_composition.csv
Default size: 2.50 in x 2.10 in (300 dpi)
CLI usage:
  python fig07_f.py --paper-root <sources_root>/papers/pmc9167783 --out fig07_f.png
"""

import argparse
from pathlib import Path
import sys

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _fig_common import DEFAULT_PAPER_ROOT

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["pdf.fonttype"] = 42

COMP_7F_COLORS = {
    "PDL1+ DCs": "#188196",
    "PDL1+ Macs": "#215578",
    "Treg": "#EB1D69",
    "Exhausted CTL": "#EA7AA6",
    "PD1+ CTL": "#B61E24",
    "PD1- CTL": "#EBB64B",
}


def draw_panel_7f(fig, gs_slot, df_7fg: pd.DataFrame):
    """Draw Panel 7F (stacked T/PDL1+ immune fraction bars + non-clipping right legend) inside gs_slot."""
    from matplotlib.gridspec import GridSpecFromSubplotSpec
    sub_gs = GridSpecFromSubplotSpec(1, 2, subplot_spec=gs_slot, width_ratios=[1.0, 0.92], wspace=0.06)
    ax = fig.add_subplot(sub_gs[0, 0])
    ax_leg = fig.add_subplot(sub_gs[0, 1])
    ax.text(-0.42, 1.12, "F", transform=ax.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")

    # Aggregate immune subsets across Dermis compartments (Normal, MIS, IM)
    sub = df_7fg[df_7fg["compartment_proxy"] == "Dermis"].copy()
    stages = [("Normal", "N"), ("MIS", "MIS"), ("IM", "IM\n(bTIL\nproxy)")]
    avail = [(sk, sl) for sk, sl in stages if sk in sub["Stage"].values]

    cats = [
        ("PD1- CTL", ["CTL", "Th"]),
        ("PD1+ CTL", ["PD1+ CTL"]),
        ("Exhausted CTL", ["Tex"]),
        ("Treg", ["Treg"]),
        ("PDL1+ Macs", ["PD-L1+ mac"]),
        ("PDL1+ DCs", ["PD-L1+ DC"]),
    ]

    x_pos = np.arange(len(avail))
    mat = np.zeros((len(cats), len(avail)))
    for s_i, (sk, _) in enumerate(avail):
        row = sub[sub["Stage"] == sk].iloc[0]
        for c_i, (_, cols) in enumerate(cats):
            mat[c_i, s_i] = sum(float(row[c]) for c in cols if c in row.index)
    col_sums = np.where(mat.sum(axis=0, keepdims=True) > 1e-9, mat.sum(axis=0, keepdims=True), 1.0)
    mat_norm = mat / col_sums

    bottoms = np.zeros(len(avail))
    for c_i, (cname, _) in enumerate(cats):
        ax.bar(x_pos, mat_norm[c_i], bottom=bottoms, width=0.68, color=COMP_7F_COLORS[cname], edgecolor="white", lw=0.3)
        bottoms += mat_norm[c_i]

    ax.set_xticks(x_pos)
    ax.set_xticklabels([sl for _, sl in avail], fontsize=5.3)
    ax.set_yticks([0.0, 0.5, 1.0])
    ax.set_yticklabels(["0.0", "0.5", "1.0"], fontsize=5.6)
    ax.set_ylim(0, 1.02)
    ax.set_ylabel("Fraction of cells", fontsize=6.2, labelpad=2)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.spines["left"].set_linewidth(0.7)
    ax.spines["bottom"].set_linewidth(0.7)

    ax_leg.axis("off")
    handles = [mpatches.Patch(facecolor=COMP_7F_COLORS[cname], label=cname.replace("+", "$^+$").replace("-", "$^-$")) for cname, _ in reversed(cats)]
    ax_leg.legend(handles=handles, loc="center left", frameon=False, fontsize=5.1, handlelength=0.80, handleheight=0.80, labelspacing=0.30, borderaxespad=0.0)
    return ax


def main():
    parser = argparse.ArgumentParser(description="Render Main Figure 7 Panel F (immune composition).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("fig07_f.png"))
    args = parser.parse_args()

    df_7fg = pd.read_csv(args.paper_root / "runs" / "step04_spatial_interaction" / "fig7fg_compartment_cell_composition.csv")
    fig = plt.figure(figsize=(2.60, 2.10), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.18, right=0.58, top=0.88, bottom=0.18)
    draw_panel_7f(fig, gs[0, 0], df_7fg)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[fig07_f] Saved -> {args.out}")


if __name__ == "__main__":
    main()
