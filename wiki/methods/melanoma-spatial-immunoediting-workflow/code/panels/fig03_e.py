#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: fig03/E
Title: Multi-stage horizontal boxenplot of distance from RCN10 (log scale 6, 90, 1,000 um)
Input tables:
  - runs/step03_rcn_lda/fig3e_rcn_to_rcn10_distances.csv
  - runs/step03_rcn_lda/fig3e_rcn_to_rcn10_ttests.csv
Default size: 5.20 in x 1.90 in (300 dpi)
CLI usage:
  python fig03_e.py --paper-root <sources_root>/papers/pmc9167783 --out fig03_e.png
"""

import argparse
from pathlib import Path
import sys

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpecFromSubplotSpec
import numpy as np
import pandas as pd
import seaborn as sns

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _fig_common import DEFAULT_PAPER_ROOT
from fig03_a import RCN_COLORS_FIG3

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["pdf.fonttype"] = 42


def draw_panel_3e(fig, gs_slot, dist_df: pd.DataFrame, ttest_df: pd.DataFrame):
    """Draw Panel 3E (4-stage horizontal boxenplot distance from RCN10 + red sig asterisks) inside gs_slot."""
    rcn_order = ["RCN2", "RCN3", "RCN4", "RCN5", "RCN8", "RCN6", "RCN7"]
    rcn_short = ["2", "3", "4", "5", "8", "6", "7"]
    palette_3e = {r: RCN_COLORS_FIG3[r] for r in rcn_order}

    stages = [
        ("Normal", "Normal", None),
        ("Precursor", "Precursor", ("Normal", "Precursor", "N vs. P")),
        ("MIS", "MIS", ("Normal", "MIS", "N vs. MIS")),
        ("IM", "IM", ("MIS", "IM", "MIS vs. IM")),
    ]

    sub_gs = GridSpecFromSubplotSpec(1, 4, subplot_spec=gs_slot, wspace=0.14)
    axes = []
    for idx, (st_key, st_title, comp_info) in enumerate(stages):
        ax = fig.add_subplot(sub_gs[0, idx])
        axes.append(ax)
        sub = dist_df[(dist_df["Stage"] == st_key) & (dist_df["RCN"].isin(rcn_order))].copy()
        sub["dist_plot"] = np.clip(sub["dist_to_RCN10_um"].to_numpy(), 5.0, 2000.0)

        for rx in (6, 90, 1000):
            ax.axvline(rx, color="#999999", linestyle="--", linewidth=0.65, zorder=1)

        if not sub.empty:
            sns.boxenplot(
                data=sub,
                x="dist_plot",
                y="RCN",
                hue="RCN",
                order=rcn_order,
                palette=palette_3e,
                legend=False,
                orient="h",
                ax=ax,
                linewidth=0.5,
                flier_kws=dict(marker="d", s=2.2, color="#444444", alpha=0.75),
                zorder=3,
            )
        else:
            ax.set_yticks(np.arange(len(rcn_order)))
            ax.text(0.5, 0.5, "0 RCN10\nin sample FOV", transform=ax.transAxes,
                    ha="center", va="center", fontsize=5.8, color="#666666",
                    bbox=dict(boxstyle="round,pad=0.25", facecolor="#F7F7F7", edgecolor="#CCCCCC", lw=0.5))

        ax.set_xscale("log")
        ax.set_xlim(4.0, 1800.0)
        ax.set_xticks([6, 90, 1000])
        ax.set_xticklabels(["6", "90", "1,000"], fontsize=5.8)
        ax.set_title(st_title, fontsize=7.0, pad=4)
        ax.set_xlabel("")
        ax.set_ylabel("")

        ax.set_yticks(np.arange(len(rcn_order)))
        if idx == 0:
            ax.set_yticklabels(rcn_short, fontsize=6.4)
            ax.set_ylabel("RCN", fontsize=6.8, labelpad=2)
        else:
            ax.set_yticklabels([])
            ax.tick_params(axis="y", length=0)

        # Red comparison header & significance asterisks on right edge
        if comp_info is not None:
            s1, s2, clbl = comp_info
            ax.text(1.02, 1.04, clbl, transform=ax.transAxes, ha="right", va="bottom", fontsize=5.8, color="#E31A1C")
            for r_i, r_name in enumerate(rcn_order):
                row_t = ttest_df[(ttest_df["RCN"] == r_name) & (ttest_df["stage_1"] == s1) & (ttest_df["stage_2"] == s2)]
                if not row_t.empty and np.isfinite(row_t["p_value"].iloc[0]) and row_t["p_value"].iloc[0] < 0.05:
                    ax.text(1700.0, r_i, "*", ha="left", va="center", fontsize=8.0, color="#E31A1C", fontweight="bold", clip_on=False)

        ax.spines["top"].set_visible(False)
        ax.spines["right"].set_visible(False)
        ax.spines["left"].set_linewidth(0.65)
        ax.spines["bottom"].set_linewidth(0.65)

    axes[0].text(-0.34, 1.18, "E", transform=axes[0].transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    fig.text(
        0.5 * (axes[0].get_position().x0 + axes[-1].get_position().x1),
        axes[0].get_position().y0 - 0.022,
        "Distance from RCN10 (μm)", ha="center", va="top", fontsize=6.6,
    )
    return axes


def main():
    parser = argparse.ArgumentParser(description="Render Main Figure 3 Panel E (RCN-to-RCN10 boxenplot).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("fig03_e.png"))
    args = parser.parse_args()

    dist_df = pd.read_csv(args.paper_root / "runs" / "step03_rcn_lda" / "fig3e_rcn_to_rcn10_distances.csv")
    ttest_df = pd.read_csv(args.paper_root / "runs" / "step03_rcn_lda" / "fig3e_rcn_to_rcn10_ttests.csv")

    fig = plt.figure(figsize=(5.30, 1.95), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.10, right=0.96, top=0.82, bottom=0.22)
    draw_panel_3e(fig, gs[0, 0], dist_df, ttest_df)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[fig03_e] Saved -> {args.out}")


if __name__ == "__main__":
    main()
