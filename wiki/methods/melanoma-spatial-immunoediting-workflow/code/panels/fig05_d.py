#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: fig05/D
Title: Mapping of TCC1-10 to physical location (5x2 spatial binary scatter grid + Immune noninteracting/interacting bars)
Input tables:
  - runs/step05_tcc_spatial_lag/fig5d_tcc_spatial_map.csv
  - runs/step03_rcn_lda/fov_cells_with_rcn.csv
Default size: 3.10 in x 6.00 in (300 dpi)
CLI usage:
  python fig05_d.py --paper-root <sources_root>/papers/pmc9167783 --out fig05_d.png
"""

import argparse
from pathlib import Path
import sys

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.gridspec import GridSpecFromSubplotSpec
import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _fig_common import DEFAULT_PAPER_ROOT

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["pdf.fonttype"] = 42


def draw_panel_5d(fig, gs_slot, d5d: pd.DataFrame, fov_df: pd.DataFrame):
    """Draw Panel 5D (TCC1-10 physical spatial map grid) inside gs_slot."""
    # Order: 8 non-interacting TCCs in top 4x2, 2 interacting TCCs in bottom 1x2
    tcc_grid_order = [
        "TCC1", "TCC2",
        "TCC5", "TCC6",
        "TCC7", "TCC8",
        "TCC9", "TCC10",
        "TCC3", "TCC4",
    ]

    sub_gs = GridSpecFromSubplotSpec(
        6, 3,
        subplot_spec=gs_slot,
        height_ratios=[1.0, 1.0, 1.0, 1.0, 1.0, 0.25],
        width_ratios=[1.0, 1.0, 0.14],
        hspace=0.22,
        wspace=0.08,
    )

    axes = []
    for idx, tname in enumerate(tcc_grid_order):
        r, c = divmod(idx, 2)
        ax = fig.add_subplot(sub_gs[r, c])
        axes.append(ax)

        sub_t = d5d[d5d["TCC"] == tname]
        # Pick primary FOV where this TCC appears
        if not sub_t.empty:
            fov_id = sub_t["fov_id"].value_counts().index[0]
        else:
            fov_id = "MEL09_FOV_IM"
        bg = fov_df[fov_df["fov_id"] == fov_id]
        ymax = bg["Y_um"].max()

        ax.scatter(bg["X_um"], ymax - bg["Y_um"], s=2.2, color="#D8D8D8", edgecolors="none", rasterized=True, zorder=1)
        fg = sub_t[sub_t["fov_id"] == fov_id]
        if not fg.empty:
            ax.scatter(fg["X_um"], ymax - fg["Y_um"], s=9.0, color="#194B5F", edgecolors="none", zorder=3)

        ax.set_title(tname, fontsize=6.4, loc="left", pad=2)
        st_tag = str(bg["Stage"].iloc[0]) if not bg.empty else ""
        ax.text(0.96, 0.06, st_tag, transform=ax.transAxes, ha="right", va="bottom", fontsize=5.0, color="#777777")
        ax.set_xticks([])
        ax.set_yticks([])
        for sp in ax.spines.values():
            sp.set_visible(False)

    axes[0].text(-0.22, 1.24, "D", transform=axes[0].transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    fig.text(
        0.5 * (axes[0].get_position().x0 + axes[1].get_position().x1),
        axes[0].get_position().y1 + 0.022,
        "Mapping of TCCs to physical location", ha="center", va="bottom", fontsize=7.6,
    )

    # Dashed divider between row 3 and row 4 (Immune noninteracting vs Immune interacting)
    ax_non = fig.add_subplot(sub_gs[0:4, 2])
    ax_non.axis("off")
    ax_non.add_patch(mpatches.Rectangle((0.15, 0.01), 0.70, 0.98, facecolor="#F5F3BE", edgecolor="none"))
    ax_non.text(0.50, 0.50, "Immune noninteracting", rotation=270, ha="center", va="center", fontsize=6.0, color="#222222")

    ax_int = fig.add_subplot(sub_gs[4, 2])
    ax_int.axis("off")
    ax_int.add_patch(mpatches.Rectangle((0.15, 0.02), 0.70, 0.96, facecolor="#EAE342", edgecolor="none"))
    ax_int.text(0.50, 0.50, "Immune\ninteracting", rotation=270, ha="center", va="center", fontsize=5.6, color="#222222")

    # Dashed horizontal separator across row 3->4
    p3 = axes[6].get_position()
    p4 = axes[8].get_position()
    y_sep = 0.5 * (p3.y0 + p4.y1)
    fig.add_artist(plt.Line2D([p3.x0, axes[1].get_position().x1], [y_sep, y_sep], color="#666666", linestyle="--", lw=0.75))

    # Bottom legend: All cells | Cells within TCC
    ax_leg = fig.add_subplot(sub_gs[5, :2])
    ax_leg.axis("off")
    handles = [
        mpatches.Patch(facecolor="#D8D8D8", label="All cells"),
        mpatches.Patch(facecolor="#194B5F", label="Cells within TCC"),
    ]
    ax_leg.legend(handles=handles, loc="center", ncol=2, frameon=False, fontsize=6.0, handlelength=0.9, handleheight=0.8)


def main():
    parser = argparse.ArgumentParser(description="Render Main Figure 5 Panel D (TCC spatial map grid).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("fig05_d.png"))
    args = parser.parse_args()

    d5d = pd.read_csv(args.paper_root / "runs" / "step05_tcc_spatial_lag" / "fig5d_tcc_spatial_map.csv")
    fov_df = pd.read_csv(args.paper_root / "runs" / "step03_rcn_lda" / "fov_cells_with_rcn.csv")

    fig = plt.figure(figsize=(3.10, 6.00), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.06, right=0.94, top=0.92, bottom=0.04)
    draw_panel_5d(fig, gs[0, 0], d5d, fov_df)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[fig05_d] Saved -> {args.out}")


if __name__ == "__main__":
    main()
