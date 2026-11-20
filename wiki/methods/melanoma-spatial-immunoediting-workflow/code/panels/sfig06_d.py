#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: sfig06/D
Title: mROI sampling counts summary table (S6D-table) + excluded microscopy notice
Input tables: runs/step06_mrseq_deseq2/figs6d_mroi_counts_table.csv
Default size: 3.30 in x 2.80 in (300 dpi)
CLI usage:
  python sfig06_d.py --paper-root <sources_root>/papers/pmc9167783 --out sfig06_d.png
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


def draw_panel_s6d(fig, gs_slot, tab_df: pd.DataFrame):
    """Draw Panel S6D (excluded imaging boxes + mROI counts summary table) inside gs_slot."""
    sub_gs = GridSpecFromSubplotSpec(2, 1, subplot_spec=gs_slot, height_ratios=[1.15, 1.0], hspace=0.14)
    ax_ex = fig.add_subplot(sub_gs[0, 0])
    ax_tab = fig.add_subplot(sub_gs[1, 0])

    ax_ex.text(-0.08, 1.08, "D", transform=ax_ex.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    ax_ex.axis("off")
    ax_ex.set_xlim(0, 1)
    ax_ex.set_ylim(0, 1)
    ax_ex.add_patch(mpatches.FancyBboxPatch(
        (0.02, 0.04), 0.96, 0.92,
        boxstyle="round,pad=0.02,rounding_size=0.02",
        facecolor="#F7F7F7", edgecolor="#999999", linestyle="--", linewidth=0.75,
    ))
    ax_ex.text(0.50, 0.50, "S6D-images: MEL01-1/2/3 PickSeq & GeoMx mROI\nfluorescence overlays (40 μm circles)\n[Excluded per imaging policy (excluded_imaging)]",
               ha="center", va="center", fontsize=5.4, color="#555555")

    ax_tab.axis("off")
    cols = ["Site", "PickSeq\n(N=222)", "GeoMx\n(N=70)", "Local\n(N=120)"]
    cell_txt = [
        [str(r["site"]), str(r["PickSeq_original_N222"]), str(r["GeoMx_original_N70"]), str(r["PickSeq_sampled_N120"])]
        for _, r in tab_df.iterrows()
    ]
    tbl = ax_tab.table(cellText=cell_txt, colLabels=cols, loc="center", cellLoc="center")
    tbl.auto_set_font_size(False)
    tbl.set_fontsize(5.4)
    tbl.scale(1.0, 1.15)
    for (ri, ci), cell in tbl.get_celld().items():
        cell.set_linewidth(0.45)
        cell.set_edgecolor("#555555")
        if ri == 0:
            cell.set_facecolor("#EAEAEA")
            cell.set_text_props(weight="bold")


def main():
    parser = argparse.ArgumentParser(description="Render Supp Figure S6 Panel D (mROI table).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("sfig06_d.png"))
    args = parser.parse_args()

    tab_df = pd.read_csv(args.paper_root / "runs" / "step06_mrseq_deseq2" / "figs6d_mroi_counts_table.csv")
    fig = plt.figure(figsize=(3.30, 2.80), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.06, right=0.96, top=0.90, bottom=0.04)
    draw_panel_s6d(fig, gs[0, 0], tab_df)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[sfig06_d] Saved -> {args.out}")


if __name__ == "__main__":
    main()
