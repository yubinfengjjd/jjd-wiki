#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: sfig07/C
Title: 4-pathway JAK-STAT ssGSEA score heatmap across bTIL, IB, IM mROIs
Input tables:
  - runs/step06_mrseq_deseq2/figs7c_jakstat_ssgsea_scores_proxy.csv
  - data_small/mrseq_meta_small.csv
Default size: 3.30 in x 2.00 in (300 dpi)
CLI usage:
  python sfig07_c.py --paper-root <sources_root>/papers/pmc9167783 --out sfig07_c.png
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


def draw_panel_s7c(fig, gs_slot, ss_df: pd.DataFrame, meta_df: pd.DataFrame):
    """Draw Panel S7C (4-pathway JAK-STAT ssGSEA heatmap) inside gs_slot."""
    sub_meta = meta_df[meta_df["site"].isin(["bTIL", "IB", "IM"]) & meta_df["sample_id"].isin(ss_df.columns)].copy()
    sub_meta["site_cat"] = pd.Categorical(sub_meta["site"], categories=["bTIL", "IB", "IM"], ordered=True)
    sub_meta = sub_meta.sort_values(["site_cat", "sample_id"])
    s_ord = sub_meta["sample_id"].tolist()
    sites_ord = sub_meta["site"].tolist()

    mat_raw = ss_df[s_ord].to_numpy(dtype=float)
    mu = mat_raw.mean(axis=1, keepdims=True)
    sd = np.where(mat_raw.std(axis=1, keepdims=True) > 1e-8, mat_raw.std(axis=1, keepdims=True), 1.0)
    mat_z = np.clip((mat_raw - mu) / sd, -1.0, 1.0)

    cmap_c = LinearSegmentedColormap.from_list("s7c_ss", ["#F7EEBC", "#EB8A5B", "#A32248"])
    norm_c = Normalize(vmin=-1.0, vmax=1.0)

    sub_gs = GridSpecFromSubplotSpec(
        5, 3, subplot_spec=gs_slot,
        height_ratios=[0.22, 1, 1, 1, 1],
        width_ratios=[0.22, 2.2, 0.95],
        hspace=0.14, wspace=0.05,
    )
    ax_cb = fig.add_subplot(sub_gs[1:5, 0])
    ax_top = fig.add_subplot(sub_gs[0, 1])

    ax_cb.text(-0.65, 1.18, "C", transform=ax_cb.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    cb_pos = ax_cb.get_position()
    ax_cb.axis("off")
    cb_ax = fig.add_axes([cb_pos.x0 + 0.005, cb_pos.y0 + cb_pos.height * 0.25, 0.009, cb_pos.height * 0.55])
    sm = plt.cm.ScalarMappable(cmap=cmap_c, norm=norm_c)
    cb = fig.colorbar(sm, cax=cb_ax)
    cb.set_ticks([-1, 0, 1])
    cb.ax.tick_params(labelsize=4.8, length=1.5, pad=1)
    cb.outline.set_linewidth(0.4)
    cb_ax.set_ylabel("ssGSEA score", fontsize=5.2, labelpad=2)
    cb_ax.yaxis.set_label_position("left")

    site_cols = {"bTIL": "#1E9C78", "IB": "#A5694F", "IM": "#6E6E6E"}
    ax_top.set_xlim(0, len(s_ord))
    ax_top.set_ylim(0, 1)
    for i, st in enumerate(sites_ord):
        ax_top.add_patch(mpatches.Rectangle((i, 0), 1.0, 1.0, facecolor=site_cols[st], edgecolor="none"))
    ax_top.axis("off")

    pretty_rows = {
        "KEGG_JAK_STAT": "KEGG JAK STAT",
        "JAK_STAT_CASCADE": "JAK STAT CASCADE",
        "GO_RECEPTOR_SIGNALING_VIA_STAT": "GO RECEPTOR\nSIG VIA STAT",
        "IL6_JAK_STAT3_SIGNALING": "IL6 JAK STAT3\nSIGNALING",
    }
    for ri, rname in enumerate(ss_df.index):
        ax_r = fig.add_subplot(sub_gs[1 + ri, 1])
        ax_r.imshow(mat_z[ri:ri + 1, :], aspect="auto", cmap=cmap_c, norm=norm_c, interpolation="nearest")
        ax_r.set_xticks([])
        ax_r.set_yticks([])
        ax_l = fig.add_subplot(sub_gs[1 + ri, 2])
        ax_l.axis("off")
        ax_l.text(0.02, 0.5, pretty_rows.get(rname, rname), fontsize=5.0, va="center", ha="left")
        for sp in ax_r.spines.values():
            sp.set_linewidth(0.45)

    # Top-right stage legend
    ax_leg = fig.add_subplot(sub_gs[0, 2])
    ax_leg.axis("off")
    handles = [mpatches.Patch(facecolor=site_cols[s], label=s) for s in ["bTIL", "IB", "IM"]]
    ax_leg.legend(handles=handles, loc="center left", ncol=3, frameon=False, fontsize=4.8, handlelength=0.7, columnspacing=0.4, borderpad=0.0)


def main():
    parser = argparse.ArgumentParser(description="Render Supp Figure S7 Panel C (JAK-STAT ssGSEA).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("sfig07_c.png"))
    args = parser.parse_args()

    ss_df = pd.read_csv(args.paper_root / "runs" / "step06_mrseq_deseq2" / "figs7c_jakstat_ssgsea_scores_proxy.csv", index_col=0)
    meta_df = pd.read_csv(args.paper_root / "data_small" / "mrseq_meta_small.csv")

    fig = plt.figure(figsize=(3.40, 2.10), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.10, right=0.97, top=0.88, bottom=0.08)
    draw_panel_s7c(fig, gs[0, 0], ss_df, meta_df)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[sfig07_c] Saved -> {args.out}")


if __name__ == "__main__":
    main()
