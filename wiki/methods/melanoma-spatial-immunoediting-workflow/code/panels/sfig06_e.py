#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: sfig06/E
Title: DDX58 (HGNC official alias RIGI) expression in IM vs EM mROIs
Input tables:
  - runs/step06_mrseq_deseq2/deseq2_log2_norm_counts_symbol.csv
  - data_small/mrseq_meta_small.csv
Default size: 1.50 in x 2.20 in (300 dpi)
CLI usage:
  python sfig06_e.py --paper-root <sources_root>/papers/pmc9167783 --out sfig06_e.png
"""

import argparse
from pathlib import Path
import sys

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from scipy import stats

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _fig_common import DEFAULT_PAPER_ROOT

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["pdf.fonttype"] = 42


def draw_panel_s6e(fig, gs_slot, log2_df: pd.DataFrame, meta_df: pd.DataFrame):
    """Draw Panel S6E (DDX58/RIGI IM vs EM barplot + SEM + jitter + significance) inside gs_slot."""
    ax = fig.add_subplot(gs_slot)
    ax.text(-0.42, 1.15, "E", transform=ax.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    ax.set_title("DDX58 (RIGI)", fontsize=7.0, pad=5)

    gene = "DDX58" if "DDX58" in log2_df.index else "RIGI"
    im_ids = meta_df.loc[meta_df["site"] == "IM", "sample_id"].tolist()
    em_ids = meta_df.loc[meta_df["site"] == "EM", "sample_id"].tolist()

    v_im = log2_df.loc[gene, [c for c in im_ids if c in log2_df.columns]].to_numpy(dtype=float)
    v_em = log2_df.loc[gene, [c for c in em_ids if c in log2_df.columns]].to_numpy(dtype=float)

    means = [float(np.mean(v_im)), float(np.mean(v_em))]
    sems = [float(stats.sem(v_im)), float(stats.sem(v_em))]

    ax.bar([0, 1], means, width=0.68, color=["#C49B4E", "#8A8A8A"], edgecolor="none", zorder=2)
    ax.errorbar([0, 1], means, yerr=sems, fmt="none", ecolor="#222222", elinewidth=0.75, capsize=2.0, capthick=0.75, zorder=4)
    rng = np.random.default_rng(42)
    for xi, vals in enumerate([v_im, v_em]):
        jit = rng.uniform(-0.16, 0.16, size=len(vals))
        ax.scatter(np.full(len(vals), xi) + jit, vals, s=3.5, color="#2A3240", alpha=0.78, zorder=3)

    _, pv = stats.ttest_ind(v_im, v_em, equal_var=False)
    sig = "***" if pv < 0.001 else ("**" if pv < 0.01 else ("*" if pv < 0.05 else "ns"))
    ymax = max(float(v_im.max()), float(v_em.max()), 1.0)
    yb = ymax * 1.07
    col_s = "#C62828" if sig != "ns" else "#444444"
    ax.plot([0, 1], [yb, yb], color=col_s, lw=0.8)
    ax.text(0.5, yb + ymax * 0.015, sig, ha="center", va="bottom", fontsize=6.4, color=col_s, fontweight="bold" if sig != "ns" else "normal")

    ax.set_xticks([0, 1])
    ax.set_xticklabels(["IM", "EM"], fontsize=6.4)
    ax.set_ylim(0, ymax * 1.24)
    ax.set_ylabel("Expression (log$_2$)", fontsize=6.2, labelpad=2)
    ax.tick_params(axis="y", labelsize=5.4, length=2.2, pad=1.5)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.spines["left"].set_linewidth(0.7)
    ax.spines["bottom"].set_linewidth(0.7)
    return ax


def main():
    parser = argparse.ArgumentParser(description="Render Supp Figure S6 Panel E (DDX58/RIGI).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("sfig06_e.png"))
    args = parser.parse_args()

    log2_df = pd.read_csv(args.paper_root / "runs" / "step06_mrseq_deseq2" / "deseq2_log2_norm_counts_symbol.csv", index_col=0)
    meta_df = pd.read_csv(args.paper_root / "data_small" / "mrseq_meta_small.csv")

    fig = plt.figure(figsize=(1.60, 2.20), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.32, right=0.95, top=0.86, bottom=0.16)
    draw_panel_s6e(fig, gs[0, 0], log2_df, meta_df)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[sfig06_e] Saved -> {args.out}")


if __name__ == "__main__":
    main()
