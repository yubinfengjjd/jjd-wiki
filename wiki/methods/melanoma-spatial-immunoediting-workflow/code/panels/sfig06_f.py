#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: sfig06/F
Title: 8-gene TCGA-SKCM (n=120) Kaplan-Meier survival curve grid (BRI3, CDK2, SOX10, TBC1D7, PMEL, TYR, S100B, TSPAN10)
Input tables:
  - runs/step07_network_survival/figs6f_tcga_km_curves.csv
  - runs/step07_network_survival/figs6f_tcga_survival_stats.csv
Default size: 3.80 in x 6.50 in (300 dpi)
CLI usage:
  python sfig06_f.py --paper-root <sources_root>/papers/pmc9167783 --out sfig06_f.png
"""

import argparse
from pathlib import Path
import sys

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.gridspec import GridSpecFromSubplotSpec
import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _fig_common import DEFAULT_PAPER_ROOT

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["pdf.fonttype"] = 42


def draw_panel_s6f(fig, gs_slot, km_df: pd.DataFrame, stats_df: pd.DataFrame):
    """Draw Panel S6F (4x2 TCGA-SKCM Kaplan-Meier grid) inside gs_slot."""
    sub_gs = GridSpecFromSubplotSpec(5, 2, subplot_spec=gs_slot, height_ratios=[1, 1, 1, 1, 0.22], hspace=0.40, wspace=0.26)
    genes_order = ["BRI3", "CDK2", "SOX10", "TBC1D7", "PMEL", "TYR", "S100B", "TSPAN10"]
    avail = [g for g in genes_order if g in km_df["gene"].values]

    col_low = "#E29D7A"
    col_high = "#284560"

    axes = []
    for idx, g in enumerate(avail[:8]):
        r, c = divmod(idx, 2)
        ax = fig.add_subplot(sub_gs[r, c])
        axes.append(ax)

        sub_g = km_df[km_df["gene"] == g]
        for grp, col in [("Low", col_low), ("High", col_high)]:
            sg = sub_g[sub_g["group"] == grp].sort_values("time_years")
            if sg.empty:
                continue
            ax.step(sg["time_years"], sg["surv"], where="post", color=col, lw=1.25, label=f"{grp} {g}")
            ax.step(sg["time_years"], sg["lower"], where="post", color=col, lw=0.45, linestyle=":", alpha=0.65)
            ax.step(sg["time_years"], sg["upper"], where="post", color=col, lw=0.45, linestyle=":", alpha=0.65)
            cens = sg[sg["n_censor"] > 0]
            if not cens.empty:
                ax.scatter(cens["time_years"], cens["surv"], marker="+", s=12, color=col, linewidths=0.6)

        st_row = stats_df[stats_df["gene"] == g].iloc[0]
        stat_txt = (
            f"Logrank p={float(st_row['logrank_p']):.3g}\n"
            f"HR(high)={float(st_row['cox_hr_high_vs_low']):.2f}\n"
            f"p(HR)={float(st_row['cox_p']):.3g}\n"
            f"n(h)={int(st_row['n_high'])}, n(l)={int(st_row['n_low'])}"
        )
        ax.text(0.96, 0.72, stat_txt, transform=ax.transAxes, ha="right", va="top", fontsize=4.3, color="#222222")
        ax.set_title(g, fontsize=6.8, loc="left", pad=2)
        ax.set_ylim(0, 1.05)
        ax.set_yticks([0.0, 0.5, 1.0])
        ax.set_yticklabels(["0.0", "0.5", "1.0"] if c == 0 else [], fontsize=5.2)
        ax.tick_params(axis="x", labelsize=4.8, length=2.0, pad=1.2)
        ax.spines["top"].set_visible(False)
        ax.spines["right"].set_visible(False)
        ax.spines["left"].set_linewidth(0.65)
        ax.spines["bottom"].set_linewidth(0.65)

    axes[0].text(-0.28, 1.22, "F", transform=axes[0].transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    fig.text(
        axes[0].get_position().x0 - 0.040,
        0.5 * (axes[0].get_position().y1 + axes[6].get_position().y0),
        "% Survival (TCGA-SKCM, n=120)", rotation=90, ha="center", va="center", fontsize=6.4,
    )

    ax_leg = fig.add_subplot(sub_gs[4, :])
    ax_leg.axis("off")
    handles = [
        mpatches.Patch(facecolor=col_low, label="Low group"),
        mpatches.Patch(facecolor=col_high, label="High group"),
    ]
    ax_leg.legend(handles=handles, loc="center", ncol=2, frameon=False, fontsize=5.8, handlelength=0.9, handleheight=0.8)
    return axes


def main():
    parser = argparse.ArgumentParser(description="Render Supp Figure S6 Panel F (8-gene TCGA KM grid).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("sfig06_f.png"))
    args = parser.parse_args()

    km_df = pd.read_csv(args.paper_root / "runs" / "step07_network_survival" / "figs6f_tcga_km_curves.csv")
    stats_df = pd.read_csv(args.paper_root / "runs" / "step07_network_survival" / "figs6f_tcga_survival_stats.csv")

    fig = plt.figure(figsize=(3.80, 6.50), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.14, right=0.96, top=0.94, bottom=0.04)
    draw_panel_s6f(fig, gs[0, 0], km_df, stats_df)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[sfig06_f] Saved -> {args.out}")


if __name__ == "__main__":
    main()
