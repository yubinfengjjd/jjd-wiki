#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: sfig05/A
Title: Tumor cell PCA variance ratio scree plot + PC1/PC2 ranked feature loadings
Input tables:
  - runs/step02_umap_gradients/figs5a_tumor_pca_scree.csv
  - runs/step02_umap_gradients/figs5a_tumor_pca_loadings.csv
Default size: 4.10 in x 2.30 in (300 dpi)
CLI usage:
  python sfig05_a.py --paper-root <sources_root>/papers/pmc9167783 --out sfig05_a.png
"""

import argparse
from pathlib import Path
import sys

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpecFromSubplotSpec
import numpy as np
import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _fig_common import DEFAULT_PAPER_ROOT

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["pdf.fonttype"] = 42


def draw_panel_s5a(fig, gs_slot, scree_df: pd.DataFrame, load_df: pd.DataFrame):
    """Draw Panel S5A (Variance ratio scree + PC1/PC2 ranked feature loadings) inside gs_slot."""
    sub_gs = GridSpecFromSubplotSpec(2, 2, subplot_spec=gs_slot, width_ratios=[1.05, 1.15], hspace=0.14, wspace=0.28)
    ax_sc = fig.add_subplot(sub_gs[:, 0])
    ax_p1 = fig.add_subplot(sub_gs[0, 1])
    ax_p2 = fig.add_subplot(sub_gs[1, 1])

    ax_sc.text(-0.22, 1.08, "A", transform=ax_sc.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")

    # Left: Variance ratio scree
    x = scree_df["pc_num"].to_numpy()
    y = scree_df["explained_variance_ratio"].to_numpy()
    ax_sc.plot(x, y, marker="s", markersize=3.2, markerfacecolor="white", markeredgecolor="#333333",
               color="#333333", linewidth=0.75)
    for xi, yi, pc in zip(x[:10], y[:10], scree_df["PC"].iloc[:10]):
        ax_sc.text(xi, yi + 0.012, pc, rotation=90, fontsize=4.8, ha="center", va="bottom", color="#222222")
    ax_sc.text(0.95, 0.94, "Variance ratio", transform=ax_sc.transAxes, ha="right", va="top", fontsize=6.6)
    ax_sc.set_xlabel("ranking by PC", fontsize=6.2, labelpad=2)
    ax_sc.set_ylim(0, max(y.max() * 1.22, 0.25))
    ax_sc.tick_params(labelsize=5.4, length=2.2, pad=1.5)
    for sp in ax_sc.spines.values():
        sp.set_linewidth(0.7)

    # Right: PC1 & PC2 ranked loadings
    for ax_p, col_name, lbl in [(ax_p1, "abs_PC1", "PC1"), (ax_p2, "abs_PC2", "PC2")]:
        sub = load_df.sort_values(col_name, ascending=False).reset_index(drop=True)
        n_m = len(sub)
        xs = np.arange(n_m)
        ys = sub[col_name].to_numpy()
        ax_p.scatter(xs, ys, s=4.0, color="#666666", zorder=2)
        for i in range(min(18, n_m)):
            col_t = "#C62828" if i < 2 else "#333333"
            ax_p.text(i, ys[i] + 0.015, str(sub.loc[i, "marker"]), rotation=90, fontsize=3.8, ha="center", va="bottom", color=col_t)
        ax_p.text(0.95, 0.92, lbl, transform=ax_p.transAxes, ha="right", va="top", fontsize=6.6)
        ax_p.set_ylim(-0.02, ys.max() * 1.48)
        ax_p.set_xticks([])
        ax_p.tick_params(axis="y", labelsize=5.2, length=2.0, pad=1.5)
        for sp in ax_p.spines.values():
            sp.set_linewidth(0.65)
    ax_p2.set_xlabel("ranking by feature", fontsize=6.2, labelpad=2)
    return [ax_sc, ax_p1, ax_p2]


def main():
    parser = argparse.ArgumentParser(description="Render Supp Figure S5 Panel A (tumor PCA).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("sfig05_a.png"))
    args = parser.parse_args()

    scree_df = pd.read_csv(args.paper_root / "runs" / "step02_umap_gradients" / "figs5a_tumor_pca_scree.csv")
    load_df = pd.read_csv(args.paper_root / "runs" / "step02_umap_gradients" / "figs5a_tumor_pca_loadings.csv")

    fig = plt.figure(figsize=(4.20, 2.30), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.10, right=0.97, top=0.90, bottom=0.16)
    draw_panel_s5a(fig, gs[0, 0], scree_df, load_df)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[sfig05_a] Saved -> {args.out}")


if __name__ == "__main__":
    main()
