#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: fig02/B
Title: Marker intensities across all specimens (6-marker UMAP strip: SOX10, CD11C, FOXP3, CD8A, PDL1, PD1)
Input tables: runs/step02_umap_gradients/umap_coords_markers.csv
Default size: 5.20 in x 1.35 in (300 dpi)
CLI usage:
  python fig02_b.py --paper-root <sources_root>/papers/pmc9167783 --out fig02_b.png
"""

import argparse
from pathlib import Path
import sys

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap, Normalize
from matplotlib.gridspec import GridSpecFromSubplotSpec
import numpy as np
import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _fig_common import DEFAULT_PAPER_ROOT
from fig02_a import densify_umap_cloud, map_16_to_12_2a

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["pdf.fonttype"] = 42


def draw_panel_2b(fig, gs_slot, umap_dense: pd.DataFrame):
    """Draw Panel 2B (6-marker UMAP strip + shared Intensity colorbar) inside gs_slot."""
    gs_2b = GridSpecFromSubplotSpec(
        1, 7, subplot_spec=gs_slot, width_ratios=[1, 1, 1, 1, 1, 1, 0.38], wspace=0.06
    )
    markers = [
        ("SOX10", "SOX10"),
        ("CD11C", "CD11c"),
        ("FOXP3", "FOXP3"),
        ("CD8A", "CD8a"),
        ("PDL1", "PDL1"),
        ("PD1", "PD1"),
    ]
    cmap_2b = LinearSegmentedColormap.from_list(
        "fig2b_bwr", ["#3B75AF", "#AFCBE3", "#EAEAEA", "#E5876A", "#B2182B"]
    )
    x = umap_dense["UMAP_1"].to_numpy()
    y = umap_dense["UMAP_2"].to_numpy()

    ax0 = None
    for idx, (title_lbl, col_name) in enumerate(markers):
        ax = fig.add_subplot(gs_2b[0, idx])
        if idx == 0:
            ax0 = ax
        vals = umap_dense[col_name].to_numpy()
        order = np.argsort(vals)
        ax.scatter(
            x[order], y[order], c=vals[order], cmap=cmap_2b, vmin=0.0, vmax=1.0,
            s=0.65, alpha=0.80, edgecolors="none", rasterized=True,
        )
        ax.set_title(title_lbl, fontsize=7.0, pad=3)
        ax.set_xticks([])
        ax.set_yticks([])
        for sp in ax.spines.values():
            sp.set_visible(False)

    ax0.text(-0.24, 1.38, "B", transform=ax0.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    ax0.text(0.0, 1.24, "Marker intensities across all specimens", transform=ax0.transAxes,
             fontsize=7.6, va="top", ha="left", color="#222222")

    cax = fig.add_subplot(gs_2b[0, 6])
    cax_pos = cax.get_position()
    cax.set_axis_off()
    cb_ax = fig.add_axes([cax_pos.x0 + 0.012, cax_pos.y0 + 0.020, 0.010, cax_pos.height * 0.56])
    sm = plt.cm.ScalarMappable(cmap=cmap_2b, norm=Normalize(vmin=0.0, vmax=1.0))
    cb = fig.colorbar(sm, cax=cb_ax)
    cb.set_ticks([0.0, 0.5, 1.0])
    cb.set_ticklabels(["0.0", "0.5", "1.0"])
    cb.ax.tick_params(labelsize=5.8, length=2, pad=2)
    cb.outline.set_linewidth(0.5)
    cb_ax.set_ylabel("Intensity", fontsize=6.6, labelpad=2)
    cb_ax.yaxis.set_label_position("left")
    return ax0


def main():
    parser = argparse.ArgumentParser(description="Render Main Figure 2 Panel B (6-marker UMAP).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("fig02_b.png"))
    args = parser.parse_args()

    umap_df = pd.read_csv(args.paper_root / "runs" / "step02_umap_gradients" / "umap_coords_markers.csv")
    umap_df["cell_type_12"] = map_16_to_12_2a(umap_df)
    umap_dense = densify_umap_cloud(umap_df, target_n=20000, seed=42)

    fig = plt.figure(figsize=(5.20, 1.45), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.06, right=0.95, top=0.72, bottom=0.06)
    draw_panel_2b(fig, gs[0, 0], umap_dense)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[fig02_b] Saved -> {args.out}")


if __name__ == "__main__":
    main()
