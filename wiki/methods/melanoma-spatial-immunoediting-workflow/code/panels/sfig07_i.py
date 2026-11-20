#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: sfig07/I
Title: Epidermis & Dermis compartment cell composition bars (Stroma, Myeloid, Lymphoid) + excluded CyCIF strip
Input tables: runs/step04_spatial_interaction/fig7fg_compartment_cell_composition.csv
Default size: 7.00 in x 2.70 in (300 dpi)
CLI usage:
  python sfig07_i.py --paper-root <sources_root>/papers/pmc9167783 --out sfig07_i.png
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

TRACK_GROUPS = {
    "Stroma": [
        ("Ker", "Keratinocytes", "#8A6240"),
        ("LC", "Langerhans", "#D3E298"),
        ("Mast cell", "Mast cells", "#C8D7E8"),
        ("Endo", "Endothelial", "#CBE4D0"),
        ("Mel", "Melanocytes", "#5B2C82"),
        ("Unknown", "Other/Stroma", "#DCDCDC"),
    ],
    "Myeloid": [
        ("PD-L1+ DC", "PDL1+ DCs", "#1A5B8C"),
        ("PD-L1+ mac", "PDL1+ Macs", "#2CA298"),
        ("DC", "Dendritic", "#227BA3"),
        ("CD11C+ mac", "CD11C+ macs", "#74A892"),
        ("Mac", "Macrophages", "#98CD87"),
    ],
    "Lymphoid": [
        ("Tex", "Exhausted", "#EA7AA6"),
        ("CTL", "CTL", "#F2C84B"),
        ("Treg", "Tregs", "#E3256B"),
        ("Th", "T helper", "#F08C4B"),
        ("PD1+ CTL", "PD1+ CTL", "#D95F43"),
    ],
}


def _draw_3track_bars(ax, row: pd.Series, show_ylabels: bool = False):
    tracks = ["Stroma", "Myeloid", "Lymphoid"]
    ax.set_xlim(0, 1.0)
    ax.set_ylim(len(tracks), 0)
    for ti, trk in enumerate(tracks):
        items = TRACK_GROUPS[trk]
        vals = [float(row[col]) if col in row.index else 0.0 for col, _, _ in items]
        tot = sum(vals)
        vals = [v / tot if tot > 0 else 0.0 for v in vals]
        xc = 0.0
        for (_, _, col_hex), v in zip(items, vals):
            if v > 0:
                ax.add_patch(mpatches.Rectangle((xc, ti + 0.08), v, 0.84, facecolor=col_hex, edgecolor="white", lw=0.25))
                xc += v
    ax.set_xticks([])
    if show_ylabels:
        ax.set_yticks([0.5, 1.5, 2.5])
        ax.set_yticklabels(tracks, fontsize=5.4)
        ax.yaxis.tick_right()
        ax.tick_params(axis="y", length=0, pad=2)
    else:
        ax.set_yticks([])
    for sp in ax.spines.values():
        sp.set_linewidth(0.55)


def draw_panel_s7i(fig, gs_slot, df_7fg: pd.DataFrame):
    """Draw Panel S7I (Epidermis/Dermis Stroma-Myeloid-Lymphoid composition bars + excluded CyCIF + legend)."""
    sub_gs = GridSpecFromSubplotSpec(4, 3, subplot_spec=gs_slot, height_ratios=[0.65, 0.72, 0.65, 0.55], hspace=0.18, wspace=0.10)

    stages = [("MIS", "Melanoma in situ"), ("Normal", "Normal (proxy)"), ("IM", "Invasive Melanoma")]
    for ci, (st_k, st_lbl) in enumerate(stages):
        ax_epi = fig.add_subplot(sub_gs[0, ci])
        ax_der = fig.add_subplot(sub_gs[2, ci])
        epi_row = df_7fg[(df_7fg["Stage"] == st_k) & (df_7fg["compartment_proxy"] == "Epidermis")]
        der_row = df_7fg[(df_7fg["Stage"] == st_k) & (df_7fg["compartment_proxy"] == "Dermis")]
        _draw_3track_bars(ax_epi, epi_row.iloc[0] if not epi_row.empty else pd.Series(dtype=float), show_ylabels=(ci == 2))
        _draw_3track_bars(ax_der, der_row.iloc[0] if not der_row.empty else pd.Series(dtype=float), show_ylabels=(ci == 2))
        ax_epi.set_title(st_lbl, fontsize=6.6, pad=3)
        if ci == 0:
            ax_epi.text(-0.14, 1.32, "I", transform=ax_epi.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
            ax_epi.set_ylabel("EPIDERMIS", fontsize=5.8, color="#3E7A56", fontweight="bold", labelpad=3)
            ax_der.set_ylabel("DERMIS", fontsize=5.8, color="#D98B38", fontweight="bold", labelpad=3)

    ax_mid = fig.add_subplot(sub_gs[1, :])
    ax_mid.axis("off")
    ax_mid.set_xlim(0, 1)
    ax_mid.set_ylim(0, 1)
    ax_mid.add_patch(mpatches.FancyBboxPatch(
        (0.01, 0.05), 0.98, 0.90,
        boxstyle="round,pad=0.02,rounding_size=0.02",
        facecolor="#F7F7F7", edgecolor="#999999", linestyle="--", linewidth=0.75,
    ))
    ax_mid.text(0.50, 0.50, "S7I-middle: Matched CyCIF fluorescence overlays (HLA-DPB1, PD1 across MIS / Regression)\n[Excluded per imaging policy (excluded_imaging)]",
                ha="center", va="center", fontsize=5.6, color="#555555")

    ax_leg = fig.add_subplot(sub_gs[3, :])
    ax_leg.axis("off")
    handles = []
    for trk in ["Stroma", "Myeloid", "Lymphoid"]:
        for _, lbl, col_hex in TRACK_GROUPS[trk]:
            handles.append(mpatches.Patch(facecolor=col_hex, label=lbl))
    ax_leg.legend(handles=handles, loc="center", ncol=6, frameon=False, fontsize=4.8, handlelength=0.85, handleheight=0.65, columnspacing=0.65, labelspacing=0.20)


def main():
    parser = argparse.ArgumentParser(description="Render Supp Figure S7 Panel I (compartment composition).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("sfig07_i.png"))
    args = parser.parse_args()

    df_7fg = pd.read_csv(args.paper_root / "runs" / "step04_spatial_interaction" / "fig7fg_compartment_cell_composition.csv")
    fig = plt.figure(figsize=(7.00, 2.80), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.06, right=0.92, top=0.90, bottom=0.04)
    draw_panel_s7i(fig, gs[0, 0], df_7fg)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[sfig07_i] Saved -> {args.out}")


if __name__ == "__main__":
    main()
