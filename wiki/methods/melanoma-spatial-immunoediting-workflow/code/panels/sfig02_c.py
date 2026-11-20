#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: sfig02/C
Title: RCN1 spatial highlight on Voronoi polygons (S2C-top) + excluded S2C-mid/bottom microscopy note
Input tables: runs/step03_rcn_lda/voronoi_polygons_fov.json
Default size: 3.30 in x 2.30 in (300 dpi)
CLI usage:
  python sfig02_c.py --paper-root <sources_root>/papers/pmc9167783 --out sfig02_c.png
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


def draw_panel_s2c(fig, gs_slot, vor_records: list[dict]):
    """Draw Panel S2C-top (RCN1 burgundy highlight over grey tissue Voronoi) + S2C-mid/bot excluded box."""
    sub_gs = GridSpecFromSubplotSpec(2, 1, subplot_spec=gs_slot, height_ratios=[1.15, 0.85], hspace=0.10)
    ax_v = fig.add_subplot(sub_gs[0, 0])
    ax_ex = fig.add_subplot(sub_gs[1, 0])

    ax_v.text(-0.08, 1.10, "C", transform=ax_v.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")

    # Use MEL09_FOV_MIS (has 111 RCN1 cells forming epidermal layer!)
    recs = [r for r in vor_records if r["fov_id"] == "MEL09_FOV_MIS"]
    polys = [np.asarray(r["polygon"]) for r in recs]
    cols = ["#A84261" if r["RCN"] == "RCN1" else "#E2E2E2" for r in recs]
    xs = [r["x_um"] for r in recs]
    ys = [r["y_um_flipped"] for r in recs]

    pc = PolyCollection(polys, facecolors=cols, edgecolors="#CCCCCC", linewidths=0.12)
    ax_v.add_collection(pc)
    ax_v.set_xlim(min(xs), max(xs))
    ax_v.set_ylim(min(ys), max(ys))
    ax_v.set_aspect("equal")
    ax_v.add_patch(mpatches.Rectangle((0.02, 0.86), 0.045, 0.09, transform=ax_v.transAxes, facecolor="#A84261", edgecolor="none"))
    ax_v.text(0.08, 0.905, "RCN1 (Epidermis)", transform=ax_v.transAxes, fontsize=6.6, va="center", ha="left", color="#111111")
    ax_v.axis("off")

    ax_ex.axis("off")
    ax_ex.set_xlim(0, 1)
    ax_ex.set_ylim(0, 1)
    ax_ex.add_patch(mpatches.FancyBboxPatch(
        (0.02, 0.04), 0.96, 0.92,
        boxstyle="round,pad=0.02,rounding_size=0.02",
        facecolor="#F7F7F7", edgecolor="#999999", linestyle="--", linewidth=0.75,
    ))
    ax_ex.text(0.50, 0.50, "S2C-mid/bottom: CyCIF (DNA, PanCK, SOX10, CD3) & H&E\n[Excluded per imaging policy (excluded_imaging)]",
               ha="center", va="center", fontsize=5.5, color="#555555")


def main():
    parser = argparse.ArgumentParser(description="Render Supp Figure S2 Panel C (RCN1 Voronoi highlight).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("sfig02_c.png"))
    args = parser.parse_args()

    with open(args.paper_root / "runs" / "step03_rcn_lda" / "voronoi_polygons_fov.json", "r", encoding="utf-8") as f:
        vor_records = json.load(f)

    fig = plt.figure(figsize=(3.30, 2.30), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.06, right=0.96, top=0.90, bottom=0.04)
    draw_panel_s2c(fig, gs[0, 0], vor_records)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[sfig02_c] Saved -> {args.out}")


if __name__ == "__main__":
    main()
