#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: fig07/G
Title: Epidermis vs Dermis cell composition horizontal stacked bars + excluded CyCIF inset
Input tables: runs/step04_spatial_interaction/fig7fg_compartment_cell_composition.csv
Default size: 2.10 in x 2.10 in (300 dpi)
CLI usage:
  python fig07_g.py --paper-root <sources_root>/papers/pmc9167783 --out fig07_g.png
"""

import argparse
from pathlib import Path
import sys

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.gridspec import GridSpecFromSubplotSpec
import numpy as np
import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _fig_common import DEFAULT_PAPER_ROOT

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["pdf.fonttype"] = 42

COMP_7G_CATS = [
    ("Other myeloid", ["Unknown", "Endo", "Mac", "Mast cell", "CD11C+ mac"], "#CCCCCC"),
    ("APC", ["DC", "LC", "PD-L1+ DC", "PD-L1+ mac"], "#EAE157"),
    ("Keratinocytes", ["Ker"], "#8A5E40"),
    ("Melanocytes", ["Mel"], "#C8C8C8"),
    ("Treg", ["Treg"], "#EB1D69"),
    ("CTL", ["CTL", "Th", "PD1+ CTL", "Tex"], "#B61E24"),
]


def _draw_hbar(ax, row: pd.Series, title: str, show_xticks: bool = False):
    ax.set_xlim(0, 1.0)
    ax.set_ylim(0, 1.0)
    vals = [sum(float(row[c]) for c in cols if c in row.index) for _, cols, _ in COMP_7G_CATS]
    tot = sum(vals)
    vals = [v / tot if tot > 0 else 0.0 for v in vals]
    xc = 0.0
    for (_, _, col), v in zip(COMP_7G_CATS, vals):
        if v > 0:
            ax.add_patch(mpatches.Rectangle((xc, 0.15), v, 0.70, facecolor=col, edgecolor="white", lw=0.25))
            xc += v
    ax.set_title(title, fontsize=6.4, loc="left", pad=2)
    ax.set_yticks([])
    if show_xticks:
        ax.set_xticks([0.0, 0.5, 1.0])
        ax.set_xticklabels(["0.0", "0.5", "1.0"], fontsize=5.5)
        ax.set_xlabel("Fraction of cells", fontsize=6.2, labelpad=2)
    else:
        ax.set_xticks([])
    for sp in ("top", "right", "left"):
        ax.spines[sp].set_visible(False)
    ax.spines["bottom"].set_visible(show_xticks)
    ax.spines["bottom"].set_linewidth(0.65)


def draw_panel_7g(fig, gs_slot, df_7fg: pd.DataFrame):
    """Draw Panel 7G (Epidermis bar + excluded microscopy box + Dermis bar) inside gs_slot."""
    sub_gs = GridSpecFromSubplotSpec(3, 1, subplot_spec=gs_slot, height_ratios=[0.32, 0.90, 0.34], hspace=0.22)
    ax_epi = fig.add_subplot(sub_gs[0, 0])
    ax_mid = fig.add_subplot(sub_gs[1, 0])
    ax_der = fig.add_subplot(sub_gs[2, 0])

    ax_epi.text(-0.14, 1.35, "G", transform=ax_epi.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")

    epi_rows = df_7fg[df_7fg["compartment_proxy"] == "Epidermis"]
    der_rows = df_7fg[df_7fg["compartment_proxy"] == "Dermis"]
    epi_mean = epi_rows.mean(numeric_only=True)
    der_mean = der_rows.mean(numeric_only=True)

    _draw_hbar(ax_epi, epi_mean, "Epidermis", show_xticks=False)
    _draw_hbar(ax_der, der_mean, "Dermis", show_xticks=True)

    ax_mid.axis("off")
    ax_mid.set_xlim(0, 1)
    ax_mid.set_ylim(0, 1)
    ax_mid.add_patch(mpatches.FancyBboxPatch(
        (0.02, 0.04), 0.96, 0.92,
        boxstyle="round,pad=0.02,rounding_size=0.03",
        facecolor="#F7F7F7", edgecolor="#999999", linestyle="--", linewidth=0.75,
    ))
    ax_mid.text(0.50, 0.50, "7G-middle: CyCIF\n(Epidermis / Dermis MHC-II, PD1)\n[Excluded per imaging policy]",
                ha="center", va="center", fontsize=5.2, color="#555555")


def main():
    parser = argparse.ArgumentParser(description="Render Main Figure 7 Panel G (Epidermis/Dermis bars).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("fig07_g.png"))
    args = parser.parse_args()

    df_7fg = pd.read_csv(args.paper_root / "runs" / "step04_spatial_interaction" / "fig7fg_compartment_cell_composition.csv")
    fig = plt.figure(figsize=(2.20, 2.20), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.10, right=0.95, top=0.86, bottom=0.18)
    draw_panel_7g(fig, gs[0, 0], df_7fg)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[fig07_g] Saved -> {args.out}")


if __name__ == "__main__":
    main()
