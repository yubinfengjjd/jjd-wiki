#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: sfig06/A
Title: Proliferation & signaling marker positivity across progression stages (Panel 2 proxy)
Input tables: runs/step02_umap_gradients/figs6a_proliferation_markers_by_stage_proxy.csv
Default size: 3.40 in x 2.20 in (300 dpi)
CLI usage:
  python sfig06_a.py --paper-root <sources_root>/papers/pmc9167783 --out sfig06_a.png
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


def draw_panel_s6a(fig, gs_slot, df_s6a: pd.DataFrame):
    """Draw Panel S6A (IM vs MIS/Normal proliferation marker % positive bars + stage pies) inside gs_slot."""
    sub_gs = GridSpecFromSubplotSpec(1, 2, subplot_spec=gs_slot, width_ratios=[0.75, 1.35], wspace=0.22)
    ax_pie = fig.add_subplot(sub_gs[0, 0])
    ax_bar = fig.add_subplot(sub_gs[0, 1])

    ax_pie.text(-0.18, 1.12, "A", transform=ax_pie.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    ax_pie.axis("off")

    # Summary pies of CCND1+ vs CCND1- fraction in IM vs Normal/MIS
    im_ccnd1 = float(df_s6a.loc[(df_s6a["Stage"] == "IM") & (df_s6a["marker"] == "CCND1"), "pct_positive"].iloc[0])
    nm_ccnd1 = float(df_s6a.loc[(df_s6a["Stage"] == "Normal") & (df_s6a["marker"] == "CCND1"), "pct_positive"].iloc[0])

    p_bbox = ax_pie.get_position()
    fw, fh = fig.get_figwidth(), fig.get_figheight()
    diam = min(p_bbox.width * fw * 0.68, p_bbox.height * fh * 0.40)
    pw, ph = diam / fw, diam / fh

    for lbl, pct, cy_f in [("IM", im_ccnd1, 0.72), ("N", nm_ccnd1, 0.28)]:
        cx = p_bbox.x0 + p_bbox.width * 0.56
        cy = p_bbox.y0 + p_bbox.height * cy_f
        pax = fig.add_axes([cx - 0.5 * pw, cy - 0.5 * ph, pw, ph])
        pax.pie([100.0 - pct, pct], colors=["#CCCCCC", "#6B3E26"], startangle=90, wedgeprops=dict(lw=0.3, edgecolor="white"))
        pax.set_aspect("equal")
        ax_pie.text(0.05, cy_f, lbl, fontsize=6.4, va="center", ha="left")
    ax_pie.text(0.50, 0.02, "CCND1$^+$ (proxy)", fontsize=5.4, ha="center", va="bottom")

    # Grouped barplot of 5 Panel-2 markers across IM vs MIS
    markers = [m for m in ["CCND1", "MYC", "pERK", "pS6", "S100a"] if m in df_s6a["marker"].values]
    y = np.arange(len(markers))
    im_vals = [float(df_s6a.loc[(df_s6a["Stage"] == "IM") & (df_s6a["marker"] == m), "pct_positive"].iloc[0]) for m in markers]
    mis_vals = [float(df_s6a.loc[(df_s6a["Stage"] == "MIS") & (df_s6a["marker"] == m), "pct_positive"].iloc[0]) for m in markers]

    ax_bar.barh(y - 0.18, mis_vals, height=0.34, color="#7A7A7A", label="MIS")
    ax_bar.barh(y + 0.18, im_vals, height=0.34, color="#C69D53", label="IM")
    ax_bar.set_yticks(y)
    ax_bar.set_yticklabels([f"{m} (%)" for m in markers], fontsize=5.8)
    ax_bar.invert_yaxis()
    ax_bar.set_xlim(0, 105)
    ax_bar.set_xticks([0, 50, 100])
    ax_bar.tick_params(axis="x", labelsize=5.4, length=2.0, pad=1.5)
    ax_bar.set_xlabel("% positive (Panel 2 proxy)", fontsize=5.8, labelpad=2)
    ax_bar.legend(loc="upper right", frameon=False, fontsize=5.4, handlelength=0.85, handleheight=0.85)
    ax_bar.spines["top"].set_visible(False)
    ax_bar.spines["right"].set_visible(False)
    ax_bar.spines["left"].set_linewidth(0.65)
    ax_bar.spines["bottom"].set_linewidth(0.65)


def main():
    parser = argparse.ArgumentParser(description="Render Supp Figure S6 Panel A (proliferation proxy).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("sfig06_a.png"))
    args = parser.parse_args()

    df_s6a = pd.read_csv(args.paper_root / "runs" / "step02_umap_gradients" / "figs6a_proliferation_markers_by_stage_proxy.csv")
    fig = plt.figure(figsize=(3.50, 2.30), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.06, right=0.96, top=0.88, bottom=0.18)
    draw_panel_s6a(fig, gs[0, 0], df_s6a)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[sfig06_a] Saved -> {args.out}")


if __name__ == "__main__":
    main()
