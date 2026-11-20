#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: fig04/B
Title: Stage progression of significant Myeloid-T cell spatial co-occurrence (sub-ROI proxy)
Input tables: runs/step04_spatial_interaction/spatial_interaction_by_subroi.csv
Default size: 2.30 in x 2.30 in (300 dpi)
CLI usage:
  python fig04_b.py --paper-root <sources_root>/papers/pmc9167783 --out fig04_b.png
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


def compute_stage_cooccur_fraction(sub_df: pd.DataFrame) -> pd.DataFrame:
    """Compute fraction of Myeloid-T sub-ROI tests with significant positive co-occurrence (p<0.05, z>0)."""
    myeloid = {"PD-L1+ DC", "PD-L1+ mac", "DC", "Mac", "LC", "CD11C+ mac"}
    t_cells = {"CTL", "PD1+ CTL", "Tex", "Treg", "Th"}
    sub = sub_df[sub_df["phenotype"].isin(myeloid) & sub_df["neighbour_phenotype"].isin(t_cells)].copy()
    sub["is_sig_pos"] = (sub["p_value"] < 0.05) & (sub["z_score"] > 0)

    rows = []
    for st_full, st_short in [("Normal", "N"), ("Precursor", "P"), ("MIS", "MIS"), ("IM", "IM")]:
        s_sub = sub[sub["Stage"] == st_full]
        n_tot = s_sub["roi_unit"].nunique() if not s_sub.empty else 0
        n_sig = s_sub.loc[s_sub["is_sig_pos"], "roi_unit"].nunique() if not s_sub.empty else 0
        frac = (n_sig / n_tot) if n_tot > 0 else 0.0
        rows.append({"Stage": st_full, "short": st_short, "n_rois": n_tot, "n_sig": n_sig, "frac": frac})
    return pd.DataFrame(rows)


def draw_panel_4b(fig, gs_slot, sub_df: pd.DataFrame):
    """Draw Panel 4B (stage trend line + light grey panel background) inside gs_slot."""
    ax = fig.add_subplot(gs_slot)
    ax.set_facecolor("#EAEAEA")
    ax.text(-0.28, 1.15, "B", transform=ax.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    ax.set_title("Myeloid–T cell co-occurrence\n(sub-ROI proxy)", fontsize=7.2, pad=5)

    trend = compute_stage_cooccur_fraction(sub_df)
    x = np.arange(len(trend))
    y = trend["frac"].to_numpy()

    ax.plot(x, y, color="#73296E", linewidth=1.8, zorder=3)
    ax.scatter(x, y, s=26, color="#666666", edgecolors="#222222", linewidths=0.45, zorder=4)

    ax.set_xticks(x)
    ax.set_xticklabels(trend["short"].tolist(), fontsize=6.6)
    ymax = max(0.85, float(y.max()) * 1.18)
    ax.set_ylim(-0.04, ymax)
    ax.set_xlim(-0.35, 3.35)
    ax.set_yticks([0.0, 0.5, 1.0])
    ax.set_yticklabels(["0.0", "0.5", "1.0"], fontsize=6.2)
    ax.set_ylabel("Fraction of sub-ROIs", fontsize=6.6, labelpad=2)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.spines["left"].set_linewidth(0.7)
    ax.spines["bottom"].set_linewidth(0.7)
    return ax


def main():
    parser = argparse.ArgumentParser(description="Render Main Figure 4 Panel B (stage co-occurrence trend).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("fig04_b.png"))
    args = parser.parse_args()

    sub_df = pd.read_csv(args.paper_root / "runs" / "step04_spatial_interaction" / "spatial_interaction_by_subroi.csv")
    fig = plt.figure(figsize=(2.40, 2.30), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.22, right=0.95, top=0.80, bottom=0.14)
    draw_panel_4b(fig, gs[0, 0], sub_df)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[fig04_b] Saved -> {args.out}")


if __name__ == "__main__":
    main()
