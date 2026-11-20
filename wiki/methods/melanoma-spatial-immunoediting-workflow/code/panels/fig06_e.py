#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: fig06/E
Title: KRAS SIGNALING UP GSEA running enrichment score curve (IM vs EM)
Input tables:
  - runs/step06_mrseq_deseq2/gsea_running_es_curves.csv
  - runs/step06_mrseq_deseq2/gsea_summary.csv
Default size: 2.00 in x 2.00 in (300 dpi)
CLI usage:
  python fig06_e.py --paper-root <sources_root>/papers/pmc9167783 --out fig06_e.png
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


def draw_panel_6e(fig, gs_slot, curves_df: pd.DataFrame, summary_df: pd.DataFrame):
    """Draw Panel 6E (KRAS SIGNALING UP GSEA curve + barcode + peak line) inside gs_slot."""
    ax = fig.add_subplot(gs_slot)
    ax.text(-0.34, 1.13, "E", transform=ax.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    ax.set_title("KRAS SIGNALING UP", fontsize=7.2, pad=4)

    sub = curves_df[curves_df["panel"] == "Fig6E"].sort_values("x")
    x = sub["x"].to_numpy()
    es = sub["runningScore"].to_numpy()
    hits = sub.loc[sub["position"] == 1, "x"].to_numpy()

    ax.axhline(0.0, color="#333333", linestyle="--", linewidth=0.75, zorder=1)
    peak_idx = int(np.argmax(np.abs(es)))
    peak_x = x[peak_idx]
    ax.axvline(peak_x, color="#E35B3A", linestyle="--", linewidth=0.95, alpha=0.85, zorder=2)
    ax.plot(x, es, color="#E35B3A", linewidth=1.6, zorder=3)

    # Bottom barcode ticks
    ymin_cur = min(es.min(), -0.05)
    bar_bottom = ymin_cur - 0.10
    bar_top = ymin_cur - 0.02
    ax.vlines(hits, bar_bottom, bar_top, color="#4A4A4A", linewidth=0.45, alpha=0.85, zorder=2)

    srow = summary_df[summary_df["panel"] == "Fig6E"].iloc[0]
    padj_v = float(srow["p.adjust"])
    nes_v = float(srow["NES"])
    stat_txt = f"FDR = {padj_v:.2f}\nNES = {nes_v:.2f}"
    ax.text(0.96, 0.94, stat_txt, transform=ax.transAxes, ha="right", va="top", fontsize=5.8, color="#222222")

    ax.set_ylim(bar_bottom - 0.02, max(es.max() * 1.15, 0.35))
    ax.set_xlim(0, x.max())
    ax.set_xlabel("Position in the ranked\nlist of genes", fontsize=6.4, labelpad=2)
    ax.set_ylabel("Enrichment score", fontsize=6.6, labelpad=2)
    ax.tick_params(labelsize=5.6, length=2.5, pad=1.5)
    for sp in ax.spines.values():
        sp.set_linewidth(0.7)
        sp.set_color("#222222")
    return ax


def main():
    parser = argparse.ArgumentParser(description="Render Main Figure 6 Panel E (KRAS GSEA).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("fig06_e.png"))
    args = parser.parse_args()

    curves_df = pd.read_csv(args.paper_root / "runs" / "step06_mrseq_deseq2" / "gsea_running_es_curves.csv")
    summary_df = pd.read_csv(args.paper_root / "runs" / "step06_mrseq_deseq2" / "gsea_summary.csv")

    fig = plt.figure(figsize=(2.00, 2.00), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.25, right=0.95, top=0.86, bottom=0.22)
    draw_panel_6e(fig, gs[0, 0], curves_df, summary_df)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[fig06_e] Saved -> {args.out}")


if __name__ == "__main__":
    main()
