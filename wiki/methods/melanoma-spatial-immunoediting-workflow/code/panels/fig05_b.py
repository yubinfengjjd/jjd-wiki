#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: fig05/B
Title: 2D spatial expression contour plots (MART1 & S100a proxy for MITF & S100B in IM FOV)
Input tables:
  - runs/step05_tcc_spatial_lag/fig5b_s5b_spatial_contours_proxy.csv
  - runs/step03_rcn_lda/fov_cells_with_rcn.csv
Default size: 2.50 in x 3.50 in (300 dpi)
CLI usage:
  python fig05_b.py --paper-root <sources_root>/papers/pmc9167783 --out fig05_b.png
"""

import argparse
from pathlib import Path
import sys

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap
from matplotlib.gridspec import GridSpecFromSubplotSpec
import numpy as np
import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _fig_common import DEFAULT_PAPER_ROOT

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["pdf.fonttype"] = 42


def draw_panel_5b(fig, gs_slot, contour_df: pd.DataFrame, fov_df: pd.DataFrame):
    """Draw Panel 5B (2 stacked spatial expression contour maps) inside gs_slot."""
    sub_cont = contour_df[contour_df["fov_id"] == "MEL09_FOV_IM"].copy()
    sub_cells = fov_df[fov_df["fov_id"] == "MEL09_FOV_IM"].copy()

    sub_gs = GridSpecFromSubplotSpec(2, 1, subplot_spec=gs_slot, hspace=0.06)
    cmap_5b = LinearSegmentedColormap.from_list(
        "fig5b_contour", ["#4E739C", "#9EC1D1", "#F2EBC9", "#DF754B", "#AE212C"]
    )

    gx = np.sort(sub_cont["X_um"].unique())
    gy = np.sort(sub_cont["Y_um"].unique())
    GX, GY = np.meshgrid(gx, gy)
    ymax = sub_cells["Y_um"].max()
    GY_flip = ymax - GY

    specs = [
        ("MART1", "MART1\n(MITF proxy)", "#EE852E"),
        ("S100a", "S100A\n(S100B proxy)", "#E6D33B"),
    ]

    axes = []
    for idx, (col_name, lbl, border_col) in enumerate(specs):
        ax = fig.add_subplot(sub_gs[idx, 0])
        axes.append(ax)
        piv = sub_cont.pivot(index="Y_um", columns="X_um", values=col_name).loc[gy, gx].to_numpy()

        ax.contourf(GX, GY_flip, piv, levels=16, cmap=cmap_5b, alpha=0.85)
        ax.contour(GX, GY_flip, piv, levels=12, colors="white", linewidths=0.45, alpha=0.75)

        # Overlay actual IM cells colored by local smoothed expression
        cx = sub_cells["X_um"].to_numpy()
        cy = ymax - sub_cells["Y_um"].to_numpy()
        # Nearest grid intensity per cell for consistent scatter coloring
        ix = np.clip(np.searchsorted(gx, cx), 0, len(gx) - 1)
        iy = np.clip(np.searchsorted(gy, sub_cells["Y_um"].to_numpy()), 0, len(gy) - 1)
        cvals = piv[iy, ix]
        ax.scatter(cx, cy, c=cvals, cmap=cmap_5b, s=3.5, alpha=0.80, edgecolors="none", rasterized=True, zorder=3)

        ax.text(0.96, 0.94, lbl, transform=ax.transAxes, ha="right", va="top", fontsize=6.4, color="#111111",
                bbox=dict(boxstyle="round,pad=0.15", facecolor="white", edgecolor="none", alpha=0.72))
        ax.set_xlim(gx.min(), gx.max())
        ax.set_ylim(GY_flip.min(), GY_flip.max())
        ax.set_xticks([])
        ax.set_yticks([])
        for sp in ax.spines.values():
            sp.set_linewidth(1.5)
            sp.set_color(border_col)

    axes[0].text(-0.10, 1.07, "B", transform=axes[0].transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    return axes


def main():
    parser = argparse.ArgumentParser(description="Render Main Figure 5 Panel B (spatial contour expression).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("fig05_b.png"))
    args = parser.parse_args()

    contour_df = pd.read_csv(args.paper_root / "runs" / "step05_tcc_spatial_lag" / "fig5b_s5b_spatial_contours_proxy.csv")
    fov_df = pd.read_csv(args.paper_root / "runs" / "step03_rcn_lda" / "fov_cells_with_rcn.csv")

    fig = plt.figure(figsize=(2.50, 3.40), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.06, right=0.96, top=0.93, bottom=0.04)
    draw_panel_5b(fig, gs[0, 0], contour_df, fov_df)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[fig05_b] Saved -> {args.out}")


if __name__ == "__main__":
    main()
