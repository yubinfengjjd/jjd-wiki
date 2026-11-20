#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: sfig07/F
Title: MIF positivity fraction across mROI sites (PickSeq proxy)
Input tables: runs/step06_mrseq_deseq2/figs7fg_mif_cd74_proxy.csv
Default size: 1.80 in x 2.10 in (300 dpi)
CLI usage:
  python sfig07_f.py --paper-root <sources_root>/papers/pmc9167783 --out sfig07_f.png
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


def draw_panel_s7f(fig, gs_slot, df_fg: pd.DataFrame):
    """Draw Panel S7F (MIF positivity fraction stacked bars across sites) inside gs_slot."""
    ax = fig.add_subplot(gs_slot)
    ax.text(-0.26, 1.24, "F", transform=ax.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    sites = ["bTIL", "IR", "IB", "IM", "EM"]
    x = np.arange(len(sites))
    sub = df_fg[df_fg["gene"] == "MIF"]

    pos_frac = np.array([
        float((sub.loc[sub["site"] == s, "log2_expr"].to_numpy() > 0).mean())
        if not sub.loc[sub["site"] == s].empty else 0.0
        for s in sites
    ])
    neg_frac = 1.0 - pos_frac

    ax.bar(x, pos_frac, width=0.80, color="#E25E3E", edgecolor="#222222", lw=0.45, label="MIF$^+$ (proxy)")
    ax.bar(x, neg_frac, bottom=pos_frac, width=0.80, color="#2C8E82", edgecolor="#222222", lw=0.45, label="MIF$^-$")
    ax.set_xticks(x)
    ax.set_xticklabels(["bTILs" if s == "bTIL" else s for s in sites], rotation=90, fontsize=5.6)
    ax.set_ylim(0, 1.02)
    ax.set_yticks([0.0, 0.5, 1.0])
    ax.set_yticklabels(["0.0", "0.5", "1.0"], fontsize=5.4)
    ax.set_ylabel("% mROIs", fontsize=6.2, labelpad=2)
    ax.legend(loc="lower center", bbox_to_anchor=(0.5, 1.02), ncol=1, frameon=False, fontsize=4.8,
              handlelength=0.8, handleheight=0.65, labelspacing=0.15)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.spines["left"].set_linewidth(0.7)
    ax.spines["bottom"].set_linewidth(0.7)
    return ax


def main():
    parser = argparse.ArgumentParser(description="Render Supp Figure S7 Panel F (MIF positivity).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("sfig07_f.png"))
    args = parser.parse_args()

    df_fg = pd.read_csv(args.paper_root / "runs" / "step06_mrseq_deseq2" / "figs7fg_mif_cd74_proxy.csv")
    fig = plt.figure(figsize=(1.80, 2.10), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.24, right=0.94, top=0.78, bottom=0.18)
    draw_panel_s7f(fig, gs[0, 0], df_fg)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[sfig07_f] Saved -> {args.out}")


if __name__ == "__main__":
    main()
