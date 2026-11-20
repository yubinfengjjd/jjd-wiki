#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: sfig07/E
Title: IRF1 horizontal barplot across bTIL, IB, IM mROIs
Input tables: runs/step06_mrseq_deseq2/figs7e_irf1_bTIL_IB_IM.csv
Default size: 3.30 in x 1.30 in (300 dpi)
CLI usage:
  python sfig07_e.py --paper-root <sources_root>/papers/pmc9167783 --out sfig07_e.png
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


def draw_panel_s7e(fig, gs_slot, df_s7e: pd.DataFrame):
    """Draw Panel S7E (IRF1 horizontal barplot + SEM + jitter + right legend) inside gs_slot."""
    sub_gs = GridSpecFromSubplotSpec(1, 2, subplot_spec=gs_slot, width_ratios=[1.25, 1.05], wspace=0.14)
    ax = fig.add_subplot(sub_gs[0, 0])
    ax_leg = fig.add_subplot(sub_gs[0, 1])

    ax.text(-0.28, 1.26, "E", transform=ax.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    ax.set_title("IRF1", fontsize=7.0, pad=10)

    sites = [("bTIL", "#D46AA0"), ("IB", "#7E9E44"), ("IM", "#B8862D")]
    vals_list = [df_s7e.loc[df_s7e["site"] == s, "log2_expr"].to_numpy() for s, _ in sites]
    means = [float(np.mean(v)) if len(v) else 0.0 for v in vals_list]
    sems = [float(stats.sem(v)) if len(v) > 1 else 0.0 for v in vals_list]

    y = np.arange(len(sites))
    ax.barh(y, means, height=0.68, color=[c for _, c in sites], edgecolor="none", zorder=2)
    ax.errorbar(means, y, xerr=sems, fmt="none", ecolor="#222222", elinewidth=0.75, capsize=1.8, capthick=0.75, zorder=4)
    rng = np.random.default_rng(42)
    for yi, v in enumerate(vals_list):
        if len(v):
            jit = rng.uniform(-0.16, 0.16, size=len(v))
            ax.scatter(v, np.full(len(v), yi) + jit, s=2.6, color="#2A3240", alpha=0.75, zorder=3)

    xmax = max([np.max(v) if len(v) else 0.0 for v in vals_list] + [1.0])
    for ya, yb, xl in [(0, 1, xmax * 1.04), (1, 2, xmax * 1.14)]:
        v1, v2 = vals_list[ya], vals_list[yb]
        _, pv = stats.ttest_ind(v1, v2, equal_var=False) if len(v1) >= 2 and len(v2) >= 2 else (0, 1.0)
        sig = "**" if pv < 0.01 else ("*" if pv < 0.05 else "ns")
        cs = "#C62828" if sig != "ns" else "#444444"
        ax.plot([xl, xl], [ya, yb], color=cs, lw=0.75)
        ax.text(xl + xmax * 0.02, 0.5 * (ya + yb), sig, rotation=270, ha="left", va="center", fontsize=5.8, color=cs)

    ax.set_yticks(y)
    ax.set_yticklabels([s for s, _ in sites], rotation=90, fontsize=5.8, va="center")
    ax.invert_yaxis()
    ax.set_xlim(0, xmax * 1.28)
    ax.xaxis.tick_top()
    ax.xaxis.set_label_position("top")
    ax.set_xlabel("Expression (log$_2$)", fontsize=5.8, labelpad=2)
    ax.tick_params(axis="x", labelsize=5.2, length=2.0, pad=1.2)
    ax.spines["bottom"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.spines["left"].set_linewidth(0.7)
    ax.spines["top"].set_linewidth(0.7)

    ax_leg.axis("off")
    handles = [
        mpatches.Patch(facecolor="#D46AA0", label="Brisk TIL (bTIL)"),
        mpatches.Patch(facecolor="#7E9E44", label="Invasive boundary (IB)"),
        mpatches.Patch(facecolor="#B8862D", label="Invasive melanoma (IM)"),
    ]
    ax_leg.legend(handles=handles, loc="center left", frameon=False, fontsize=5.1, handlelength=0.85, handleheight=0.8, labelspacing=0.3)
    return ax


def main():
    parser = argparse.ArgumentParser(description="Render Supp Figure S7 Panel E (IRF1).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("sfig07_e.png"))
    args = parser.parse_args()

    df_s7e = pd.read_csv(args.paper_root / "runs" / "step06_mrseq_deseq2" / "figs7e_irf1_bTIL_IB_IM.csv")
    fig = plt.figure(figsize=(3.30, 1.40), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.14, right=0.97, top=0.72, bottom=0.08)
    draw_panel_s7e(fig, gs[0, 0], df_s7e)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[sfig07_e] Saved -> {args.out}")


if __name__ == "__main__":
    main()
