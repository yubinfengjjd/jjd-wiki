#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: sfig07/B
Title: HALLMARK IL6 JAK STAT3 SIGNALING GSEA running ES curve (bTIL vs EM/IM)
Input tables:
  - runs/step06_mrseq_deseq2/gsea_running_es_curves.csv
  - runs/step06_mrseq_deseq2/gsea_summary.csv
Default size: 2.00 in x 2.00 in (300 dpi)
CLI usage:
  python sfig07_b.py --paper-root <sources_root>/papers/pmc9167783 --out sfig07_b.png
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


def draw_panel_s7b(fig, gs_slot, curves_df: pd.DataFrame, summary_df: pd.DataFrame):
    """Draw Panel S7B (IL6 JAK STAT3 GSEA curve) inside gs_slot."""
    ax = fig.add_subplot(gs_slot)
    ax.text(-0.34, 1.15, "B", transform=ax.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    ax.set_title("IL6 JAK STAT3 SIGNALING", fontsize=6.4, pad=4)

    sub = curves_df[curves_df["panel"] == "FigS7B"].sort_values("x")
    x = sub["x"].to_numpy()
    es = sub["runningScore"].to_numpy()
    hits = sub.loc[sub["position"] == 1, "x"].to_numpy()

    ax.axhline(0.0, color="#222222", lw=0.75, zorder=1)
    peak_x = x[int(np.argmax(np.abs(es)))]
    ax.axvline(peak_x, color="#DF2B26", linestyle="--", lw=0.95, alpha=0.85, zorder=2)
    ax.plot(x, es, color="#DF2B26", lw=1.6, zorder=3)

    ymin_cur = min(es.min(), -0.05)
    bar_bot, bar_top = ymin_cur - 0.12, ymin_cur - 0.02
    ax.vlines(hits, bar_bot, bar_top, color="#111111", lw=0.45, alpha=0.85, zorder=2)

    srow = summary_df[summary_df["panel"] == "FigS7B"].iloc[0]
    pv = float(srow["p.adjust"])
    nes = float(srow["NES"])
    p_str = "P < 0.001" if pv < 0.001 else f"P = {pv:.3f}"
    ax.text(0.96, 0.94, f"Hallmark geneset\n{p_str}\nNES = {nes:.2f}",
            transform=ax.transAxes, ha="right", va="top", fontsize=5.2, color="#111111")

    ax.set_ylim(bar_bot - 0.02, max(es.max() * 1.18, 0.55))
    ax.set_xlim(0, x.max())
    ax.set_xlabel("Position in the Ranked List of Genes", fontsize=5.8, labelpad=2)
    ax.set_ylabel("Running Enrichment Score", fontsize=6.0, labelpad=2)
    ax.tick_params(labelsize=5.2, length=2.0, pad=1.5)
    for sp in ax.spines.values():
        sp.set_linewidth(0.7)
    return ax


def main():
    parser = argparse.ArgumentParser(description="Render Supp Figure S7 Panel B (JAK-STAT3 GSEA).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("sfig07_b.png"))
    args = parser.parse_args()

    curves_df = pd.read_csv(args.paper_root / "runs" / "step06_mrseq_deseq2" / "gsea_running_es_curves.csv")
    summary_df = pd.read_csv(args.paper_root / "runs" / "step06_mrseq_deseq2" / "gsea_summary.csv")

    fig = plt.figure(figsize=(2.10, 2.10), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.25, right=0.95, top=0.86, bottom=0.18)
    draw_panel_s7b(fig, gs[0, 0], curves_df, summary_df)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[sfig07_b] Saved -> {args.out}")


if __name__ == "__main__":
    main()
