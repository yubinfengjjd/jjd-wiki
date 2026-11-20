#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: sfig02/D
Title: K-means clustering elbow curve (inertia heterogeneities vs number of clusters k=2..50)
Input tables: runs/step03_rcn_lda/figs2d_kmeans_elbow.csv
Default size: 3.10 in x 2.30 in (300 dpi)
CLI usage:
  python sfig02_d.py --paper-root <sources_root>/papers/pmc9167783 --out sfig02_d.png
"""

import argparse
from pathlib import Path
import sys

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _fig_common import DEFAULT_PAPER_ROOT

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["pdf.fonttype"] = 42


def draw_panel_s2d(fig, gs_slot, elbow_df: pd.DataFrame):
    """Draw Panel S2D (K-means elbow curve) inside gs_slot."""
    ax = fig.add_subplot(gs_slot)
    ax.text(-0.16, 1.12, "D", transform=ax.transAxes, fontsize=11, fontweight="bold", va="top", ha="left", clip_on=False)

    df = elbow_df.sort_values("k")
    x = df["k"].to_numpy()
    y = df["inertia"].to_numpy()

    ax.plot(x, y, color="#999999", linewidth=2.2, zorder=2)
    ax.scatter(x, y, s=22, color="#3A669C", zorder=3)
    # Mark k=30 selected elbow point
    r30 = df[df["k"] == 30]
    if not r30.empty:
        ax.axvline(30, color="#C62828", linestyle="--", linewidth=0.75, alpha=0.75, zorder=1)
        ax.text(31.2, float(y.max()) * 0.85, "k = 30", fontsize=5.8, color="#C62828")

    ax.set_xticks([10, 20, 30, 40, 50])
    ax.set_xticklabels(["10", "20", "30", "40", "50"], fontsize=6.2)
    ax.tick_params(axis="y", labelsize=6.0, length=2.5, pad=2)
    ax.set_xlabel("Number of clusters", fontsize=6.8, labelpad=2)
    ax.set_ylabel("Heterogeneity (inertia)", fontsize=6.8, labelpad=2)
    for sp in ax.spines.values():
        sp.set_linewidth(0.75)
        sp.set_color("#222222")
    return ax


def main():
    parser = argparse.ArgumentParser(description="Render Supp Figure S2 Panel D (K-means elbow).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("sfig02_d.png"))
    args = parser.parse_args()

    elbow_df = pd.read_csv(args.paper_root / "runs" / "step03_rcn_lda" / "figs2d_kmeans_elbow.csv")
    fig = plt.figure(figsize=(3.10, 2.30), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.20, right=0.95, top=0.88, bottom=0.18)
    draw_panel_s2d(fig, gs[0, 0], elbow_df)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[sfig02_d] Saved -> {args.out}")


if __name__ == "__main__":
    main()
