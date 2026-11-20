#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: fig05/F
Title: TCC1-10 marker positivity fraction horizontal bar chart (S100a, MART1, CCND1, HLADPB1, MYC proxy)
Input tables: runs/step05_tcc_spatial_lag/fig5f_tcc_marker_positivity.csv
Default size: 2.90 in x 2.80 in (300 dpi)
CLI usage:
  python fig05_f.py --paper-root <sources_root>/papers/pmc9167783 --out fig05_f.png
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

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _fig_common import DEFAULT_PAPER_ROOT
from fig05_e import TCC_COLORS_5

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["pdf.fonttype"] = 42


def draw_panel_5f(fig, gs_slot, df_5f: pd.DataFrame):
    """Draw Panel 5F (5-column faceted horizontal fraction bar chart across TCC1-10) inside gs_slot."""
    df_5f = df_5f.set_index("TCC")
    tcc_order = [f"TCC{i}" for i in range(1, 11)]
    markers = [
        ("S100a", "S100A$^+$"),
        ("MART1", "MART1$^+$"),
        ("CCND1", "CCND1$^+$"),
        ("MYC", "MYC$^+$"),
        ("HLADPB1", "HLA-II$^+$"),
    ]
    avail = [(m, lbl) for m, lbl in markers if m in df_5f.columns]

    sub_gs = GridSpecFromSubplotSpec(1, len(avail), subplot_spec=gs_slot, wspace=0.14)
    y_pos = np.arange(len(tcc_order))
    bar_cols = [TCC_COLORS_5[t] for t in tcc_order]

    axes = []
    for idx, (col_name, title_lbl) in enumerate(avail):
        ax = fig.add_subplot(sub_gs[0, idx])
        axes.append(ax)
        vals = [float(df_5f.loc[t, col_name]) / 100.0 if t in df_5f.index else 0.0 for t in tcc_order]
        ax.barh(y_pos, vals, height=0.76, color=bar_cols, edgecolor="none")
        ax.set_xlim(0, 1.05)
        ax.set_ylim(len(tcc_order) - 0.3, -0.7)
        ax.set_xticks([0, 1])
        ax.set_xticklabels(["0", "1"], fontsize=5.6)
        ax.set_title(title_lbl, fontsize=5.8, pad=3)

        ax.set_yticks(y_pos)
        if idx == 0:
            ax.set_yticklabels([str(i) for i in range(1, 11)], fontsize=5.8)
            ax.set_ylabel("TCCs", fontsize=6.4, labelpad=2)
        else:
            ax.set_yticklabels([])
            ax.tick_params(axis="y", length=0)

        ax.spines["top"].set_visible(False)
        ax.spines["right"].set_visible(False)
        ax.spines["left"].set_linewidth(0.65)
        ax.spines["bottom"].set_linewidth(0.65)

    axes[0].text(-0.65, 1.10, "F", transform=axes[0].transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    fig.text(
        0.5 * (axes[0].get_position().x0 + axes[-1].get_position().x1),
        axes[0].get_position().y0 - 0.030,
        "Fraction of cells", ha="center", va="top", fontsize=6.4,
    )
    return axes


def main():
    parser = argparse.ArgumentParser(description="Render Main Figure 5 Panel F (TCC marker positivity).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("fig05_f.png"))
    args = parser.parse_args()

    df_5f = pd.read_csv(args.paper_root / "runs" / "step05_tcc_spatial_lag" / "fig5f_tcc_marker_positivity.csv")
    fig = plt.figure(figsize=(2.90, 2.80), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.14, right=0.97, top=0.88, bottom=0.14)
    draw_panel_5f(fig, gs[0, 0], df_5f)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[fig05_f] Saved -> {args.out}")


if __name__ == "__main__":
    main()
