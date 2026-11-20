#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: fig03/D
Title: Cross-stage RCN1-10 composition stacked bar chart (N, P, MIS, IM)
Input tables: runs/step03_rcn_lda/fig3d_rcn_proportions_by_stage.csv
Default size: 1.90 in x 2.80 in (300 dpi)
CLI usage:
  python fig03_d.py --paper-root <sources_root>/papers/pmc9167783 --out fig03_d.png
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
from fig03_a import RCN_COLORS_FIG3

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["pdf.fonttype"] = 42


def draw_panel_3d(fig, gs_slot, prop_df: pd.DataFrame):
    """Draw Panel 3D (RCN1-10 stacked proportion bars across stages) inside gs_slot."""
    ax = fig.add_subplot(gs_slot)
    ax.text(-0.32, 1.24, "D", transform=ax.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")

    stage_map = [("Normal", "N"), ("Precursor", "P"), ("MIS", "MIS"), ("IM", "IM"), ("EM", "EM")]
    avail = [(sf, sl) for sf, sl in stage_map if sf in prop_df["Stage"].values]
    rcn_order = [f"RCN{i}" for i in range(1, 11)]

    x_pos = np.arange(len(avail))
    bottoms = np.zeros(len(avail))
    for rcn in rcn_order:
        vals = []
        for sf, _ in avail:
            row = prop_df[prop_df["Stage"] == sf]
            vals.append(float(row[rcn].iloc[0]) if (not row.empty and rcn in row.columns) else 0.0)
        vals = np.array(vals)
        ax.bar(x_pos, vals, bottom=bottoms, width=0.72, color=RCN_COLORS_FIG3[rcn], edgecolor="white", linewidth=0.35, label=rcn)
        bottoms += vals

    ax.set_xticks(x_pos)
    ax.set_xticklabels([sl for _, sl in avail], fontsize=6.5)
    ax.set_yticks([0.0, 0.5, 1.0])
    ax.set_yticklabels(["0", "0.5", "1.0"], fontsize=6.2)
    ax.set_ylim(0, 1.02)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.spines["left"].set_linewidth(0.7)
    ax.spines["bottom"].set_linewidth(0.7)

    handles = [mpatches.Patch(facecolor=RCN_COLORS_FIG3[r], label=r) for r in rcn_order]
    ax.legend(
        handles=handles, loc="lower center", bbox_to_anchor=(0.45, 1.01),
        ncol=4, frameon=False, fontsize=4.8, handlelength=0.85, handleheight=0.55,
        handletextpad=0.25, columnspacing=0.45, labelspacing=0.20,
    )
    return ax


def main():
    parser = argparse.ArgumentParser(description="Render Main Figure 3 Panel D (RCN stage proportions).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("fig03_d.png"))
    args = parser.parse_args()

    prop_df = pd.read_csv(args.paper_root / "runs" / "step03_rcn_lda" / "fig3d_rcn_proportions_by_stage.csv")
    fig = plt.figure(figsize=(2.10, 2.80), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.24, right=0.95, top=0.72, bottom=0.12)
    draw_panel_3d(fig, gs[0, 0], prop_df)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[fig03_d] Saved -> {args.out}")


if __name__ == "__main__":
    main()
