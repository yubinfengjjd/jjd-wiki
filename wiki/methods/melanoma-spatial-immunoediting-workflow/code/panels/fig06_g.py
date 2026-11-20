#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: fig06/G
Title: IM vs EM EMT-related 8-gene Z-score heatmap (S100A4..CSTB)
Input tables:
  - runs/step06_mrseq_deseq2/fig6g_emt_zscore_im_em.csv
  - data_small/mrseq_meta_small.csv
Default size: 4.30 in x 1.85 in (300 dpi)
CLI usage:
  python fig06_g.py --paper-root <sources_root>/papers/pmc9167783 --out fig06_g.png
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


def draw_panel_6g(fig, gs_slot, z_df: pd.DataFrame, meta_df: pd.DataFrame):
    """Draw Panel 6G (IM vs EM 8-gene Z-score heatmap + top annotation strip + Z score colorbar) inside gs_slot."""
    gene_order = ["S100A4", "VIM", "CTNNB1", "DMKN", "MMP2", "FXYD3", "PYROXD2", "CSTB"]
    avail_genes = [g for g in gene_order if g in z_df.index]

    sub_meta = meta_df[meta_df["sample_id"].isin(z_df.columns)].copy()
    sub_meta["site_ord"] = pd.Categorical(sub_meta["site"], categories=["IM", "EM"], ordered=True)
    sub_meta = sub_meta.sort_values(["site_ord", "sample_id"])
    samples_ord = sub_meta["sample_id"].tolist()
    sites_ord = sub_meta["site"].tolist()

    mat = z_df.loc[avail_genes, samples_ord].to_numpy(dtype=float)

    cmap_6g = LinearSegmentedColormap.from_list(
        "fig6g_z", ["#2D5B8E", "#8FC2BD", "#F7F1BE", "#E6794F", "#B62238"]
    )

    sub_gs = GridSpecFromSubplotSpec(
        2, 2,
        subplot_spec=gs_slot,
        height_ratios=[0.18, 1.0],
        width_ratios=[1.0, 0.24],
        hspace=0.05,
        wspace=0.05,
    )

    ax_top = fig.add_subplot(sub_gs[0, 0])
    ax_heat = fig.add_subplot(sub_gs[1, 0])
    ax_cb = fig.add_subplot(sub_gs[1, 1])

    ax_top.text(-0.10, 2.30, "G", transform=ax_top.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")

    n_s = len(samples_ord)
    ax_top.set_xlim(0, n_s)
    ax_top.set_ylim(0, 1)
    for i, st in enumerate(sites_ord):
        col = "#C49B4E" if st == "IM" else "#4D4D4D"
        ax_top.add_patch(mpatches.Rectangle((i, 0), 1.0, 1.0, facecolor=col, edgecolor="none"))
    im_idxs = [i for i, s in enumerate(sites_ord) if s == "IM"]
    em_idxs = [i for i, s in enumerate(sites_ord) if s == "EM"]
    if im_idxs:
        ax_top.text(0.5 * (min(im_idxs) + max(im_idxs) + 1), 1.25, "IM", ha="center", va="bottom", fontsize=7.0, color="#222222")
    if em_idxs:
        ax_top.text(0.5 * (min(em_idxs) + max(em_idxs) + 1), 1.25, "EM", ha="center", va="bottom", fontsize=7.0, color="#222222")
    ax_top.text(n_s + 0.6, 0.45, "P < 0.05", ha="left", va="center", fontsize=6.2, color="#222222", clip_on=False)
    ax_top.set_xticks([])
    ax_top.set_yticks([])
    for sp in ax_top.spines.values():
        sp.set_visible(False)

    n_g = len(avail_genes)
    norm_6g = Normalize(vmin=-2.0, vmax=2.0)
    ax_heat.set_xlim(0, n_s)
    ax_heat.set_ylim(n_g, 0)
    for r_i in range(n_g):
        for c_i in range(n_s):
            val = np.clip(mat[r_i, c_i], -2.0, 2.0)
            ax_heat.add_patch(mpatches.Rectangle(
                (c_i, r_i), 1.0, 1.0,
                facecolor=cmap_6g(norm_6g(val)),
                edgecolor="#444444", linewidth=0.30,
            ))
    ax_heat.set_xticks([])
    ax_heat.set_yticks(np.arange(n_g) + 0.5)
    ax_heat.set_yticklabels(avail_genes, fontsize=6.0, style="italic")
    ax_heat.yaxis.tick_right()
    ax_heat.tick_params(axis="y", length=0, pad=3)
    for sp in ax_heat.spines.values():
        sp.set_linewidth(0.6)
        sp.set_color("#333333")

    # Right colorbar aligned with top half of 6G heatmap (next to S100A4..MMP2)
    cb_pos = ax_cb.get_position()
    ax_cb.axis("off")
    cb_ax = fig.add_axes([cb_pos.x0 + cb_pos.width * 0.58, cb_pos.y0 + cb_pos.height * 0.38, 0.011, cb_pos.height * 0.58])
    sm = plt.cm.ScalarMappable(cmap=cmap_6g, norm=norm_6g)
    cb = fig.colorbar(sm, cax=cb_ax)
    cb.set_ticks([-2, -1, 0, 1, 2])
    cb.ax.tick_params(labelsize=5.5, length=2, pad=1.5)
    cb.outline.set_linewidth(0.4)
    cb_ax.set_ylabel("Z score", fontsize=6.2, labelpad=2)
    cb_ax.yaxis.set_label_position("left")


def main():
    parser = argparse.ArgumentParser(description="Render Main Figure 6 Panel G (IM vs EM heatmap).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("fig06_g.png"))
    args = parser.parse_args()

    z_df = pd.read_csv(args.paper_root / "runs" / "step06_mrseq_deseq2" / "fig6g_emt_zscore_im_em.csv", index_col=0)
    meta_df = pd.read_csv(args.paper_root / "data_small" / "mrseq_meta_small.csv")

    fig = plt.figure(figsize=(4.40, 1.95), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.06, right=0.92, top=0.82, bottom=0.05)
    draw_panel_6g(fig, gs[0, 0], z_df, meta_df)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[fig06_g] Saved -> {args.out}")


if __name__ == "__main__":
    main()
