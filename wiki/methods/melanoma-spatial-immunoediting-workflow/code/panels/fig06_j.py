#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: fig06/J
Title: S100B module mean expression across ordered mROIs with bottom 6-stage bar
Input tables: runs/step07_network_survival/fig6j_s100b_module_curve.csv
Default size: 3.10 in x 2.00 in (300 dpi)
CLI usage:
  python fig06_j.py --paper-root <sources_root>/papers/pmc9167783 --out fig06_j.png
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

SITE_ORDER_6 = ["MIS", "IR", "bTIL", "IB", "IM", "EM"]
SITE_COLORS_6 = {
    "MIS": "#1E9C78",
    "IR": "#B86646",
    "bTIL": "#C84B93",
    "IB": "#85A933",
    "IM": "#C69032",
    "EM": "#666666",
}


def draw_panel_6j(fig, gs_slot, curve_df: pd.DataFrame):
    """Draw Panel 6J (ordered S100B module expression curve + bottom 6-stage color bar) inside gs_slot."""
    # Group by site order (MIS, IR, bTIL, IB, IM, EM) and sort within each site by mean_log2_norm
    df = curve_df.copy()
    df["site_cat"] = pd.Categorical(df["site"], categories=SITE_ORDER_6, ordered=True)
    df = df.sort_values(["site_cat", "sample_id"]).reset_index(drop=True)

    sub_gs = GridSpecFromSubplotSpec(2, 1, subplot_spec=gs_slot, height_ratios=[1.0, 0.08], hspace=0.04)
    ax_line = fig.add_subplot(sub_gs[0, 0])
    ax_bar = fig.add_subplot(sub_gs[1, 0])

    ax_line.text(-0.24, 1.06, "J", transform=ax_line.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")

    x = np.arange(len(df))
    y = df["mean_log2_norm"].to_numpy()
    ax_line.plot(x, y, color="#111111", linewidth=0.75, zorder=2)
    ax_line.scatter(x, y, s=5.0, color="#111111", zorder=3)

    ax_line.set_xlim(-1, len(df))
    ax_line.set_ylim(0, max(y.max() * 1.12, 8.2))
    ax_line.set_ylabel("Mean expression (log$_2$)\nS100B module", fontsize=6.4, labelpad=2)
    ax_line.set_xticks([])
    ax_line.tick_params(axis="y", labelsize=5.8, length=2.5, pad=1.5)
    for sp in ax_line.spines.values():
        sp.set_linewidth(0.7)
        sp.set_color("#222222")

    # Top-left 6-stage legend
    handles = [mpatches.Patch(facecolor=SITE_COLORS_6[s], label=s) for s in SITE_ORDER_6]
    ax_line.legend(
        handles=handles, loc="upper left", bbox_to_anchor=(0.02, 0.98),
        frameon=False, fontsize=5.8, handlelength=0.9, handleheight=0.9, labelspacing=0.25,
    )

    # Bottom site color bar
    ax_bar.set_xlim(-1, len(df))
    ax_bar.set_ylim(0, 1)
    for i, st in enumerate(df["site"]):
        ax_bar.add_patch(mpatches.Rectangle((i - 0.5, 0), 1.0, 1.0, facecolor=SITE_COLORS_6[st], edgecolor="none"))
    ax_bar.set_xlabel("mROI", fontsize=6.6, labelpad=2)
    ax_bar.set_xticks([])
    ax_bar.set_yticks([])
    for sp in ax_bar.spines.values():
        sp.set_visible(False)
    return ax_line


def main():
    parser = argparse.ArgumentParser(description="Render Main Figure 6 Panel J (S100B module curve).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("fig06_j.png"))
    args = parser.parse_args()

    curve_df = pd.read_csv(args.paper_root / "runs" / "step07_network_survival" / "fig6j_s100b_module_curve.csv")
    fig = plt.figure(figsize=(3.10, 2.00), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.20, right=0.96, top=0.92, bottom=0.14)
    draw_panel_6j(fig, gs[0, 0], curve_df)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[fig06_j] Saved -> {args.out}")


if __name__ == "__main__":
    main()
