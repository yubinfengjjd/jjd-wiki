#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: sfig03/C
Title: Interaction CD11C+ cells and Melanocytes (10 um Proximity Volume Score across N, P, MIS, IM)
Input tables: runs/step04_spatial_interaction/figs3c_proximity_volume_by_stage.csv
Default size: 2.30 in x 1.60 in (300 dpi)
CLI usage:
  python sfig03_c.py --paper-root <sources_root>/papers/pmc9167783 --out sfig03_c.png
"""

import argparse
from pathlib import Path
import sys

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _fig_common import DEFAULT_PAPER_ROOT

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["pdf.fonttype"] = 42


def draw_panel_s3c(fig, gs_slot, df_s3c: pd.DataFrame):
    """Draw Panel S3C (10 um Proximity Volume Score bars across stages) inside gs_slot."""
    ax = fig.add_subplot(gs_slot)
    ax.text(-0.22, 1.26, "C", transform=ax.transAxes, fontsize=11, fontweight="bold", va="top", ha="left", clip_on=False)
    ax.set_title("Interaction CD11C$^+$ Cells\nand Melanocytes (10 μm FOV)", fontsize=6.6, pad=4)

    stages = [("Normal", "N", "#3F3D6B"), ("Precursor", "P", "#D96B43"), ("MIS", "MIS", "#1D9A6C"), ("IM", "IM", "#B8862D")]
    vals = []
    for sk, _, _ in stages:
        row = df_s3c[df_s3c["Stage"] == sk]
        vals.append(float(row["proximity_volume"].iloc[0]) if not row.empty else 0.0)

    ax.bar(range(len(stages)), vals, width=0.68, color=[s[2] for s in stages], edgecolor="none")
    ax.set_xticks(range(len(stages)))
    ax.set_xticklabels([s[1] for s in stages], fontsize=6.2)
    ax.set_ylim(0, max(max(vals) * 1.25, 0.005))
    ax.tick_params(axis="y", labelsize=5.5, length=2.2, pad=1.5)
    ax.set_ylabel("Proximity Volume Score", fontsize=6.2, labelpad=2)
    for sp in ax.spines.values():
        sp.set_linewidth(0.7)
        sp.set_color("#222222")
    return ax


def main():
    parser = argparse.ArgumentParser(description="Render Supp Figure S3 Panel C (proximity volume score).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("sfig03_c.png"))
    args = parser.parse_args()

    df_s3c = pd.read_csv(args.paper_root / "runs" / "step04_spatial_interaction" / "figs3c_proximity_volume_by_stage.csv")
    fig = plt.figure(figsize=(2.30, 1.70), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.24, right=0.95, top=0.80, bottom=0.16)
    draw_panel_s3c(fig, gs[0, 0], df_s3c)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[sfig03_c] Saved -> {args.out}")


if __name__ == "__main__":
    main()
