#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: fig06/C
Title: 4-block ssGSEA pathway score heatmap (IFN, Tumor, Immune, Skin) across 6 sites
Input tables:
  - runs/step06_mrseq_deseq2/fig6c_ssgsea_scores.csv
  - data_small/mrseq_meta_small.csv
Default size: 3.10 in x 2.20 in (300 dpi)
CLI usage:
  python fig06_c.py --paper-root <sources_root>/papers/pmc9167783 --out fig06_c.png
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
SITE_COLORS_6 = {
    "MIS": "#1E9C78",
    "IR": "#B86646",
    "bTIL": "#C84B93",
    "IB": "#85A933",
    "IM": "#C69032",
    "EM": "#666666",
}


def draw_panel_6c(fig, gs_slot, ss_df: pd.DataFrame, meta_df: pd.DataFrame):
    """Draw Panel 6C (4-block ssGSEA heatmap + top 6-stage strip + horizontal Score colorbar) inside gs_slot."""
    # Order samples by site order MIS -> IR -> bTIL -> IB -> IM -> EM
    meta_sub = meta_df[meta_df["sample_id"].isin(ss_df.columns)].copy()
    meta_sub["site_cat"] = pd.Categorical(meta_sub["site"], categories=SITE_ORDER_6, ordered=True)
    meta_sub = meta_sub.sort_values(["site_cat", "sample_id"])
    ordered_samples = meta_sub["sample_id"].tolist()
    ordered_sites = meta_sub["site"].tolist()

    # Row-normalize ssGSEA scores to [-1, 1] z-clipped for crisp visual contrast matching Score (-1..1)
    mat_raw = ss_df[ordered_samples].to_numpy(dtype=float)
    row_mean = mat_raw.mean(axis=1, keepdims=True)
    row_std = np.where(mat_raw.std(axis=1, keepdims=True) > 1e-8, mat_raw.std(axis=1, keepdims=True), 1.0)
    mat_norm = np.clip((mat_raw - row_mean) / (2.0 * row_std), -1.0, 1.0)
    row_names = ss_df.index.tolist()

    row_blocks = [
        ("IFN", ["SHIH_IFN", "IMSIG_IFN"], ["SHIH_IFN", "IMSIG_IFN"]),
        ("Tumor", ["Melanocytes", "Melanoma"], ["Melanocytes", "Melanoma"]),
        ("Immune", ["T_cells", "Macrophages", "B_cells"], ["T cells", "Macrophages", "B cells"]),
        ("Skin", ["Keratinocyte"], ["Keratinocyte"]),
    ]

    cmap_6c = LinearSegmentedColormap.from_list(
        "fig6c_score",
        ["#F8F1C3", "#F3C37A", "#E3704D", "#AC2A55", "#54184E"],
    )

    # Top row: colorbar & stage labels | Stage strip | 4 heatmap blocks
    # Reserve right column (26% width) inside gs_slot so right-side row labels never clip!
    sub_gs = GridSpecFromSubplotSpec(
        6, 2,
        subplot_spec=gs_slot,
        height_ratios=[0.65, 0.25, 0.85, 0.85, 1.25, 0.48],
        width_ratios=[1.0, 0.36],
        hspace=0.14,
        wspace=0.02,
    )

    # Top colorbar slot (above heatmap + right label space)
    ax_top = fig.add_subplot(sub_gs[0, :])
    ax_top.axis("off")
    ax_top.text(-0.08, 1.22, "C", transform=ax_top.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    top_pos = ax_top.get_position()
    cb_ax = fig.add_axes([top_pos.x0 + top_pos.width * 0.56, top_pos.y0 + top_pos.height * 0.62, top_pos.width * 0.28, 0.011])
    sm = plt.cm.ScalarMappable(cmap=cmap_6c, norm=Normalize(vmin=-1.0, vmax=1.0))
    cb = fig.colorbar(sm, cax=cb_ax, orientation="horizontal")
    cb.set_ticks([-1, -0.5, 0, 0.5, 1])
    cb.set_ticklabels(["1", "0.5", "0", "-0.5", "-1"])
    cb.ax.xaxis.set_ticks_position("top")
    cb.ax.tick_params(labelsize=4.8, length=1.6, pad=1)
    cb.outline.set_linewidth(0.4)
    cb_ax.text(-0.08, 0.5, "Score", transform=cb_ax.transAxes, fontsize=5.6, va="center", ha="right")

    # Top stage annotation bar
    ax_st = fig.add_subplot(sub_gs[1, 0])
    n_s = len(ordered_samples)
    ax_st.set_xlim(0, n_s)
    ax_st.set_ylim(0, 1)
    for i, st in enumerate(ordered_sites):
        ax_st.add_patch(mpatches.Rectangle((i, 0), 1.0, 1.0, facecolor=SITE_COLORS_6[st], edgecolor="none"))
    # Site labels above strip
    for st in SITE_ORDER_6:
        idxs = [i for i, s in enumerate(ordered_sites) if s == st]
        if idxs:
            mid = 0.5 * (min(idxs) + max(idxs) + 1)
            ax_st.text(mid, 1.15, st, ha="center", va="bottom", fontsize=5.3, color=SITE_COLORS_6[st], fontweight="bold")
    ax_st.set_xticks([])
    ax_st.set_yticks([])
    for sp in ax_st.spines.values():
        sp.set_visible(False)

    # 4 heatmap blocks
    norm_6c = Normalize(vmin=-1.0, vmax=1.0)
    for b_idx, (blk_lbl, keys, pretty_keys) in enumerate(row_blocks):
        ax_b = fig.add_subplot(sub_gs[2 + b_idx, 0])
        r_indices = [row_names.index(k) for k in keys if k in row_names]
        sub_mat = mat_norm[r_indices, :]
        ax_b.imshow(sub_mat, aspect="auto", cmap=cmap_6c, norm=norm_6c, interpolation="nearest")
        ax_b.set_ylabel(blk_lbl, fontsize=6.2, labelpad=3)
        ax_b.set_yticks(np.arange(len(r_indices)))
        ax_b.set_yticklabels([pretty_keys[i] for i in range(len(r_indices))], fontsize=5.5)
        ax_b.yaxis.tick_right()
        ax_b.tick_params(axis="y", length=0, pad=2)
        ax_b.set_xticks([])
        for sp in ax_b.spines.values():
            sp.set_linewidth(0.5)
            sp.set_color("#444444")


def main():
    parser = argparse.ArgumentParser(description="Render Main Figure 6 Panel C (ssGSEA heatmap).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("fig06_c.png"))
    args = parser.parse_args()

    ss_df = pd.read_csv(args.paper_root / "runs" / "step06_mrseq_deseq2" / "fig6c_ssgsea_scores.csv", index_col=0)
    meta_df = pd.read_csv(args.paper_root / "data_small" / "mrseq_meta_small.csv")

    fig = plt.figure(figsize=(3.40, 2.30), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.10, right=0.76, top=0.88, bottom=0.05)
    draw_panel_6c(fig, gs[0, 0], ss_df, meta_df)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[fig06_c] Saved -> {args.out}")


if __name__ == "__main__":
    main()
