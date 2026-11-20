#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: fig06/D
Title: DESeq2 volcano plot (MIS vs EM/IM differential expression)
Input tables: runs/step06_mrseq_deseq2/deseq2_mis_vs_emim_symbol.csv
Default size: 2.60 in x 2.00 in (300 dpi)
CLI usage:
  python fig06_d.py --paper-root <sources_root>/papers/pmc9167783 --out fig06_d.png
"""

import argparse
from pathlib import Path
import sys

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _fig_common import DEFAULT_PAPER_ROOT

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["pdf.fonttype"] = 42


def draw_panel_6d(fig, gs_slot, deg_df: pd.DataFrame):
    """Draw Panel 6D (DESeq2 volcano plot) inside gs_slot."""
    ax = fig.add_subplot(gs_slot)
    ax.text(-0.26, 1.13, "D", transform=ax.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")

    df = deg_df.dropna(subset=["log2FoldChange", "padj"]).copy()
    p_clipped = np.clip(df["padj"].to_numpy(dtype=float), 1e-120, 1.0)
    df["neg_log10_padj"] = -np.log10(p_clipped)
    lfc = df["log2FoldChange"].to_numpy(dtype=float)
    yval = df["neg_log10_padj"].to_numpy(dtype=float)

    sig_mask = (np.abs(lfc) >= 2.0) & (df["padj"].to_numpy() < 0.05)
    ax.scatter(lfc[~sig_mask], yval[~sig_mask], s=4.5, color="#BDBDBD", alpha=0.55, edgecolors="none", rasterized=True, zorder=2)
    ax.scatter(lfc[sig_mask], yval[sig_mask], s=6.5, color="#9E623E", alpha=0.82, edgecolors="none", rasterized=True, zorder=3)

    ax.axhline(-np.log10(0.05), color="#777777", linestyle="--", linewidth=0.75, zorder=1)
    ax.axvline(-2.0, color="#777777", linestyle="--", linewidth=0.75, zorder=1)
    ax.axvline(2.0, color="#777777", linestyle="--", linewidth=0.75, zorder=1)

    # Non-overlapping curated top labels from both sides
    top_pos = df[(df["log2FoldChange"] > 5) & (df["padj"] < 1e-20)].sort_values("neg_log10_padj", ascending=False).head(6)
    top_neg = df[(df["log2FoldChange"] < -5) & (df["padj"] < 1e-20)].sort_values("neg_log10_padj", ascending=False).head(5)
    to_label = pd.concat([top_pos, top_neg], ignore_index=True)

    placed = []
    for _, row in to_label.iterrows():
        gx, gy = float(row["log2FoldChange"]), float(row["neg_log10_padj"])
        # Place labels inward/sideways cleanly without touching plot border
        tx = gx + (1.8 if gx < 0 else -1.8)
        ty = gy
        for px, py in placed:
            if abs(tx - px) < 11.0 and abs(ty - py) < 8.5:
                ty = py - 8.5 if ty > 25 else py + 8.5
        placed.append((tx, ty))
        ha = "left" if gx < 0 else "right"
        ax.text(tx, ty, str(row["gene_symbol"]), fontsize=5.2, style="italic", color="#111111", ha=ha, va="center", zorder=5)

    ax.set_xlim(lfc.min() - 10, lfc.max() + 10)
    ax.set_ylim(-4, yval.max() * 1.08)
    ax.set_xlabel("Log$_2$ fold change", fontsize=6.8, labelpad=2)
    ax.set_ylabel("−Log$_{10}$ $P_{adj}$", fontsize=6.8, labelpad=2)
    ax.tick_params(labelsize=5.8, length=2.5, pad=1.5)
    for sp in ax.spines.values():
        sp.set_linewidth(0.7)
        sp.set_color("#222222")
    return ax


def main():
    parser = argparse.ArgumentParser(description="Render Main Figure 6 Panel D (DESeq2 volcano).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("fig06_d.png"))
    args = parser.parse_args()

    deg_df = pd.read_csv(args.paper_root / "runs" / "step06_mrseq_deseq2" / "deseq2_mis_vs_emim_symbol.csv")
    fig = plt.figure(figsize=(2.60, 2.00), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.20, right=0.95, top=0.90, bottom=0.20)
    draw_panel_6d(fig, gs[0, 0], deg_df)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[fig06_d] Saved -> {args.out}")


if __name__ == "__main__":
    main()
