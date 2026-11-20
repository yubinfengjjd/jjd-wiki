#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: fig06/K
Title: PMEL and CD63 log-expression overlapping filled density plots (MIS vs EM and IM, PickSeq proxy)
Input tables: runs/step06_mrseq_deseq2/fig6k_pmel_cd63_density_proxy.csv
Default size: 2.80 in x 2.00 in (300 dpi)
CLI usage:
  python fig06_k.py --paper-root <sources_root>/papers/pmc9167783 --out fig06_k.png
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


def draw_panel_6k(fig, gs_slot, df_6k: pd.DataFrame):
    """Draw Panel 6K (PMEL & CD63 overlapping filled density plots) inside gs_slot."""
    sub_gs = GridSpecFromSubplotSpec(1, 2, subplot_spec=gs_slot, wspace=0.28)
    genes = ["PMEL", "CD63"]
    col_mis = "#689892"
    col_tum = "#EBE3B5"

    axes = []
    for idx, g in enumerate(genes):
        ax = fig.add_subplot(sub_gs[0, idx])
        axes.append(ax)
        sub = df_6k[df_6k["gene"] == g]
        v_mis = sub.loc[sub["group"] == "MIS", "log2_expr"].to_numpy()
        v_tum = sub.loc[sub["group"] == "EM_and_IM", "log2_expr"].to_numpy()

        xmin = min(v_mis.min(), v_tum.min()) - 0.8
        xmax = max(v_mis.max(), v_tum.max()) + 0.8
        xs = np.linspace(xmin, xmax, 250)

        max_d = 0.0
        for vals, col, zo in [(v_mis, col_mis, 2), (v_tum, col_tum, 3)]:
            if len(vals) >= 3 and np.std(vals) > 1e-6:
                kde = stats.gaussian_kde(vals, bw_method=0.45)
                ys = kde(xs)
                ax.fill_between(xs, 0, ys, color=col, alpha=0.76, linewidth=0, zorder=zo)
                max_d = max(max_d, float(ys.max()))

        _, pv = stats.ttest_ind(v_mis, v_tum, equal_var=False)
        sl = _sig_label(pv)
        if sl != "ns":
            m1, m2 = np.median(v_mis), np.median(v_tum)
            y_bar = max_d * 1.07
            ax.plot([m1, m2], [y_bar, y_bar], color="#C62828", lw=0.9, zorder=5)
            ax.text(0.5 * (m1 + m2), y_bar + max_d * 0.02, sl, ha="center", va="bottom",
                    fontsize=7.0, color="#C62828", fontweight="bold")

        ax.set_title(g, fontsize=7.0, loc="left", pad=4)
        ax.set_xlim(xmin, xmax)
        ax.set_ylim(0, max_d * 1.22 if max_d > 0 else 1.0)
        ax.set_yticks([0.0, round(max_d, 2)])
        ax.tick_params(labelsize=5.6, length=2.2, pad=1.5)
        ax.spines["top"].set_visible(False)
        ax.spines["right"].set_visible(False)
        ax.spines["left"].set_linewidth(0.65)
        ax.spines["bottom"].set_linewidth(0.65)

    axes[0].text(-0.34, 1.15, "K", transform=axes[0].transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    axes[0].set_ylabel("Density", fontsize=6.6, labelpad=2)

    handles = [
        mpatches.Patch(facecolor=col_mis, label="MIS"),
        mpatches.Patch(facecolor=col_tum, label="EM and IM"),
    ]
    axes[0].legend(handles=handles, loc="upper left", frameon=False, fontsize=5.5, handlelength=0.9, handleheight=0.9, labelspacing=0.25)

    fig.text(
        0.5 * (axes[0].get_position().x0 + axes[1].get_position().x1),
        axes[0].get_position().y0 - 0.042,
        "Log$_2$ expression (proxy)", ha="center", va="top", fontsize=6.4,
    )
    return axes


def main():
    parser = argparse.ArgumentParser(description="Render Main Figure 6 Panel K (PMEL & CD63 density).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("fig06_k.png"))
    args = parser.parse_args()

    df_6k = pd.read_csv(args.paper_root / "runs" / "step06_mrseq_deseq2" / "fig6k_pmel_cd63_density_proxy.csv")
    fig = plt.figure(figsize=(2.80, 2.00), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.16, right=0.96, top=0.84, bottom=0.18)
    draw_panel_6k(fig, gs[0, 0], df_6k)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[fig06_k] Saved -> {args.out}")


if __name__ == "__main__":
    main()
