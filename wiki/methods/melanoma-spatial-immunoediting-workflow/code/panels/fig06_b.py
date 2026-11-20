#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: fig06/B
Title: Melanoma lineage markers (PMEL, MITF, MLANA, CSPG4, TYR) across MIS, Immune, and Tumor
Input tables: runs/step06_mrseq_deseq2/fig6b_melanoma_markers_long.csv
Default size: 3.10 in x 2.20 in (300 dpi)
CLI usage:
  python fig06_b.py --paper-root <sources_root>/papers/pmc9167783 --out fig06_b.png
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
from scipy import stats

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _fig_common import DEFAULT_PAPER_ROOT

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["pdf.fonttype"] = 42

GRP3_COLORS = {
    "MIS": "#689892",
    "Immune": "#EB582B",
    "Tumor": "#EBE3B5",
}


def _sig_label(p: float) -> str:
    if not np.isfinite(p):
        return "ns"
    if p < 0.001:
        return "***"
    if p < 0.01:
        return "**"
    if p < 0.05:
        return "*"
    return "ns"


def draw_panel_6b(fig, gs_slot, df_6b: pd.DataFrame):
    """Draw Panel 6B (5 faceted barplots + SEM + jitter + red sig brackets + legend) inside gs_slot."""
    sub_gs = GridSpecFromSubplotSpec(2, 3, subplot_spec=gs_slot, hspace=0.45, wspace=0.35)
    genes = ["PMEL", "MITF", "MLANA", "CSPG4", "TYR"]
    groups = ["MIS", "Immune", "Tumor"]
    rng = np.random.default_rng(42)

    axes = []
    for idx, gene in enumerate(genes):
        r, c = divmod(idx, 3)
        ax = fig.add_subplot(sub_gs[r, c])
        axes.append(ax)
        sub = df_6b[df_6b["gene"] == gene]

        means, sems, vals_list = [], [], []
        for g in groups:
            v = sub.loc[sub["group"] == g, "log2_expr"].to_numpy()
            vals_list.append(v)
            means.append(np.mean(v) if len(v) else 0.0)
            sems.append(stats.sem(v) if len(v) > 1 else 0.0)

        x_pos = np.arange(len(groups))
        ax.bar(
            x_pos, means, width=0.68,
            color=[GRP3_COLORS[g] for g in groups],
            edgecolor="none", zorder=2,
        )
        ax.errorbar(
            x_pos, means, yerr=sems, fmt="none", ecolor="#222222",
            elinewidth=0.75, capsize=2.0, capthick=0.75, zorder=4,
        )
        for xi, v in enumerate(vals_list):
            if len(v):
                jit = rng.uniform(-0.18, 0.18, size=len(v))
                ax.scatter(np.full(len(v), xi) + jit, v, s=2.2, color="#2A3240", alpha=0.75, zorder=3)

        ymax_pts = max([np.max(v) if len(v) else 0 for v in vals_list] + [1.0])
        # Compute MIS vs Immune and Immune vs Tumor significance
        _, p_mi = stats.ttest_ind(vals_list[0], vals_list[1], equal_var=False)
        _, p_it = stats.ttest_ind(vals_list[1], vals_list[2], equal_var=False)
        _, p_mt = stats.ttest_ind(vals_list[0], vals_list[2], equal_var=False)

        y1 = ymax_pts * 1.04
        y2 = ymax_pts * 1.15
        for (xa, xb, pv, y_lvl) in [(0, 1, p_mi, y1), (1, 2, p_it, y1), (0, 2, p_mt, y2)]:
            sl = _sig_label(pv)
            col_sig = "#C62828" if sl != "ns" else "#444444"
            ax.plot([xa, xb], [y_lvl, y_lvl], color=col_sig, lw=0.75)
            ax.text(0.5 * (xa + xb), y_lvl + ymax_pts * 0.01, sl, ha="center", va="bottom",
                    fontsize=6.2 if sl != "ns" else 5.5, color=col_sig, fontweight="bold" if sl != "ns" else "normal")

        ax.set_title(gene, fontsize=7.0, pad=3)
        ax.set_ylim(0, ymax_pts * 1.28)
        ax.set_xticks([])
        ax.tick_params(axis="y", labelsize=5.6, length=2.5, pad=1.5)
        ax.spines["top"].set_visible(False)
        ax.spines["right"].set_visible(False)
        ax.spines["left"].set_linewidth(0.65)
        ax.spines["bottom"].set_linewidth(0.65)

    axes[0].text(-0.55, 1.32, "B", transform=axes[0].transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    # Shared Y-axis label on left column
    fig.text(
        axes[0].get_position().x0 - 0.036,
        0.5 * (axes[0].get_position().y0 + axes[3].get_position().y1) if len(axes) > 3 else axes[0].get_position().y0,
        "Expression (log$_2$)", rotation=90, va="center", ha="center", fontsize=6.8,
    )

    # Slot [1, 2] for 3-group legend
    ax_leg = fig.add_subplot(sub_gs[1, 2])
    ax_leg.axis("off")
    handles = [mpatches.Patch(facecolor=GRP3_COLORS[g], label=g) for g in groups]
    ax_leg.legend(handles=handles, loc="center left", frameon=False, fontsize=6.5, handlelength=1.1, handleheight=1.1, labelspacing=0.45)
    return axes


def main():
    parser = argparse.ArgumentParser(description="Render Main Figure 6 Panel B (5 melanoma markers).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("fig06_b.png"))
    args = parser.parse_args()

    df_6b = pd.read_csv(args.paper_root / "runs" / "step06_mrseq_deseq2" / "fig6b_melanoma_markers_long.csv")
    fig = plt.figure(figsize=(3.10, 2.20), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.14, right=0.97, top=0.86, bottom=0.06)
    draw_panel_6b(fig, gs[0, 0], df_6b)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[fig06_b] Saved -> {args.out}")


if __name__ == "__main__":
    main()
