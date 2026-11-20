#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: fig07/H
Title: Immune checkpoint & cytotoxicity 9-gene Z-score heatmap + right significance matrix (Up P < 0.05 vs EM)
Input tables:
  - runs/step06_mrseq_deseq2/fig7h_checkpoints_zscore_proxy.csv
  - runs/step06_mrseq_deseq2/fig7h_up_vs_em_sig_proxy.csv
  - data_small/mrseq_meta_small.csv
Default size: 3.10 in x 2.20 in (300 dpi)
CLI usage:
  python fig07_h.py --paper-root <sources_root>/papers/pmc9167783 --out fig07_h.png
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


def draw_panel_7h(fig, gs_slot, z_df: pd.DataFrame, sig_df: pd.DataFrame, meta_df: pd.DataFrame):
    """Draw Panel 7H (9-gene checkpoint Z-score heatmap + binary Up P<0.05 matrix + legends) inside gs_slot."""
    gene_order = ["CTLA4", "PDCD1", "GNLY", "HAVCR2", "TIGIT", "LAG3", "PRF1", "GZMB", "GZMA"]
    genes = [g for g in gene_order if g in z_df.index]

    sub_meta = meta_df[meta_df["sample_id"].isin(z_df.columns)].copy()
    sub_meta["site_cat"] = pd.Categorical(sub_meta["site"], categories=SITE_ORDER_6, ordered=True)
    sub_meta = sub_meta.sort_values(["site_cat", "sample_id"])
    samples_ord = sub_meta["sample_id"].tolist()
    sites_ord = sub_meta["site"].tolist()

    mat_raw = z_df.loc[genes, samples_ord].to_numpy(dtype=float)
    # Use robust percentile scaling per gene within [-1.5, 1.5] for smooth continuous heatmap contrast
    mat = np.zeros_like(mat_raw)
    for r_i in range(mat_raw.shape[0]):
        row_v = mat_raw[r_i]
        lo, hi = np.percentile(row_v, [5, 95])
        if hi - lo > 1e-6:
            scaled = (row_v - np.median(row_v)) / ((hi - lo) * 0.42)
        else:
            scaled = row_v
        mat[r_i] = np.clip(scaled, -1.5, 1.5)

    cmap_7h = LinearSegmentedColormap.from_list(
        "fig7h_z", ["#3D7889", "#8FC2BD", "#F5EEBE", "#E68358", "#BC2C3B"]
    )
    norm_7h = Normalize(vmin=-1.5, vmax=1.5)

    sub_gs = GridSpecFromSubplotSpec(
        3, 2,
        subplot_spec=gs_slot,
        height_ratios=[0.22, 1.45, 0.35],
        width_ratios=[3.2, 0.85],
        hspace=0.06,
        wspace=0.04,
    )

    ax_top = fig.add_subplot(sub_gs[0, 0])
    ax_sig_hdr = fig.add_subplot(sub_gs[0, 1])
    ax_heat = fig.add_subplot(sub_gs[1, 0])
    ax_sig = fig.add_subplot(sub_gs[1, 1])
    ax_cb = fig.add_subplot(sub_gs[2, 0])
    ax_sleg = fig.add_subplot(sub_gs[2, 1])

    ax_top.text(-0.22, 1.90, "H", transform=ax_top.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")

    # Top 6-site strip
    n_s = len(samples_ord)
    ax_top.set_xlim(0, n_s)
    ax_top.set_ylim(0, 1)
    for i, st in enumerate(sites_ord):
        ax_top.add_patch(mpatches.Rectangle((i, 0), 1.0, 1.0, facecolor=SITE_COLORS_6[st], edgecolor="none"))
    for st in SITE_ORDER_6:
        idxs = [i for i, s in enumerate(sites_ord) if s == st]
        if idxs:
            mid = 0.5 * (min(idxs) + max(idxs) + 1)
            ax_top.text(mid, 1.25, st, ha="center", va="bottom", fontsize=5.2, color=SITE_COLORS_6[st], fontweight="bold")
    ax_top.axis("off")

    # Main heatmap
    ax_heat.imshow(mat, aspect="auto", cmap=cmap_7h, norm=norm_7h, interpolation="nearest")
    ax_heat.set_yticks(np.arange(len(genes)))
    ax_heat.set_yticklabels(genes, fontsize=5.6)
    ax_heat.tick_params(axis="y", length=0, pad=2)
    ax_heat.set_xticks([])
    for sp in ax_heat.spines.values():
        sp.set_linewidth(0.55)
        sp.set_color("#333333")

    # Right binary significance matrix (5 sites vs EM)
    sig_sites = ["MIS", "IR", "bTIL", "IB", "IM"]
    ax_sig_hdr.set_xlim(0, len(sig_sites))
    ax_sig_hdr.set_ylim(0, 1)
    for c_i, s_name in enumerate(sig_sites):
        ax_sig_hdr.text(c_i + 0.5, 0.1, s_name, rotation=90, ha="center", va="bottom", fontsize=5.0)
    ax_sig_hdr.axis("off")

    ax_sig.set_xlim(0, len(sig_sites))
    ax_sig.set_ylim(len(genes), 0)
    for r_i, g in enumerate(genes):
        for c_i, s_name in enumerate(sig_sites):
            row_s = sig_df[(sig_df["gene"] == g) & (sig_df["site"] == s_name)]
            is_sig = (not row_s.empty) and int(row_s["up_sig_p05"].iloc[0]) == 1
            fc = "#DF2B26" if is_sig else "#D8D8D8"
            ax_sig.add_patch(mpatches.Rectangle((c_i, r_i), 1.0, 1.0, facecolor=fc, edgecolor="#333333", lw=0.45))
    ax_sig.set_xticks([])
    ax_sig.set_yticks([])

    # Bottom Z-score horizontal colorbar + significance legend
    cb_pos = ax_cb.get_position()
    ax_cb.axis("off")
    cb_ax = fig.add_axes([cb_pos.x0 + cb_pos.width * 0.12, cb_pos.y0 + cb_pos.height * 0.42, cb_pos.width * 0.68, 0.011])
    sm = plt.cm.ScalarMappable(cmap=cmap_7h.reversed(), norm=norm_7h)
    cb = fig.colorbar(sm, cax=cb_ax, orientation="horizontal")
    cb.set_ticks([-1.5, -0.75, 0, 0.75, 1.5])
    cb.set_ticklabels(["1.5", "", "0", "", "−1.5"])
    cb.ax.tick_params(labelsize=4.8, length=1.6, pad=1)
    cb.outline.set_linewidth(0.4)
    cb_ax.set_xlabel("Z score", fontsize=5.2, style="italic", labelpad=1.5)

    ax_sleg.axis("off")
    handles_s = [
        mpatches.Patch(facecolor="#DF2B26", label="Up P < 0.05"),
        mpatches.Patch(facecolor="#D8D8D8", label="NS"),
    ]
    ax_sleg.legend(handles=handles_s, loc="center left", frameon=False, fontsize=5.0, handlelength=0.8, handleheight=0.8, labelspacing=0.2)


def main():
    parser = argparse.ArgumentParser(description="Render Main Figure 7 Panel H (checkpoints Z-score + sig).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("fig07_h.png"))
    args = parser.parse_args()

    z_df = pd.read_csv(args.paper_root / "runs" / "step06_mrseq_deseq2" / "fig7h_checkpoints_zscore_proxy.csv", index_col=0)
    sig_df = pd.read_csv(args.paper_root / "runs" / "step06_mrseq_deseq2" / "fig7h_up_vs_em_sig_proxy.csv")
    meta_df = pd.read_csv(args.paper_root / "data_small" / "mrseq_meta_small.csv")

    fig = plt.figure(figsize=(3.20, 2.30), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.16, right=0.96, top=0.84, bottom=0.08)
    draw_panel_7h(fig, gs[0, 0], z_df, sig_df, meta_df)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[fig07_h] Saved -> {args.out}")


if __name__ == "__main__":
    main()
