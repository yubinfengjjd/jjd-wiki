#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: sfig07/H
Title: CXCL12 & CXCR4 Z-score heatmap across all 120 mROIs (PickSeq proxy)
Input tables:
  - runs/step06_mrseq_deseq2/figs7h_cxcl12_cxcr4_zscore_proxy.csv
  - data_small/mrseq_meta_small.csv
Default size: 3.40 in x 1.30 in (300 dpi)
CLI usage:
  python sfig07_h.py --paper-root <sources_root>/papers/pmc9167783 --out sfig07_h.png
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

SITE_ORDER_6 = ["MIS", "IR", "bTIL", "IB", "IM", "EM"]
SITE_COLORS_6 = {"MIS": "#1E9C78", "IR": "#B86646", "bTIL": "#C84B93", "IB": "#85A933", "IM": "#C69032", "EM": "#666666"}


def draw_panel_s7h(fig, gs_slot, z_df: pd.DataFrame, meta_df: pd.DataFrame):
    """Draw Panel S7H (CXCL12/CXCR4 Z-score heatmap + top 6-site bar + Z-score colorbar) inside gs_slot."""
    sub_meta = meta_df[meta_df["sample_id"].isin(z_df.columns)].copy()
    sub_meta["site_cat"] = pd.Categorical(sub_meta["site"], categories=SITE_ORDER_6, ordered=True)
    sub_meta = sub_meta.sort_values(["site_cat", "sample_id"])
    s_ord = sub_meta["sample_id"].tolist()
    sites_ord = sub_meta["site"].tolist()

    mat = np.clip(z_df.loc[["CXCL12", "CXCR4"], s_ord].to_numpy(dtype=float), -1.5, 1.5)
    cmap_h = LinearSegmentedColormap.from_list("s7h_z", ["#3D7889", "#8FC2BD", "#F5EEBE", "#E68358", "#BC2C3B"])
    norm_h = Normalize(vmin=-1.5, vmax=1.5)

    sub_gs = GridSpecFromSubplotSpec(2, 2, subplot_spec=gs_slot, height_ratios=[0.22, 1.0], width_ratios=[1.0, 0.16], hspace=0.06, wspace=0.04)
    ax_top = fig.add_subplot(sub_gs[0, 0])
    ax_hm = fig.add_subplot(sub_gs[1, 0])
    ax_cb = fig.add_subplot(sub_gs[1, 1])

    ax_top.text(-0.22, 1.90, "H", transform=ax_top.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    ax_top.set_xlim(0, len(s_ord))
    ax_top.set_ylim(0, 1)
    for i, st in enumerate(sites_ord):
        ax_top.add_patch(mpatches.Rectangle((i, 0), 1.0, 1.0, facecolor=SITE_COLORS_6[st], edgecolor="none"))
    for st in SITE_ORDER_6:
        idxs = [i for i, s in enumerate(sites_ord) if s == st]
        if idxs:
            ax_top.text(0.5 * (min(idxs) + max(idxs) + 1), 1.20, st, ha="center", va="bottom", fontsize=5.2, color="#222222")
    ax_top.axis("off")

    ax_hm.imshow(mat, aspect="auto", cmap=cmap_h, norm=norm_h, interpolation="nearest")
    ax_hm.set_yticks([0, 1])
    ax_hm.set_yticklabels(["CXCL12", "CXCR4"], fontsize=5.8)
    ax_hm.tick_params(axis="y", length=0, pad=2)
    ax_hm.set_xticks([])
    ax_hm.set_xlabel("Expression in each mROI (proxy)", fontsize=5.8, labelpad=3)
    for sp in ax_hm.spines.values():
        sp.set_linewidth(0.55)

    cb_pos = ax_cb.get_position()
    ax_cb.axis("off")
    cb_ax = fig.add_axes([cb_pos.x0 + 0.008, cb_pos.y0 + 0.005, 0.009, cb_pos.height * 0.90])
    sm = plt.cm.ScalarMappable(cmap=cmap_h, norm=norm_h)
    cb = fig.colorbar(sm, cax=cb_ax)
    cb.set_ticks([-1.5, 0, 1.5])
    cb.set_ticklabels(["-1.5", "0", "1.5"])
    cb.ax.tick_params(labelsize=4.6, length=1.4, pad=1)
    cb.outline.set_linewidth(0.4)
    cb_ax.set_title("z score", fontsize=5.0, pad=2)


def main():
    parser = argparse.ArgumentParser(description="Render Supp Figure S7 Panel H (CXCL12/CXCR4).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("sfig07_h.png"))
    args = parser.parse_args()

    z_df = pd.read_csv(args.paper_root / "runs" / "step06_mrseq_deseq2" / "figs7h_cxcl12_cxcr4_zscore_proxy.csv", index_col=0)
    meta_df = pd.read_csv(args.paper_root / "data_small" / "mrseq_meta_small.csv")

    fig = plt.figure(figsize=(3.50, 1.40), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.18, right=0.94, top=0.72, bottom=0.22)
    draw_panel_s7h(fig, gs[0, 0], z_df, meta_df)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[sfig07_h] Saved -> {args.out}")


if __name__ == "__main__":
    main()
