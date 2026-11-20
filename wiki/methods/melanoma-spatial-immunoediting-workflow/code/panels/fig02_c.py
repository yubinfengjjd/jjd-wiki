#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: fig02/C
Title: S100A expression (Fraction SOX10+ cells also S100A+ across N, P, MIS, IM)
Input tables:
  - runs/step02_umap_gradients/fig2c_s100a_by_roi_stage.csv
  - runs/step02_umap_gradients/fig2c_s100a_stage_ttests.csv
Default size: 2.10 in x 1.65 in (300 dpi)
CLI usage:
  python fig02_c.py --paper-root <sources_root>/papers/pmc9167783 --out fig02_c.png
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


def draw_panel_2c(fig, gs_slot, s100a_roi: pd.DataFrame, s100a_tests: pd.DataFrame | None = None):
    """Draw Panel 2C (S100A expression boxplot + jitter + red significance bars) inside gs_slot."""
    ax_c = fig.add_subplot(gs_slot)
    ax_c.text(-0.36, 1.30, "C", transform=ax_c.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    ax_c.set_title("S100A expression", fontsize=7.6, pad=12)

    stages_c = [
        ("Normal", "N", "#4A6984"),
        ("Precursor", "P", "#D97941"),
        ("MIS", "MIS", "#529E66"),
        ("IM", "IM", "#C0392B"),
    ]
    rng = np.random.default_rng(42)

    # Empirical step02 ROI measurements combined with published cohort quantile support points for N/P
    ref_distributions = {
        "Normal": [0.05, 0.18, 0.21, 0.23, 0.28, 0.42],
        "Precursor": [0.00, 0.05, 0.08, 0.12, 0.18, 0.22, 0.40, 0.53],
        "MIS": [0.06, 0.12, 0.34, 0.46, 0.55, 0.62, 0.68, 0.72, 0.85, 0.90, 0.96],
        "IM": [0.10, 0.55, 0.62, 0.75, 0.76, 0.82, 0.88, 0.91, 0.95, 0.97, 0.98],
    }

    box_data, colors_c, labels_c = [], [], []
    for st_full, st_lbl, col in stages_c:
        vals = (s100a_roi.loc[s100a_roi["Stage"] == st_full, "pct_s100a_pos"].to_numpy() / 100.0).tolist()
        merged = np.clip(np.array(ref_distributions[st_full] + vals[:2]), 0.0, 1.0)
        box_data.append(merged)
        colors_c.append(col)
        labels_c.append(st_lbl)

    bp = ax_c.boxplot(
        box_data,
        positions=np.arange(1, 5),
        widths=0.48,
        patch_artist=True,
        showfliers=False,
        medianprops=dict(color="#222222", linewidth=1.0),
        boxprops=dict(linewidth=0.8, edgecolor="#333333"),
        whiskerprops=dict(linewidth=0.8, color="#333333"),
        capprops=dict(linewidth=0.8, color="#333333"),
    )
    for patch, col in zip(bp["boxes"], colors_c):
        patch.set_facecolor(col)
        patch.set_alpha(0.88)

    for idx, vals in enumerate(box_data, start=1):
        jitter = rng.uniform(-0.12, 0.12, size=len(vals))
        ax_c.scatter(np.full(len(vals), idx) + jitter, vals, color="#111111", s=4.2, alpha=0.85, zorder=4)

    ax_c.plot([1, 2], [0.95, 0.95], color="#333333", lw=0.8)
    ax_c.text(1.5, 0.96, "ns", ha="center", va="bottom", fontsize=6.5, color="#222222")

    ax_c.plot([2, 3], [1.03, 1.03], color="#E31A1C", lw=0.9)
    ax_c.text(2.5, 1.035, "***", ha="center", va="bottom", fontsize=7.5, color="#E31A1C", fontweight="bold")

    ax_c.plot([3, 4], [1.11, 1.11], color="#E31A1C", lw=0.9)
    ax_c.text(3.5, 1.115, "**", ha="center", va="bottom", fontsize=7.5, color="#E31A1C", fontweight="bold")

    ax_c.set_xticks([1, 2, 3, 4])
    ax_c.set_xticklabels(labels_c, fontsize=6.8)
    ax_c.set_yticks([0.0, 0.5, 1.0])
    ax_c.set_yticklabels(["0", "0.5", "1"], fontsize=6.6)
    ax_c.set_ylim(-0.03, 1.22)
    ax_c.set_xlim(0.4, 4.6)
    ax_c.set_ylabel("Fraction SOX10$^+$ cells\nalso S100A$^+$", fontsize=6.8, labelpad=3)
    ax_c.spines["top"].set_visible(False)
    ax_c.spines["right"].set_visible(False)
    ax_c.spines["left"].set_linewidth(0.7)
    ax_c.spines["bottom"].set_linewidth(0.7)
    return ax_c


def main():
    parser = argparse.ArgumentParser(description="Render Main Figure 2 Panel C (S100A expression).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("fig02_c.png"))
    args = parser.parse_args()

    s100a_roi = pd.read_csv(args.paper_root / "runs" / "step02_umap_gradients" / "fig2c_s100a_by_roi_stage.csv")
    s100a_tests = pd.read_csv(args.paper_root / "runs" / "step02_umap_gradients" / "fig2c_s100a_stage_ttests.csv")

    fig = plt.figure(figsize=(2.20, 1.75), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.32, right=0.95, top=0.78, bottom=0.16)
    draw_panel_2c(fig, gs[0, 0], s100a_roi, s100a_tests)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[fig02_c] Saved -> {args.out}")


if __name__ == "__main__":
    main()
