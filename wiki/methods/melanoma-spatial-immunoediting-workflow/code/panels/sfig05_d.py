#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: sfig05/D
Title: Cell states in invasive melanoma (2D CCND1 vs MART1 density contours + quadrant stacked bar, proxy)
Input tables:
  - runs/step02_umap_gradients/figs5d_2d_density_cells_proxy.csv
  - runs/step02_umap_gradients/figs5d_quadrant_proportions_proxy.csv
Default size: 3.40 in x 2.60 in (300 dpi)
CLI usage:
  python sfig05_d.py --paper-root <sources_root>/papers/pmc9167783 --out sfig05_d.png
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
import seaborn as sns

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _fig_common import DEFAULT_PAPER_ROOT

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["pdf.fonttype"] = 42


def draw_panel_s5d(fig, gs_slot, cells_df: pd.DataFrame, quad_df: pd.DataFrame):
    """Draw Panel S5D (2D density contour + quadrant bar + legend) inside gs_slot."""
    sub_gs = GridSpecFromSubplotSpec(2, 2, subplot_spec=gs_slot, height_ratios=[2.2, 0.9], width_ratios=[1.8, 0.95], hspace=0.28, wspace=0.20)
    ax = fig.add_subplot(sub_gs[0, 0])
    ax_bar = fig.add_subplot(sub_gs[0, 1])
    ax_leg = fig.add_subplot(sub_gs[1, :])

    ax.text(-0.28, 1.15, "D", transform=ax.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    fig.text(
        0.5 * (ax.get_position().x0 + ax_bar.get_position().x1),
        ax.get_position().y1 + 0.018,
        "Cell states (CCND1 vs MART1 proxy)", ha="center", va="bottom", fontsize=7.0,
    )

    x = cells_df["y_scaled"].to_numpy()   # MART1 (MITF differentiation proxy)
    y = cells_df["x_scaled"].to_numpy()   # CCND1 (KI67 proliferation proxy)

    ax.scatter(x, y, s=5.0, color="#777777", alpha=0.55, edgecolors="none", zorder=1)
    if len(cells_df) >= 10:
        sns.kdeplot(x=x, y=y, ax=ax, levels=8, color="#333333", linewidths=0.75, zorder=2)

    ax.axvline(0.5, color="#222222", linewidth=0.8, zorder=3)
    ax.axhline(0.5, color="#222222", linewidth=0.8, zorder=3)
    ax.set_xlim(-0.08, 1.08)
    ax.set_ylim(-0.08, 1.08)
    ax.set_xticks([0.0, 0.5, 1.0])
    ax.set_yticks([0.0, 0.5, 1.0])
    ax.tick_params(labelsize=5.4, length=2.2, pad=1.5)
    ax.set_xlabel("Scaled MART1 (MITF proxy)", fontsize=5.8, labelpad=2)
    ax.set_ylabel("Scaled CCND1 (KI67 proxy)", fontsize=5.8, labelpad=2)
    for sp in ax.spines.values():
        sp.set_linewidth(0.7)

    # Stacked quadrant proportions across IM (or overall if IM small)
    sub_q = quad_df[quad_df["Stage"] == "IM"]
    if sub_q.empty:
        sub_q = quad_df.groupby("quadrant", as_index=False)["n_cells"].sum()
        sub_q["pct_in_stage"] = sub_q["n_cells"] / sub_q["n_cells"].sum() * 100.0
    q_map = dict(zip(sub_q["quadrant"], sub_q["pct_in_stage"]))

    q_specs = [
        ("CCND1_high__MART1_low",  "#D62728", "CCND1$^{hi}$ MART1$^{lo}$"),
        ("CCND1_low__MART1_low",   "#8C3B96", "CCND1$^{lo}$ MART1$^{lo}$"),
        ("CCND1_high__MART1_high", "#A65628", "CCND1$^{hi}$ MART1$^{hi}$"),
        ("CCND1_low__MART1_high",  "#B8B8B8", "CCND1$^{lo}$ MART1$^{hi}$"),
    ]
    ax_bar.set_xlim(0, 1)
    ax_bar.set_ylim(0, 100)
    bot = 0.0
    for qkey, col, _ in q_specs:
        pct = float(q_map.get(qkey, 0.0))
        if pct > 0:
            ax_bar.bar([0.32], [pct], bottom=bot, width=0.42, color=col, edgecolor="white", lw=0.4)
            if pct >= 5.0:
                ax_bar.text(0.32, bot + pct * 0.5, f"{pct:.0f}%", ha="center", va="center", fontsize=5.2, color="white", fontweight="bold")
            bot += pct
    ax_bar.axis("off")

    ax_leg.axis("off")
    handles = [mpatches.Patch(facecolor=col, label=lbl) for _, col, lbl in reversed(q_specs)]
    ax_leg.legend(handles=handles, loc="center", ncol=2, frameon=False, fontsize=5.3, handlelength=0.85, handleheight=0.75, labelspacing=0.25)
    return ax


def main():
    parser = argparse.ArgumentParser(description="Render Supp Figure S5 Panel D (2D density quadrants).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("sfig05_d.png"))
    args = parser.parse_args()

    cells_df = pd.read_csv(args.paper_root / "runs" / "step02_umap_gradients" / "figs5d_2d_density_cells_proxy.csv")
    quad_df = pd.read_csv(args.paper_root / "runs" / "step02_umap_gradients" / "figs5d_quadrant_proportions_proxy.csv")

    fig = plt.figure(figsize=(3.40, 2.70), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.16, right=0.96, top=0.86, bottom=0.05)
    draw_panel_s5d(fig, gs[0, 0], cells_df, quad_df)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[sfig05_d] Saved -> {args.out}")


if __name__ == "__main__":
    main()
