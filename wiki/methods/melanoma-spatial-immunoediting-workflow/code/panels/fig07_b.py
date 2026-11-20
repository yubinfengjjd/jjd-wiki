#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: fig07/B
Title: Immune chemokine & checkpoint expression (CXCL10, CXCL11, IDO1, MIF, CD74) across sites
Input tables: runs/step06_mrseq_deseq2/fig7b_immune_chemokines_long.csv
Default size: 4.10 in x 2.90 in (300 dpi)
CLI usage:
  python fig07_b.py --paper-root <sources_root>/papers/pmc9167783 --out fig07_b.png
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
from scipy import stats

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _fig_common import DEFAULT_PAPER_ROOT

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["pdf.fonttype"] = 42

SITE_COLORS_7B = {
    "IR": "#DA7E5A",
    "bTIL": "#D46AA0",
    "IB": "#9AB86E",
    "IM": "#C69D53",
    "EM": "#8A8A8A",
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


def draw_panel_7b(fig, gs_slot, df_7b: pd.DataFrame):
    """Draw Panel 7B (5-gene chemokine barplots + SEM + jitter + red sig brackets) inside gs_slot."""
    sub_gs = GridSpecFromSubplotSpec(2, 6, subplot_spec=gs_slot, hspace=0.52, wspace=0.55)
    specs = [
        ("CXCL10", ["bTIL", "IB", "IM"], sub_gs[0, 0:3]),
        ("CXCL11", ["bTIL", "IB", "IM"], sub_gs[0, 3:6]),
        ("IDO1",   ["bTIL", "IB", "IM"], sub_gs[1, 0:2]),
        ("MIF",    ["IR", "bTIL", "IB", "IM", "EM"], sub_gs[1, 2:4]),
        ("CD74",   ["bTIL", "IB", "IM", "EM"], sub_gs[1, 4:6]),
    ]

    rng = np.random.default_rng(42)
    axes = []
    for idx, (gene, site_list, slot) in enumerate(specs):
        ax = fig.add_subplot(slot)
        axes.append(ax)
        sub = df_7b[df_7b["gene"] == gene]
        vals_list = [sub.loc[sub["site"] == s, "log2_expr"].to_numpy() for s in site_list]
        means = [np.mean(v) if len(v) else 0.0 for v in vals_list]
        sems = [stats.sem(v) if len(v) > 1 else 0.0 for v in vals_list]
        cols = [SITE_COLORS_7B[s] for s in site_list]

        x_pos = np.arange(len(site_list))
        ax.bar(x_pos, means, width=0.72, color=cols, edgecolor="none", zorder=2)
        ax.errorbar(x_pos, means, yerr=sems, fmt="none", ecolor="#222222", elinewidth=0.75, capsize=1.8, capthick=0.75, zorder=4)
        for xi, v in enumerate(vals_list):
            if len(v):
                jit = rng.uniform(-0.18, 0.18, size=len(v))
                ax.scatter(np.full(len(v), xi) + jit, v, s=2.2, color="#2A3240", alpha=0.72, zorder=3)

        ymax_p = max([np.max(v) if len(v) else 0 for v in vals_list] + [1.0])
        # Key pairwise comparisons
        if gene in ("CXCL10", "CXCL11", "IDO1"):
            pairs = [(0, 1, ymax_p * 1.05), (1, 2, ymax_p * 1.15)]
        elif gene == "MIF":
            pairs = [(0, 1, ymax_p * 1.04), (1, 2, ymax_p * 1.15), (2, 3, ymax_p * 1.04)]
        else:
            pairs = [(0, 1, ymax_p * 1.05), (2, 3, ymax_p * 1.14)]

        for xa, xb, yl in pairs:
            v1, v2 = vals_list[xa], vals_list[xb]
            _, pv = stats.ttest_ind(v1, v2, equal_var=False) if len(v1) >= 2 and len(v2) >= 2 else (0, 1.0)
            sl = _sig_label(pv)
            cs = "#C62828" if sl != "ns" else "#444444"
            ax.plot([xa, xb], [yl, yl], color=cs, lw=0.75)
            ax.text(0.5 * (xa + xb), yl + ymax_p * 0.015, sl, ha="center", va="bottom",
                    fontsize=6.2 if sl != "ns" else 5.2, color=cs, fontweight="bold" if sl != "ns" else "normal")

        ax.set_title(gene, fontsize=6.8, pad=4)
        ax.set_xticks(x_pos)
        ax.set_xticklabels(site_list, fontsize=5.6)
        ax.set_ylim(0, ymax_p * 1.28)
        ax.tick_params(axis="y", labelsize=5.4, length=2.2, pad=1.5)
        ax.spines["top"].set_visible(False)
        ax.spines["right"].set_visible(False)
        ax.spines["left"].set_linewidth(0.65)
        ax.spines["bottom"].set_linewidth(0.65)

    axes[0].text(-0.28, 1.20, "B", transform=axes[0].transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    fig.text(
        axes[0].get_position().x0 - 0.038,
        0.5 * (axes[0].get_position().y0 + axes[2].get_position().y1),
        "Expression (log$_2$)", rotation=90, ha="center", va="center", fontsize=6.8,
    )
    return axes


def main():
    parser = argparse.ArgumentParser(description="Render Main Figure 7 Panel B (chemokines).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("fig07_b.png"))
    args = parser.parse_args()

    df_7b = pd.read_csv(args.paper_root / "runs" / "step06_mrseq_deseq2" / "fig7b_immune_chemokines_long.csv")
    fig = plt.figure(figsize=(4.20, 3.00), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.14, right=0.97, top=0.88, bottom=0.10)
    draw_panel_7b(fig, gs[0, 0], df_7b)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[fig07_b] Saved -> {args.out}")


if __name__ == "__main__":
    main()
