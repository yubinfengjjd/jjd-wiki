#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: fig06/F
Title: IM vs EM expression of MYC, NFKB1, IGFBP2, IGF1R, BCL2A1
Input tables: runs/step06_mrseq_deseq2/fig6f_im_vs_em_genes_long.csv
Default size: 3.10 in x 1.75 in (300 dpi)
CLI usage:
  python fig06_f.py --paper-root <sources_root>/papers/pmc9167783 --out fig06_f.png
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


def draw_panel_6f(fig, gs_slot, df_6f: pd.DataFrame):
    """Draw Panel 6F (5-gene IM vs EM barplots + jitter + SEM + red sig brackets) inside gs_slot."""
    genes = ["MYC", "NFKB1", "IGFBP2", "IGF1R", "BCL2A1"]
    sub_gs = GridSpecFromSubplotSpec(1, 5, subplot_spec=gs_slot, wspace=0.45)
    colors = ["#C49B4E", "#8A8A8A"]
    rng = np.random.default_rng(42)

    axes = []
    for idx, g in enumerate(genes):
        ax = fig.add_subplot(sub_gs[0, idx])
        axes.append(ax)
        sub = df_6f[df_6f["gene"] == g]
        v_im = sub.loc[sub["group"] == "IM", "log2_expr"].to_numpy()
        v_em = sub.loc[sub["group"] == "EM", "log2_expr"].to_numpy()
        vals_list = [v_im, v_em]
        means = [np.mean(v) if len(v) else 0.0 for v in vals_list]
        sems = [stats.sem(v) if len(v) > 1 else 0.0 for v in vals_list]

        ax.bar([0, 1], means, width=0.68, color=colors, edgecolor="none", zorder=2)
        ax.errorbar([0, 1], means, yerr=sems, fmt="none", ecolor="#222222",
                    elinewidth=0.75, capsize=2.0, capthick=0.75, zorder=4)
        for xi, v in enumerate(vals_list):
            if len(v):
                jit = rng.uniform(-0.18, 0.18, size=len(v))
                ax.scatter(np.full(len(v), xi) + jit, v, s=2.4, color="#2A3240", alpha=0.75, zorder=3)

        _, pv = stats.ttest_ind(v_im, v_em, equal_var=False) if len(v_im) >= 2 and len(v_em) >= 2 else (0, 1.0)
        sl = _sig_label(pv)
        ymax_p = max([np.max(v) if len(v) else 0 for v in vals_list] + [1.0])
        y_bar = ymax_p * 1.06
        col_s = "#C62828" if sl != "ns" else "#444444"
        ax.plot([0, 1], [y_bar, y_bar], color=col_s, lw=0.8)
        ax.text(0.5, y_bar + ymax_p * 0.015, sl, ha="center", va="bottom",
                fontsize=6.5 if sl != "ns" else 5.5, color=col_s, fontweight="bold" if sl != "ns" else "normal")

        ax.set_title(g, fontsize=6.6, pad=4)
        ax.set_xticks([0, 1])
        ax.set_xticklabels(["IM", "EM"], fontsize=6.2)
        ax.set_ylim(0, ymax_p * 1.22)
        ax.tick_params(axis="y", labelsize=5.5, length=2.2, pad=1.5)
        ax.spines["top"].set_visible(False)
        ax.spines["right"].set_visible(False)
        ax.spines["left"].set_linewidth(0.65)
        ax.spines["bottom"].set_linewidth(0.65)

    axes[0].text(-0.52, 1.15, "F", transform=axes[0].transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    axes[0].set_ylabel("Expression (log$_2$)", fontsize=6.6, labelpad=2)
    return axes


def main():
    parser = argparse.ArgumentParser(description="Render Main Figure 6 Panel F (IM vs EM 5 genes).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("fig06_f.png"))
    args = parser.parse_args()

    df_6f = pd.read_csv(args.paper_root / "runs" / "step06_mrseq_deseq2" / "fig6f_im_vs_em_genes_long.csv")
    fig = plt.figure(figsize=(3.30, 1.80), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.14, right=0.97, top=0.84, bottom=0.16)
    draw_panel_6f(fig, gs[0, 0], df_6f)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[fig06_f] Saved -> {args.out}")


if __name__ == "__main__":
    main()
