#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: sfig03/D
Title: Spatial highlight maps for RCN2 and RCN3/4 in IM FOV (MEL09)
Input tables: runs/step03_rcn_lda/fov_cells_with_rcn.csv
Default size: 2.30 in x 3.50 in (300 dpi)
CLI usage:
  python sfig03_d.py --paper-root <sources_root>/papers/pmc9167783 --out sfig03_d.png
"""

import argparse
from pathlib import Path
import sys

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpecFromSubplotSpec
import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _fig_common import DEFAULT_PAPER_ROOT

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["pdf.fonttype"] = 42


def draw_panel_s3d(fig, gs_slot, fov_df: pd.DataFrame):
    """Draw Panel S3D (MEL09: RCN2 and MEL09: RCN3 and 4 spatial highlights) inside gs_slot."""
    sub = fov_df[fov_df["fov_id"] == "MEL09_FOV_IM"].copy()
    ymax = sub["Y_um"].max()
    x = sub["X_um"].to_numpy()
    y = ymax - sub["Y_um"].to_numpy()

    sub_gs = GridSpecFromSubplotSpec(2, 1, subplot_spec=gs_slot, hspace=0.22)
    specs = [
        ("MEL09: RCN2", sub["RCN"].isin(["RCN2"]).to_numpy()),
        ("MEL09: RCN3 and 4", sub["RCN"].isin(["RCN3", "RCN4"]).to_numpy()),
    ]
    axes = []
    for idx, (title, mask) in enumerate(specs):
        ax = fig.add_subplot(sub_gs[idx, 0])
        axes.append(ax)
        ax.scatter(x[~mask], y[~mask], s=4.0, color="#DCDCDC", edgecolors="none", zorder=1)
        ax.scatter(x[mask], y[mask], s=10.0, color="#1F355C", edgecolors="none", zorder=3)
        ax.set_title(title, fontsize=7.0, pad=3)
        ax.set_xticks([])
        ax.set_yticks([])
        for sp in ax.spines.values():
            sp.set_linewidth(0.7)
            sp.set_color("#222222")

    axes[0].text(-0.14, 1.15, "D", transform=axes[0].transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    return axes


def main():
    parser = argparse.ArgumentParser(description="Render Supp Figure S3 Panel D (RCN2 & RCN3/4 spatial).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("sfig03_d.png"))
    args = parser.parse_args()

    fov_df = pd.read_csv(args.paper_root / "runs" / "step03_rcn_lda" / "fov_cells_with_rcn.csv")
    fig = plt.figure(figsize=(2.30, 3.50), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.10, right=0.95, top=0.90, bottom=0.04)
    draw_panel_s3d(fig, gs[0, 0], fov_df)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[sfig03_d] Saved -> {args.out}")


if __name__ == "__main__":
    main()
