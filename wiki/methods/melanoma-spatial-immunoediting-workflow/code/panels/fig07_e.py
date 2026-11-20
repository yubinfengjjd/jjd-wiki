#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: fig07/E
Title: Tumor-stroma boundary spatial fluorescence intensity gradient (SOX10 & HLADPB1 IRF1-proxy)
Input tables: runs/step04_spatial_interaction/figs7d_boundary_intensity_gradient.csv
Default size: 2.00 in x 2.30 in (300 dpi)
CLI usage:
  python fig07_e.py --paper-root <sources_root>/papers/pmc9167783 --out fig07_e.png
"""

import argparse
from pathlib import Path
import sys

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _fig_common import DEFAULT_PAPER_ROOT

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["pdf.fonttype"] = 42


def draw_panel_7e(fig, gs_slot, df_7e: pd.DataFrame):
    """Draw Panel 7E (boundary distance intensity profile) inside gs_slot."""
    ax = fig.add_subplot(gs_slot)
    ax.text(-0.34, 1.12, "E", transform=ax.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")

    df = df_7e.sort_values("dist_bin_um").copy()
    x = df["dist_bin_um"].to_numpy()
    y_sox = df["SOX10"].to_numpy()
    y_hla = df["HLADPB1"].to_numpy()

    ax.axvline(0.0, color="#264C96", linestyle="--", linewidth=1.0, zorder=1)
    ax.axvline(-15.0, color="#C8D6E5", linestyle="--", linewidth=0.75, zorder=1)
    ax.axvline(15.0, color="#C8D6E5", linestyle="--", linewidth=0.75, zorder=1)

    ax.plot(x, y_hla, color="#E86850", linewidth=1.8, label="HLADPB1 (IRF1 proxy)", zorder=3)
    ax.plot(x, y_sox, color="#2B3058", linewidth=1.8, label="SOX10", zorder=4)

    ymax = max(y_sox.max(), y_hla.max(), 1.0) * 1.15
    ax.set_xlim(x.min() - 5, x.max() + 5)
    ax.set_ylim(0, ymax)
    ax.set_xticks([-100, -50, 0, 50, 100])
    ax.set_xticklabels(["100", "50", "0", "50", "100"], fontsize=5.6)
    ax.set_yticks([0.0, 0.5, 1.0])
    ax.set_yticklabels(["0.0", "0.5", "1.0"], fontsize=5.6)

    ax.annotate("", xy=(-95, ymax * 0.94), xytext=(-5, ymax * 0.94),
                arrowprops=dict(arrowstyle="->", color="#222222", lw=0.7))
    ax.text(-50, ymax * 0.96, "Tumor", ha="center", va="bottom", fontsize=5.6)
    ax.annotate("", xy=(95, ymax * 0.94), xytext=(5, ymax * 0.94),
                arrowprops=dict(arrowstyle="->", color="#222222", lw=0.7))
    ax.text(50, ymax * 0.96, "Stroma", ha="center", va="bottom", fontsize=5.6)

    ax.set_xlabel("Distance from boundary (μm)", fontsize=6.2, labelpad=2)
    ax.set_ylabel("Fluorescence intensity", fontsize=6.4, labelpad=2)
    ax.legend(loc="lower left", frameon=False, fontsize=5.2, handlelength=1.0, labelspacing=0.25)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.spines["left"].set_linewidth(0.7)
    ax.spines["bottom"].set_linewidth(0.7)
    return ax


def main():
    parser = argparse.ArgumentParser(description="Render Main Figure 7 Panel E (boundary intensity).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("fig07_e.png"))
    args = parser.parse_args()

    df_7e = pd.read_csv(args.paper_root / "runs" / "step04_spatial_interaction" / "figs7d_boundary_intensity_gradient.csv")
    fig = plt.figure(figsize=(2.20, 2.40), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.24, right=0.95, top=0.88, bottom=0.18)
    draw_panel_7e(fig, gs[0, 0], df_7e)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[fig07_e] Saved -> {args.out}")


if __name__ == "__main__":
    main()
