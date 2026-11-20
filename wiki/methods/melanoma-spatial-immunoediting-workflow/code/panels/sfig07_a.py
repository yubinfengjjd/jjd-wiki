#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: sfig07/A
Title: IFNG expression across MIS, bTIL, IB, IM mROIs (PickSeq proxy)
Input tables: runs/step06_mrseq_deseq2/figs7a_ifng_proxy.csv
Default size: 1.80 in x 2.00 in (300 dpi)
CLI usage:
  python sfig07_a.py --paper-root <sources_root>/papers/pmc9167783 --out sfig07_a.png
"""

import argparse
from pathlib import Path
import sys

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from scipy import stats

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _fig_common import DEFAULT_PAPER_ROOT

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["pdf.fonttype"] = 42

SITE_COLS_S7 = {"MIS": "#689892", "bTIL": "#D46AA0", "IB": "#9AB86E", "IM": "#C69D53"}


def draw_panel_s7a(fig, gs_slot, df_s7a: pd.DataFrame):
    """Draw Panel S7A (IFNG barplot + SEM + jitter) inside gs_slot."""
    ax = fig.add_subplot(gs_slot)
    ax.text(-0.32, 1.15, "A", transform=ax.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    ax.set_title("IFNG (proxy)", fontsize=7.0, pad=4)

    sites = ["MIS", "bTIL", "IB", "IM"]
    vals_list = [df_s7a.loc[df_s7a["site"] == s, "log2_expr"].to_numpy() for s in sites]
    means = [float(np.mean(v)) if len(v) else 0.0 for v in vals_list]
    sems = [float(stats.sem(v)) if len(v) > 1 else 0.0 for v in vals_list]

    ax.bar(range(len(sites)), means, width=0.72, color=[SITE_COLS_S7[s] for s in sites], edgecolor="none", zorder=2)
    ax.errorbar(range(len(sites)), means, yerr=sems, fmt="none", ecolor="#222222", elinewidth=0.75, capsize=1.8, capthick=0.75, zorder=4)
    rng = np.random.default_rng(42)
    for xi, v in enumerate(vals_list):
        if len(v):
            jit = rng.uniform(-0.16, 0.16, size=len(v))
            ax.scatter(np.full(len(v), xi) + jit, v, s=2.6, color="#2A3240", alpha=0.75, zorder=3)

    ymax = max([np.max(v) if len(v) else 0.0 for v in vals_list] + [1.0])
    for xa, xb, yl in [(0, 1, ymax * 1.05), (0, 2, ymax * 1.15)]:
        v1, v2 = vals_list[xa], vals_list[xb]
        _, pv = stats.ttest_ind(v1, v2, equal_var=False) if len(v1) >= 2 and len(v2) >= 2 else (0, 1.0)
        sig = "**" if pv < 0.01 else ("*" if pv < 0.05 else "ns")
        cs = "#C62828" if sig != "ns" else "#444444"
        ax.plot([xa, xb], [yl, yl], color=cs, lw=0.75)
        ax.text(0.5 * (xa + xb), yl + ymax * 0.015, sig, ha="center", va="bottom", fontsize=5.8, color=cs)

    ax.set_xticks(range(len(sites)))
    ax.set_xticklabels(sites, rotation=90, fontsize=5.8)
    ax.set_ylim(0, ymax * 1.28)
    ax.set_ylabel("Expression (log$_2$)", fontsize=6.2, labelpad=2)
    ax.tick_params(axis="y", labelsize=5.4, length=2.0, pad=1.5)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.spines["left"].set_linewidth(0.7)
    ax.spines["bottom"].set_linewidth(0.7)
    return ax


def main():
    parser = argparse.ArgumentParser(description="Render Supp Figure S7 Panel A (IFNG).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("sfig07_a.png"))
    args = parser.parse_args()

    df_s7a = pd.read_csv(args.paper_root / "runs" / "step06_mrseq_deseq2" / "figs7a_ifng_proxy.csv")
    fig = plt.figure(figsize=(1.80, 2.10), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.26, right=0.95, top=0.84, bottom=0.18)
    draw_panel_s7a(fig, gs[0, 0], df_s7a)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[sfig07_a] Saved -> {args.out}")


if __name__ == "__main__":
    main()
