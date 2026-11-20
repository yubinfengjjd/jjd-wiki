#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: fig04/F
Title: Cohort 1 (local recompute, n=5) vs Cohort 2 (paper visual bins, n=25) PDL1 positivity bars
Input tables: runs/step04_spatial_interaction/fig4f_cohort1_pdl1_bins.csv
Default size: 2.30 in x 2.60 in (300 dpi)
CLI usage:
  python fig04_f.py --paper-root <sources_root>/papers/pmc9167783 --out fig04_f.png
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


def draw_panel_4f(fig, gs_slot, df_4f: pd.DataFrame):
    """Draw Panel 4F (SOX10+ tumor & CD11C+ myeloid PDL1 bin stacked horizontal bars) inside gs_slot."""
    sub_gs = GridSpecFromSubplotSpec(3, 1, subplot_spec=gs_slot, height_ratios=[1.0, 1.0, 0.52], hspace=0.62)
    ax1 = fig.add_subplot(sub_gs[0, 0])
    ax2 = fig.add_subplot(sub_gs[1, 0])
    ax_leg = fig.add_subplot(sub_gs[2, 0])

    ax1.text(-0.38, 1.44, "F", transform=ax1.transAxes, fontsize=11, fontweight="bold", va="top", ha="left", clip_on=False)

    # Cohort 1 local patient counts (n=5)
    c1_mel = df_4f["mel_bin"].value_counts().to_dict()
    c1_mye = df_4f["myeloid_bin"].value_counts().to_dict()

    # Cohort 2 paper-reported visual scoring counts (n=25, Nirmal et al. p. 11)
    mel_bins = ["0-5%", "5-20%", ">20%"]
    c2_mel_counts = [22, 2, 1]
    c1_mel_counts = [c1_mel.get(b, 0) for b in mel_bins]

    mye_bins = ["<1%", "1-25%", ">25%"]
    c2_mye_counts = [3, 3, 19]
    c1_mye_counts = [c1_mye.get(b, 0) for b in mye_bins]

    col_c2 = "#4C82B6"  # Blue Cohort 2
    col_c1 = "#DE2D26"  # Red Cohort 1

    for ax, bins, c2_v, c1_v, title in [
        (ax1, mel_bins, c2_mel_counts, c1_mel_counts, "SOX10$^+$ tumor cells"),
        (ax2, mye_bins, c2_mye_counts, c1_mye_counts, "CD11C$^+$ myeloid cells"),
    ]:
        y = np.arange(len(bins))
        ax.barh(y, c2_v, height=0.72, color=col_c2, edgecolor="white", lw=0.4)
        ax.barh(y, c1_v, left=c2_v, height=0.72, color=col_c1, edgecolor="white", lw=0.4)
        ax.set_yticks(y)
        ax.set_yticklabels([b.replace("-", "–") for b in bins], fontsize=5.8)
        ax.invert_yaxis()
        ax.set_xlim(0, 30)
        ax.set_xticks([0, 10, 20, 30])
        ax.tick_params(axis="x", labelsize=5.6, length=2.2, pad=1.5)
        ax.set_title(title, fontsize=6.8, pad=3)
        ax.set_ylabel("% PDL1 positive", fontsize=6.0, labelpad=2)
        ax.spines["top"].set_visible(False)
        ax.spines["right"].set_visible(False)
        ax.spines["left"].set_linewidth(0.7)
        ax.spines["bottom"].set_linewidth(0.7)

    ax2.set_xlabel("Number of specimens", fontsize=6.2, labelpad=2)

    ax_leg.axis("off")
    handles = [
        mpatches.Patch(facecolor=col_c1, label="Cohort 1 (local n=5)"),
        mpatches.Patch(facecolor=col_c2, label="Cohort 2 (paper visual n=25)"),
    ]
    ax_leg.legend(handles=handles, loc="lower center", bbox_to_anchor=(0.48, -0.25),
                  ncol=1, frameon=False, fontsize=5.1, handlelength=0.9, handleheight=0.75, labelspacing=0.22)
    return [ax1, ax2]


def main():
    parser = argparse.ArgumentParser(description="Render Main Figure 4 Panel F (Cohort 1 vs 2 PDL1 bins).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("fig04_f.png"))
    args = parser.parse_args()

    df_4f = pd.read_csv(args.paper_root / "runs" / "step04_spatial_interaction" / "fig4f_cohort1_pdl1_bins.csv")
    fig = plt.figure(figsize=(2.40, 2.70), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.26, right=0.94, top=0.90, bottom=0.06)
    draw_panel_4f(fig, gs[0, 0], df_4f)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[fig04_f] Saved -> {args.out}")


if __name__ == "__main__":
    main()
