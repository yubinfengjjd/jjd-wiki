#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: sfig07/D
Title: Tumor-stroma boundary fluorescence intensity gradient (MHC-II, SOX10, CD11C) + excluded CyCIF S7D-left
Input tables: runs/step04_spatial_interaction/figs7d_boundary_intensity_gradient.csv
Default size: 3.30 in x 2.10 in (300 dpi)
CLI usage:
  python sfig07_d.py --paper-root <sources_root>/papers/pmc9167783 --out sfig07_d.png
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


def draw_panel_s7d(fig, gs_slot, df_s7d: pd.DataFrame):
    """Draw Panel S7D (left excluded microscopy + right MHC-II/SOX10/CD11c boundary line) inside gs_slot."""
    sub_gs = GridSpecFromSubplotSpec(1, 2, subplot_spec=gs_slot, width_ratios=[1.05, 1.15], wspace=0.22)
    ax_ex = fig.add_subplot(sub_gs[0, 0])
    ax = fig.add_subplot(sub_gs[0, 1])

    ax_ex.text(-0.08, 1.10, "D", transform=ax_ex.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    ax_ex.axis("off")
    ax_ex.set_xlim(0, 1)
    ax_ex.set_ylim(0, 1)
    ax_ex.add_patch(mpatches.FancyBboxPatch(
        (0.02, 0.04), 0.96, 0.92,
        boxstyle="round,pad=0.02,rounding_size=0.02",
        facecolor="#F7F7F7", edgecolor="#999999", linestyle="--", linewidth=0.75,
    ))
    ax_ex.text(0.50, 0.50, "S7D-left: CyCIF\n(SOX10, MHC-II, CD11C)\n\n[Excluded imaging]",
               ha="center", va="center", fontsize=5.5, color="#555555")

    df = df_s7d.sort_values("dist_bin_um")
    x = df["dist_bin_um"].to_numpy()
    ax.axvline(0.0, color="#999999", linestyle="--", lw=0.8)
    ax.plot(x, df["HLADPB1"], color="#E3D433", lw=1.8, label="MHC-II")
    ax.plot(x, df["SOX10"], color="#6E49A6", lw=1.8, label="SOX10")
    ax.plot(x, df["CD11c"], color="#3853A4", lw=1.8, label="CD11C")

    ymax = max(df[["HLADPB1", "SOX10", "CD11c"]].to_numpy().max(), 1.0) * 1.15
    ax.set_xlim(x.min() - 5, x.max() + 5)
    ax.set_ylim(0, ymax)
    ax.set_xticks([-100, -50, 0, 50, 100])
    ax.set_xticklabels(["100", "50", "0", "50", "100"], fontsize=5.2)
    ax.set_yticks([0.0, 0.5, 1.0])
    ax.set_yticklabels(["0.0", "0.5", "1.0"], fontsize=5.2)
    ax.set_xlabel("Distance from boundary (μm)", fontsize=5.8, labelpad=2)
    ax.set_ylabel("Fluorescence intensity", fontsize=5.8, labelpad=2)
    ax.legend(loc="center left", frameon=False, fontsize=5.2, handlelength=0.9, labelspacing=0.25)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.spines["left"].set_linewidth(0.7)
    ax.spines["bottom"].set_linewidth(0.7)
    return ax


def main():
    parser = argparse.ArgumentParser(description="Render Supp Figure S7 Panel D (boundary intensity).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("sfig07_d.png"))
    args = parser.parse_args()

    df_s7d = pd.read_csv(args.paper_root / "runs" / "step04_spatial_interaction" / "figs7d_boundary_intensity_gradient.csv")
    fig = plt.figure(figsize=(3.40, 2.10), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.06, right=0.96, top=0.88, bottom=0.18)
    draw_panel_s7d(fig, gs[0, 0], df_s7d)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[sfig07_d] Saved -> {args.out}")


if __name__ == "__main__":
    main()
