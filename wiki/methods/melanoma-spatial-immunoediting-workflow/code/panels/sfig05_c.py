#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: sfig05/C
Title: Co-occurrence of spatial lag clusters (TCC1-10 x Immune/Stromal 1,000-permutation test)
Input tables: runs/step05_tcc_spatial_lag/figs5c_tcc_cooccurrence.csv
Default size: 4.10 in x 2.90 in (300 dpi)
CLI usage:
  python sfig05_c.py --paper-root <sources_root>/papers/pmc9167783 --out sfig05_c.png
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

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _fig_common import DEFAULT_PAPER_ROOT

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["pdf.fonttype"] = 42


def draw_panel_s5c(fig, gs_slot, df_s5c: pd.DataFrame):
    """Draw Panel S5C (3-state TCC co-occurrence matrix) inside gs_slot."""
    sub_gs = GridSpecFromSubplotSpec(1, 2, subplot_spec=gs_slot, width_ratios=[2.4, 0.85], wspace=0.06)
    ax = fig.add_subplot(sub_gs[0, 0])
    ax_leg = fig.add_subplot(sub_gs[0, 1])

    ax.text(-0.24, 1.11, "C", transform=ax.transAxes, fontsize=11, fontweight="bold", va="top", ha="left", clip_on=False)
    ax.set_title("Co-occurrence of spatial lag clusters", fontsize=7.2, pad=6)

    tcc_cols = [f"TCC{i}" for i in range(1, 11)]
    all_nbrs = sorted(df_s5c["neighbour"].unique())
    non_tcc = [n for n in all_nbrs if n not in tcc_cols and n != "Unknown"]
    row_order = non_tcc + tcc_cols

    state_colors = {
        "Avoidance": "#3D164A",
        "Co-occurrence": "#EAE33C",
        "Non-Sig": "#8E8E8E",
    }

    ax.set_xlim(0, len(tcc_cols))
    ax.set_ylim(len(row_order), 0)

    lookup = df_s5c.set_index(["TCC", "neighbour"])["sig_state"].to_dict()
    for ri, rname in enumerate(row_order):
        for ci, cname in enumerate(tcc_cols):
            st = lookup.get((cname, rname), "Non-Sig")
            ax.add_patch(mpatches.Rectangle(
                (ci, ri), 1.0, 1.0,
                facecolor=state_colors.get(st, "#8E8E8E"),
                edgecolor="#222222", linewidth=0.35,
            ))

    ax.set_xticks(np.arange(len(tcc_cols)) + 0.5)
    ax.set_xticklabels(tcc_cols, rotation=90, fontsize=5.6)
    ax.set_yticks(np.arange(len(row_order)) + 0.5)
    ax.set_yticklabels(row_order, fontsize=5.2)
    ax.tick_params(length=0, pad=2)
    for sp in ax.spines.values():
        sp.set_linewidth(0.7)

    # Legend
    ax_leg.axis("off")
    ax_leg.text(0.05, 0.65, "(P < 0.05)", fontsize=5.6, va="bottom")
    handles = [
        mpatches.Patch(facecolor="#3D164A", label="Avoidance"),
        mpatches.Patch(facecolor="#EAE33C", label="Co-occurrence"),
        mpatches.Patch(facecolor="#8E8E8E", label="Non-Sig (P ≥ 0.05)"),
    ]
    ax_leg.legend(handles=handles, loc="center left", frameon=False, fontsize=5.4, handlelength=0.9, handleheight=0.85, labelspacing=0.35)
    return ax


def main():
    parser = argparse.ArgumentParser(description="Render Supp Figure S5 Panel C (TCC co-occurrence).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("sfig05_c.png"))
    args = parser.parse_args()

    df_s5c = pd.read_csv(args.paper_root / "runs" / "step05_tcc_spatial_lag" / "figs5c_tcc_cooccurrence.csv")
    fig = plt.figure(figsize=(4.20, 3.00), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.22, right=0.96, top=0.88, bottom=0.14)
    draw_panel_s5c(fig, gs[0, 0], df_s5c)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[sfig05_c] Saved -> {args.out}")


if __name__ == "__main__":
    main()
