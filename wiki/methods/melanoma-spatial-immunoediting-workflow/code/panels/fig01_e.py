#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: fig01/E
Title: Cell centroids spatial scatter plot on dark background (Tumor, T cells, Myeloid, Other)
Input tables: runs/step04_spatial_interaction/fig1e_cell_centroids_im.csv
Default size: 2.20 in x 2.00 in (300 dpi)
CLI usage:
  python fig01_e.py --paper-root <sources_root>/papers/pmc9167783 --out fig01_e.png
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


def draw_panel_1e(fig, gs_slot, df_1e: pd.DataFrame):
    """Draw Panel 1E (dark-background Cell centroids scatter) inside gs_slot."""
    ax = fig.add_subplot(gs_slot)
    ax.set_facecolor("#0A0A0A")

    def map_grp(r):
        ph = str(r["phenotype_abbrev"])
        lb = str(r["lineage_broad"])
        if ph == "Mel":
            return "Tumor"
        if ph in ("CTL", "Th", "Treg", "PD1+ CTL", "Tex") or lb == "Lymphoid":
            return "T cells"
        if lb == "Myeloid" or ph in ("PD-L1+ DC", "PD-L1+ mac", "DC", "LC", "Mac", "CD11C+ mac", "Mast cell"):
            return "Myeloid"
        return "Other"

    grp = df_1e.apply(map_grp, axis=1)
    ymax = df_1e["Y_um"].max()
    x = df_1e["X_um"].to_numpy()
    y = ymax - df_1e["Y_um"].to_numpy()

    styles = [
        ("Other", "#777777", 5.5),
        ("Myeloid", "#4DC0D6", 7.5),
        ("T cells", "#E8BA3B", 8.5),
        ("Tumor", "#D93B3B", 9.5),
    ]
    for gname, col, sz in styles:
        m = (grp == gname).to_numpy()
        if m.any():
            ax.scatter(x[m], y[m], c=col, s=sz, alpha=0.92, edgecolors="none", zorder=2)

    ax.text(0.04, 0.96, "E", transform=ax.transAxes, fontsize=11, fontweight="bold", color="white", va="top", ha="left")
    ax.text(0.96, 0.96, "Cell centroids", transform=ax.transAxes, fontsize=6.4, color="white", va="top", ha="right")

    ax.text(0.05, 0.14, "Tumor", transform=ax.transAxes, fontsize=5.8, color="#D93B3B", fontweight="bold")
    ax.text(0.28, 0.14, "T cells", transform=ax.transAxes, fontsize=5.8, color="#E8BA3B", fontweight="bold")
    ax.text(0.05, 0.05, "Other", transform=ax.transAxes, fontsize=5.8, color="#999999", fontweight="bold")
    ax.text(0.28, 0.05, "Myeloid", transform=ax.transAxes, fontsize=5.8, color="#4DC0D6", fontweight="bold")

    ax.set_xticks([])
    ax.set_yticks([])
    for sp in ax.spines.values():
        sp.set_color("#333333")
        sp.set_linewidth(0.7)
    return ax


def main():
    parser = argparse.ArgumentParser(description="Render Main Figure 1 Panel E (Cell centroids).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("fig01_e.png"))
    args = parser.parse_args()

    df_1e = pd.read_csv(args.paper_root / "runs" / "step04_spatial_interaction" / "fig1e_cell_centroids_im.csv")
    fig = plt.figure(figsize=(2.20, 2.00), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.04, right=0.96, top=0.94, bottom=0.05)
    draw_panel_1e(fig, gs[0, 0], df_1e)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[fig01_e] Saved -> {args.out}")


if __name__ == "__main__":
    main()
