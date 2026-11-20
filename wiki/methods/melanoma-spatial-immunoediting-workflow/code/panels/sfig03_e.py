#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: sfig03/E
Title: Differences between stages p-value numeric heatmap (RCN1-10 x pairwise stage comparisons)
Input tables: runs/step03_rcn_lda/figs3e_rcn_stage_pvalues.csv
Default size: 2.30 in x 3.60 in (300 dpi)
CLI usage:
  python sfig03_e.py --paper-root <sources_root>/papers/pmc9167783 --out sfig03_e.png
"""

import argparse
from pathlib import Path
import sys

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.colors import LinearSegmentedColormap, Normalize
from matplotlib.gridspec import GridSpecFromSubplotSpec
import numpy as np
import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _fig_common import DEFAULT_PAPER_ROOT

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["pdf.fonttype"] = 42


def draw_panel_s3e(fig, gs_slot, pval_df: pd.DataFrame):
    """Draw Panel S3E (RCN1-10 stage p-value numeric heatmap + P-value colorbar) inside gs_slot."""
    sub_gs = GridSpecFromSubplotSpec(2, 1, subplot_spec=gs_slot, height_ratios=[5.0, 0.7], hspace=0.10)
    ax = fig.add_subplot(sub_gs[0, 0])
    ax_cb = fig.add_subplot(sub_gs[1, 0])

    ax.text(-0.18, 1.12, "E", transform=ax.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    ax.set_title("Differences between stages", fontsize=7.2, pad=14)

    rcn_list = [f"RCN{i}" for i in range(1, 11)]
    comps = [
        ("Normal_vs_Precursor", "N v P"),
        ("Precursor_vs_MIS", "P v MIS"),
        ("Precursor_vs_IM", "P v IM"),
        ("MIS_vs_IM", "MIS v IM"),
    ]

    cmap_p = LinearSegmentedColormap.from_list("s3e_p", ["#BA242A", "#D96F56", "#83C8BE"])
    norm_p = Normalize(vmin=0.0, vmax=0.05)

    ax.set_xlim(0, len(comps))
    ax.set_ylim(len(rcn_list), 0)

    for ri, rname in enumerate(rcn_list):
        for ci, (ckey, _) in enumerate(comps):
            row = pval_df[(pval_df["RCN"] == rname) & (pval_df["comparison"] == ckey)]
            pv = float(row["p_value"].iloc[0]) if not row.empty else np.nan
            if not np.isfinite(pv):
                fc = "#111111"
                txt = ""
            elif pv >= 0.05:
                fc = "#A6A6A6"
                txt = f"{pv:.3f}"
            else:
                fc = cmap_p(norm_p(pv))
                txt = f"{pv:.3f}"
            ax.add_patch(mpatches.Rectangle((ci, ri), 1.0, 1.0, facecolor=fc, edgecolor="white", lw=0.6))
            if txt:
                ax.text(ci + 0.5, ri + 0.5, txt, ha="center", va="center", fontsize=5.2, color="white")

    ax.set_xticks(np.arange(len(comps)) + 0.5)
    ax.set_xticklabels([c[1] for c in comps], fontsize=5.8)
    ax.xaxis.tick_top()
    ax.tick_params(axis="x", length=0, pad=2)
    ax.set_yticks(np.arange(len(rcn_list)) + 0.5)
    ax.set_yticklabels(rcn_list, fontsize=5.8)
    ax.yaxis.tick_right()
    ax.tick_params(axis="y", length=0, pad=2)
    for sp in ax.spines.values():
        sp.set_visible(False)

    # Bottom colorbar + ns swatch
    cb_pos = ax_cb.get_position()
    ax_cb.axis("off")
    cb_ax = fig.add_axes([cb_pos.x0 + cb_pos.width * 0.25, cb_pos.y0 + 0.015, cb_pos.width * 0.42, 0.012])
    sm = plt.cm.ScalarMappable(cmap=cmap_p, norm=norm_p)
    cb = fig.colorbar(sm, cax=cb_ax, orientation="horizontal")
    cb.set_ticks([0.0, 0.05])
    cb.set_ticklabels(["0", "0.05"])
    cb.ax.tick_params(labelsize=5.2, length=1.6, pad=1)
    cb.outline.set_linewidth(0.4)
    cb_ax.text(-0.08, 0.5, "P-value", transform=cb_ax.transAxes, fontsize=5.6, va="center", ha="right")

    ax_cb.add_patch(mpatches.Rectangle((0.76, 0.28), 0.08, 0.34, facecolor="#A6A6A6", edgecolor="none"))
    ax_cb.text(0.86, 0.45, "ns", fontsize=5.6, va="center", ha="left")


def main():
    parser = argparse.ArgumentParser(description="Render Supp Figure S3 Panel E (stage p-value heatmap).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("sfig03_e.png"))
    args = parser.parse_args()

    pval_df = pd.read_csv(args.paper_root / "runs" / "step03_rcn_lda" / "figs3e_rcn_stage_pvalues.csv")
    fig = plt.figure(figsize=(2.40, 3.60), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.14, right=0.84, top=0.86, bottom=0.06)
    draw_panel_s3e(fig, gs[0, 0], pval_df)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[sfig03_e] Saved -> {args.out}")


if __name__ == "__main__":
    main()
