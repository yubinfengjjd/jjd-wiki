#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: fig03/C
Title: Progression axis 6 circular-clipped Voronoi neighborhoods (Normal | Precursor | Melanoma in situ)
Input tables: runs/step03_rcn_lda/voronoi_polygons_fov.json
Default size: 7.20 in x 2.15 in (300 dpi)
CLI usage:
  python fig03_c.py --paper-root <sources_root>/papers/pmc9167783 --out fig03_c.png
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
from matplotlib.colors import LinearSegmentedColormap
from matplotlib.gridspec import GridSpecFromSubplotSpec
import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _fig_common import DEFAULT_PAPER_ROOT
from fig03_a import RCN_COLORS_FIG3

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["pdf.fonttype"] = 42


def _render_circular_voronoi(ax, recs: list[dict], cx: float, cy: float, radius: float, ring_color: str, pat_lbl: str):
    """Clip and render Voronoi polygons inside a circular window with thick colored border ring."""
    sub = [
        r for r in recs
        if ((r["x_um"] - cx) ** 2 + (r["y_um_flipped"] - cy) ** 2) <= (radius * 1.18) ** 2
    ]
    polys = [np.asarray(r["polygon"]) for r in sub]
    cols = [RCN_COLORS_FIG3.get(r["RCN"], "#CCCCCC") for r in sub]
    clip_circ = mpatches.Circle((cx, cy), radius, transform=ax.transData)

    if polys:
        pc = PolyCollection(polys, facecolors=cols, edgecolors="#555555", linewidths=0.20, zorder=2)
        pc.set_clip_path(clip_circ)
        ax.add_collection(pc)

    # Background fill inside circle for any convex-hull tissue border
    bg_circ = mpatches.Circle((cx, cy), radius, facecolor="#D6D6D6", edgecolor="none", zorder=1)
    ax.add_patch(bg_circ)

    # Thick colored outer ring
    ring = mpatches.Circle((cx, cy), radius, facecolor="none", edgecolor=ring_color, linewidth=1.6, zorder=5)
    ax.add_patch(ring)

    ax.set_xlim(cx - radius * 1.08, cx + radius * 1.08)
    ax.set_ylim(cy - radius * 1.08, cy + radius * 1.16)
    ax.set_aspect("equal")
    ax.text(cx + radius * 0.72, cy + radius * 0.88, pat_lbl, fontsize=6.2, ha="center", va="bottom", color="#111111", zorder=6)
    ax.axis("off")


def draw_panel_3c(fig, gs_slot, vor_records: list[dict]):
    """Draw Panel 3C-top (Progression axis gradient + 6 circular Voronoi neighborhoods) + excluded 3C-bottom note."""
    sub_gs = GridSpecFromSubplotSpec(
        3, 1,
        subplot_spec=gs_slot,
        height_ratios=[0.24, 1.35, 0.30],
        hspace=0.06,
    )

    # 1) Top gradient progression axis banner
    ax_bar = fig.add_subplot(sub_gs[0, 0])
    ax_bar.text(-0.04, 1.20, "C", transform=ax_bar.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    grad = np.linspace(0, 1, 256).reshape(1, -1)
    cmap_prog = LinearSegmentedColormap.from_list("prog_axis", ["#D9E6F2", "#EBEBEB", "#F5CCA0", "#EE9B49"])
    ax_bar.imshow(grad, aspect="auto", cmap=cmap_prog, extent=[0, 1, 0, 1])
    ax_bar.text(0.98, 0.5, "Progression axis", ha="right", va="center", fontsize=7.0, color="#FFFFFF", fontweight="bold")
    ax_bar.set_xticks([])
    ax_bar.set_yticks([])
    for sp in ax_bar.spines.values():
        sp.set_visible(False)

    # 2) 6 circular Voronoi crops across Normal, Precursor, Melanoma in situ
    ax_row = fig.add_subplot(sub_gs[1, 0])
    ax_row.axis("off")
    row_pos = ax_row.get_position()

    fov_by_id = {}
    for r in vor_records:
        fov_by_id.setdefault(r["fov_id"], []).append(r)

    def fov_distinct_pair(fid, mode: str):
        recs = fov_by_id[fid]
        xs = np.array([r["x_um"] for r in recs])
        ys = np.array([r["y_um_flipped"] for r in recs])
        rad = float(0.40 * min(xs.max() - xs.min(), ys.max() - ys.min()))
        if mode == "vertical":
            c1 = (float(np.percentile(xs, 45)), float(np.percentile(ys, 30)))
            c2 = (float(np.percentile(xs, 55)), float(np.percentile(ys, 72)))
        else:
            c1 = (float(np.percentile(xs, 32)), float(np.percentile(ys, 46)))
            c2 = (float(np.percentile(xs, 72)), float(np.percentile(ys, 54)))
        return recs, c1, c2, rad

    n_recs, n_c1, n_c2, n_r = fov_distinct_pair("MEL11_FOV_Normal", "vertical")
    p_recs, p_c1, p_c2, p_r = fov_distinct_pair("MEL11_FOV_Precursor", "vertical")
    m_recs, m_c1, m_c2, m_r = fov_distinct_pair("MEL09_FOV_MIS", "horizontal")

    # 6 distinct spatial circular sub-windows capturing ~120-230 real cells per disk
    circles_spec = [
        (n_recs, n_c1[0], n_c1[1], n_r, "#E87A24", "MEL11-a"),
        (n_recs, n_c2[0], n_c2[1], n_r, "#555555", "MEL11-b"),
        (p_recs, p_c1[0], p_c1[1], p_r, "#4FC4EA", "MEL11-P1"),
        (p_recs, p_c2[0], p_c2[1], p_r, "#555555", "MEL11-P2"),
        (m_recs, m_c1[0], m_c1[1], m_r, "#D64292", "MEL09-a"),
        (m_recs, m_c2[0], m_c2[1], m_r, "#D64292", "MEL09-b"),
    ]

    circ_gs = GridSpecFromSubplotSpec(1, 6, subplot_spec=sub_gs[1, 0], wspace=0.04)
    for idx, (recs, cx, cy, rad, rcol, plbl) in enumerate(circles_spec):
        cax = fig.add_subplot(circ_gs[0, idx])
        _render_circular_voronoi(cax, recs, cx, cy, rad, rcol, plbl)

    # Vertical dashed dividers between Normal | Precursor | Melanoma in situ
    for div_x in (0.333, 0.667):
        ax_row.plot([div_x, div_x], [-0.05, 1.05], color="#999999", linestyle="--", linewidth=0.75, transform=ax_row.transAxes, clip_on=False)

    # Stage labels & 3C-bottom excluded microscopy note
    ax_bot = fig.add_subplot(sub_gs[2, 0])
    ax_bot.set_xlim(0, 1)
    ax_bot.set_ylim(0, 1)
    ax_bot.axis("off")
    ax_bot.text(0.165, 0.82, "Normal", ha="center", va="center", fontsize=7.0, color="#222222")
    ax_bot.text(0.500, 0.82, "Precursor", ha="center", va="center", fontsize=7.0, color="#222222")
    ax_bot.text(0.835, 0.82, "Melanoma in situ", ha="center", va="center", fontsize=7.0, style="italic", color="#222222")
    ax_bot.add_patch(mpatches.Rectangle((0.01, 0.04), 0.98, 0.52, facecolor="#F7F7F7", edgecolor="#AAAAAA", linestyle="--", linewidth=0.65))
    ax_bot.text(0.50, 0.30, "3C-bottom: Matched CyCIF fluorescence overlays (Pan-CK, CD3, CD11C, SOX10, PD1, CD8, PDL1) [Excluded per imaging policy]",
                ha="center", va="center", fontsize=5.8, color="#555555")


def main():
    parser = argparse.ArgumentParser(description="Render Main Figure 3 Panel C-top (6 circular Voronoi crops).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("fig03_c.png"))
    args = parser.parse_args()

    with open(args.paper_root / "runs" / "step03_rcn_lda" / "voronoi_polygons_fov.json", "r", encoding="utf-8") as f:
        vor_records = json.load(f)

    fig = plt.figure(figsize=(7.20, 2.25), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.05, right=0.97, top=0.92, bottom=0.04)
    draw_panel_3c(fig, gs[0, 0], vor_records)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[fig03_c] Saved -> {args.out}")


if __name__ == "__main__":
    main()
