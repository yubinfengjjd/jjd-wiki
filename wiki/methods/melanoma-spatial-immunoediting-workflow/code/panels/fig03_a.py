#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: fig03/A
Title: IM region RCN spatial map + two Voronoi polygon zoom insets (red & blue boxes) + RCN1-10 legend
Input tables:
  - runs/step03_rcn_lda/voronoi_polygons_fov.json
  - runs/step03_rcn_lda/fov_cells_with_rcn.csv
Default size: 3.40 in x 4.10 in (300 dpi)
CLI usage:
  python fig03_a.py --paper-root <sources_root>/papers/pmc9167783 --out fig03_a.png
"""

import argparse
import json
from pathlib import Path
import sys

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.collections import PolyCollection
from matplotlib.gridspec import GridSpecFromSubplotSpec
import numpy as np
import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _fig_common import DEFAULT_PAPER_ROOT

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["pdf.fonttype"] = 42

RCN_COLORS_FIG3 = {
    "RCN1": "#EBB39A",
    "RCN2": "#2D9A93",
    "RCN3": "#52B87A",
    "RCN4": "#C3DEC0",
    "RCN5": "#EFE738",
    "RCN6": "#4FC4EA",
    "RCN7": "#5692BC",
    "RCN8": "#F29954",
    "RCN9": "#EB2629",
    "RCN10": "#C7C7C7",
}


def draw_panel_3a(fig, gs_slot, vor_records: list[dict]):
    """Draw Panel 3A (IM Voronoi spatial overview + 2 zoomed Voronoi insets + RCN1-10 legend) inside gs_slot."""
    im_recs = [r for r in vor_records if r["fov_id"] == "MEL09_FOV_IM"]

    sub_gs = GridSpecFromSubplotSpec(
        3, 2,
        subplot_spec=gs_slot,
        height_ratios=[1.65, 1.15, 0.35],
        hspace=0.06,
        wspace=0.06,
    )

    ax_top = fig.add_subplot(sub_gs[0, :])
    ax_red = fig.add_subplot(sub_gs[1, 0])
    ax_blue = fig.add_subplot(sub_gs[1, 1])
    ax_leg = fig.add_subplot(sub_gs[2, :])

    ax_top.text(-0.08, 1.06, "A", transform=ax_top.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")

    # Render full IM FOV using Voronoi polygons (RCN10 grey background + colored RCN1-9)
    polys = [np.asarray(r["polygon"]) for r in im_recs]
    cols = [RCN_COLORS_FIG3.get(r["RCN"], "#CCCCCC") for r in im_recs]
    xs = [r["x_um"] for r in im_recs]
    ys = [r["y_um_flipped"] for r in im_recs]
    x0, x1 = min(xs), max(xs)
    y0, y1 = min(ys), max(ys)

    pc_top = PolyCollection(polys, facecolors=cols, edgecolors="#888888", linewidths=0.08)
    ax_top.add_collection(pc_top)
    ax_top.set_xlim(x0, x1)
    ax_top.set_ylim(y0, y1)
    ax_top.set_aspect("equal")
    ax_top.text(0.03, 0.94, "IM: MEL09", transform=ax_top.transAxes, fontsize=7.2, ha="left", va="top", color="#111111",
                bbox=dict(boxstyle="square,pad=0.15", facecolor="white", edgecolor="none", alpha=0.75))

    # Larger spatial zoom boxes capturing ~120-200 cells each with fine cellular Voronoi borders
    red_box = (1260, 260, 620, 500)    # (xmin, ymin, w, h)
    blue_box = (1950, 120, 620, 500)

    for (bx, by, bw, bh), ec in [(red_box, "#E31A1C"), (blue_box, "#1F78B4")]:
        ax_top.add_patch(mpatches.Rectangle((bx, by), bw, bh, facecolor="none", edgecolor=ec, linewidth=1.25, zorder=5))

    ax_top.set_xticks([])
    ax_top.set_yticks([])
    for sp in ax_top.spines.values():
        sp.set_linewidth(0.7)
        sp.set_color("#222222")

    # Zoom insets with crisp fine Voronoi cell borders
    for ax_z, (bx, by, bw, bh), ec in [(ax_red, red_box, "#E31A1C"), (ax_blue, blue_box, "#1F78B4")]:
        sub_recs = [
            r for r in im_recs
            if (bx - 80 <= r["x_um"] <= bx + bw + 80) and (by - 80 <= r["y_um_flipped"] <= by + bh + 80)
        ]
        z_polys = [np.asarray(r["polygon"]) for r in sub_recs]
        z_cols = [RCN_COLORS_FIG3.get(r["RCN"], "#CCCCCC") for r in sub_recs]
        pc_z = PolyCollection(z_polys, facecolors=z_cols, edgecolors="#555555", linewidths=0.22)
        ax_z.add_collection(pc_z)
        ax_z.set_xlim(bx, bx + bw)
        ax_z.set_ylim(by, by + bh)
        ax_z.set_aspect("equal")
        ax_z.set_xticks([])
        ax_z.set_yticks([])
        for sp in ax_z.spines.values():
            sp.set_linewidth(1.3)
            sp.set_color(ec)

    # Bottom 5x2 RCN1-10 legend
    ax_leg.axis("off")
    handles = [mpatches.Patch(facecolor=RCN_COLORS_FIG3[f"RCN{i}"], label=f"RCN{i}") for i in range(1, 11)]
    ax_leg.legend(
        handles=handles, loc="center", ncol=5, frameon=False,
        fontsize=6.0, handlelength=1.1, handleheight=0.7, columnspacing=0.9, labelspacing=0.3,
    )
    return ax_top


def main():
    parser = argparse.ArgumentParser(description="Render Main Figure 3 Panel A (IM Voronoi spatial + insets).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("fig03_a.png"))
    args = parser.parse_args()

    with open(args.paper_root / "runs" / "step03_rcn_lda" / "voronoi_polygons_fov.json", "r", encoding="utf-8") as f:
        vor_records = json.load(f)

    fig = plt.figure(figsize=(3.50, 4.10), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.06, right=0.96, top=0.94, bottom=0.04)
    draw_panel_3a(fig, gs[0, 0], vor_records)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[fig03_a] Saved -> {args.out}")


if __name__ == "__main__":
    main()
