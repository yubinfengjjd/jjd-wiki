#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: fig05/E
Title: TCC spatial Voronoi tissue overview + yellow circular zoomed neighborhood + excluded CyCIF inset
Input tables:
  - runs/step05_tcc_spatial_lag/fig5e_tcc_voronoi_im.json
  - runs/step03_rcn_lda/voronoi_polygons_fov.json
Default size: 4.50 in x 2.80 in (300 dpi)
CLI usage:
  python fig05_e.py --paper-root <sources_root>/papers/pmc9167783 --out fig05_e.png
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

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _fig_common import DEFAULT_PAPER_ROOT

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["pdf.fonttype"] = 42

TCC_COLORS_5 = {
    "TCC1": "#EC607A",
    "TCC2": "#48C999",
    "TCC3": "#F7C654",
    "TCC4": "#227BA3",
    "TCC5": "#0F3D4C",
    "TCC6": "#F19B8E",
    "TCC7": "#F3EED4",
    "TCC8": "#B8E1DF",
    "TCC9": "#8B7D8B",
    "TCC10": "#696D7D",
    "Stroma": "#181818",
}


def draw_panel_5e(fig, gs_slot, tcc_vor: list[dict], all_vor: list[dict]):
    """Draw Panel 5E (IM overview + excluded microscopy box + zoomed circular TCC Voronoi + legend) inside gs_slot."""
    im_all = [r for r in all_vor if r["fov_id"] == "MEL09_FOV_IM"]
    tcc_map = {r["cell_uid"]: r["TCC"] for r in tcc_vor}

    polys_all = [np.asarray(r["polygon"]) for r in im_all]
    cols_all = [TCC_COLORS_5.get(tcc_map.get(r["cell_uid"], "Stroma"), "#181818") for r in im_all]
    xs = [r["x_um"] for r in im_all]
    ys = [r["y_um_flipped"] for r in im_all]

    # Focus circle centered on dense TCC tumor cluster
    txs = [r["x_um"] for r in tcc_vor]
    tys = [r["y_um_flipped"] for r in tcc_vor]
    cx, cy = float(np.median(txs)), float(np.median(tys))
    rad = 260.0

    sub_gs = GridSpecFromSubplotSpec(
        2, 3,
        subplot_spec=gs_slot,
        height_ratios=[1.0, 0.85],
        width_ratios=[1.15, 1.35, 0.55],
        hspace=0.10,
        wspace=0.08,
    )

    ax_top = fig.add_subplot(sub_gs[0, 0])
    ax_excl = fig.add_subplot(sub_gs[1, 0])
    ax_zoom = fig.add_subplot(sub_gs[:, 1])
    ax_leg = fig.add_subplot(sub_gs[:, 2])

    ax_top.text(-0.14, 1.12, "E", transform=ax_top.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")

    pc_top = PolyCollection(polys_all, facecolors=cols_all, edgecolors="#222222", linewidths=0.10)
    ax_top.add_collection(pc_top)
    ax_top.add_patch(mpatches.Circle((cx, cy), rad, facecolor="none", edgecolor="#F2DC35", linewidth=1.35, zorder=5))
    ax_top.set_xlim(min(xs), max(xs))
    ax_top.set_ylim(min(ys), max(ys))
    ax_top.set_aspect("equal")
    ax_top.axis("off")

    # Bottom-left excluded CyCIF microscopy box
    ax_excl.axis("off")
    ax_excl.set_xlim(0, 1)
    ax_excl.set_ylim(0, 1)
    ax_excl.add_patch(mpatches.FancyBboxPatch(
        (0.02, 0.04), 0.96, 0.92,
        boxstyle="round,pad=0.02,rounding_size=0.03",
        facecolor="#F7F7F7", edgecolor="#999999", linestyle="--", linewidth=0.75,
    ))
    ax_excl.text(0.50, 0.50, "5E-bottom: CyCIF\n(CD163, MITF, KI67, MHC-II)\n[Excluded per imaging policy]",
                 ha="center", va="center", fontsize=5.3, color="#555555")

    # Right zoomed circular Voronoi inset
    clip_circ = mpatches.Circle((cx, cy), rad, transform=ax_zoom.transData)
    ax_zoom.add_patch(mpatches.Circle((cx, cy), rad, facecolor="#181818", edgecolor="none", zorder=1))
    pc_z = PolyCollection(polys_all, facecolors=cols_all, edgecolors="#444444", linewidths=0.22, zorder=2)
    pc_z.set_clip_path(clip_circ)
    ax_zoom.add_collection(pc_z)
    ax_zoom.add_patch(mpatches.Circle((cx, cy), rad, facecolor="none", edgecolor="#F2DC35", linewidth=1.8, zorder=5))
    ax_zoom.set_xlim(cx - rad * 1.06, cx + rad * 1.06)
    ax_zoom.set_ylim(cy - rad * 1.06, cy + rad * 1.06)
    ax_zoom.set_aspect("equal")
    ax_zoom.axis("off")

    # Legend TCC1..10 + Stroma
    ax_leg.axis("off")
    keys = [f"TCC{i}" for i in range(1, 11)] + ["Stroma"]
    handles = [mpatches.Patch(facecolor=TCC_COLORS_5[k], label=k) for k in keys]
    ax_leg.legend(handles=handles, loc="center left", frameon=False, fontsize=5.6, handlelength=0.9, handleheight=0.8, labelspacing=0.25)


def main():
    parser = argparse.ArgumentParser(description="Render Main Figure 5 Panel E (TCC spatial Voronoi + zoom).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("fig05_e.png"))
    args = parser.parse_args()

    with open(args.paper_root / "runs" / "step05_tcc_spatial_lag" / "fig5e_tcc_voronoi_im.json", "r", encoding="utf-8") as f:
        tcc_vor = json.load(f)
    with open(args.paper_root / "runs" / "step03_rcn_lda" / "voronoi_polygons_fov.json", "r", encoding="utf-8") as f:
        all_vor = json.load(f)

    fig = plt.figure(figsize=(4.50, 2.80), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.05, right=0.96, top=0.92, bottom=0.04)
    draw_panel_5e(fig, gs[0, 0], tcc_vor, all_vor)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[fig05_e] Saved -> {args.out}")


if __name__ == "__main__":
    main()
