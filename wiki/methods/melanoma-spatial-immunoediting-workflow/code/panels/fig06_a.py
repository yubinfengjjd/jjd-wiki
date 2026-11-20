#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: fig06/A
Title: PickSeq mROI PCA (120 mROIs, proxy for GeoMx 70 mROIs) with soft group envelopes
Input tables: runs/step06_mrseq_deseq2/fig6a_pca_coords_proxy.csv
Default size: 2.30 in x 2.20 in (300 dpi)
CLI usage:
  python fig06_a.py --paper-root <sources_root>/papers/pmc9167783 --out fig06_a.png
"""

import argparse
from pathlib import Path
import sys

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import pandas as pd
from scipy.spatial import ConvexHull

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _fig_common import DEFAULT_PAPER_ROOT

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["pdf.fonttype"] = 42

SITE_COLORS_6 = {
    "MIS": "#1E9C78",
    "IR": "#DA805C",
    "bTIL": "#C84B93",
    "IB": "#85A933",
    "IM": "#C69032",
    "EM": "#666666",
}


def _draw_soft_hull(ax, pts: np.ndarray, facecolor: str, edgecolor: str, pad_frac: float = 0.22):
    """Draw a smooth padded dashed envelope around a group of 2D PCA points."""
    if len(pts) < 3:
        return
    center = pts.mean(axis=0)
    # Expand points radially from center for clean padding
    padded = center + (pts - center) * (1.0 + pad_frac)
    hull = ConvexHull(padded)
    poly_pts = padded[hull.vertices]
    # Subdivide/smooth corners via Chaikin corner cutting
    for _ in range(3):
        new_pts = []
        n = len(poly_pts)
        for i in range(n):
            p0, p1 = poly_pts[i], poly_pts[(i + 1) % n]
            new_pts.append(0.75 * p0 + 0.25 * p1)
            new_pts.append(0.25 * p0 + 0.75 * p1)
        poly_pts = np.asarray(new_pts)
    patch = mpatches.Polygon(
        poly_pts, closed=True, facecolor=facecolor, edgecolor=edgecolor,
        linestyle="--", linewidth=0.8, alpha=0.42, zorder=1,
    )
    ax.add_patch(patch)


def draw_panel_6a(fig, gs_slot, pca_df: pd.DataFrame):
    """Draw Panel 6A (PCA scatter + 3 soft translucent dashed hulls) inside gs_slot."""
    ax = fig.add_subplot(gs_slot)
    ax.text(-0.26, 1.15, "A", transform=ax.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    n_mroi = len(pca_df)
    ax.set_title(f"PickSeq ({n_mroi} mROIs, proxy)", fontsize=7.6, pad=5)

    # 3 super-group hulls matching 1518fig6.jpg
    hull_groups = [
        (["EM", "IM", "IB"], "#E9E3B5", "#C7BF86"),
        (["MIS"], "#9DC2B5", "#6BA18F"),
        (["bTIL", "IR"], "#F1BFA4", "#DC9470"),
    ]
    for sites, fc, ec in hull_groups:
        sub = pca_df[pca_df["site"].isin(sites)][["PC1", "PC2"]].to_numpy()
        _draw_soft_hull(ax, sub, fc, ec, pad_frac=0.18)

    for site_name in ["EM", "IM", "IB", "MIS", "bTIL", "IR"]:
        sub = pca_df[pca_df["site"] == site_name]
        if not sub.empty:
            ax.scatter(
                sub["PC1"], sub["PC2"], c=SITE_COLORS_6[site_name],
                s=14, edgecolors="#222222", linewidths=0.35, alpha=0.92, zorder=3,
            )
            cx, cy = sub["PC1"].median(), sub["PC2"].median()
            ax.text(
                cx, cy + (sub["PC2"].std() * 0.65 if len(sub) > 1 else 2.0),
                site_name, fontsize=6.4, fontweight="bold", color=SITE_COLORS_6[site_name],
                ha="center", va="bottom", zorder=4,
            )

    pc1_v = pca_df["pc1_var_pct"].iloc[0]
    pc2_v = pca_df["pc2_var_pct"].iloc[0]
    ax.set_xlabel(f"PC1: {pc1_v:.1f}% variance", fontsize=6.8, labelpad=2)
    ax.set_ylabel(f"PC2: {pc2_v:.1f}% variance", fontsize=6.8, labelpad=2)
    ax.set_xticks([])
    ax.set_yticks([])
    for sp in ax.spines.values():
        sp.set_linewidth(0.7)
        sp.set_color("#222222")
    return ax


def main():
    parser = argparse.ArgumentParser(description="Render Main Figure 6 Panel A (PCA proxy).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("fig06_a.png"))
    args = parser.parse_args()

    pca_df = pd.read_csv(args.paper_root / "runs" / "step06_mrseq_deseq2" / "fig6a_pca_coords_proxy.csv")
    fig = plt.figure(figsize=(2.30, 2.20), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.18, right=0.95, top=0.84, bottom=0.14)
    draw_panel_6a(fig, gs[0, 0], pca_df)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[fig06_a] Saved -> {args.out}")


if __name__ == "__main__":
    main()
