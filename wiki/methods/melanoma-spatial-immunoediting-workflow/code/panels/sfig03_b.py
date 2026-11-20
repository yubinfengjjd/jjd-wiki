#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: sfig03/B
Title: Frequency of RCN9 across progression stages (N, P, MIS, IM) with sub-ROI dots + mean bars
Input tables:
  - runs/step03_rcn_lda/figs3b_rcn_freq_by_roi.csv
  - runs/step03_rcn_lda/fov_cells_with_rcn.csv
  - runs/step03_rcn_lda/figs3e_rcn_stage_pvalues.csv
Default size: 2.30 in x 1.80 in (300 dpi)
CLI usage:
  python sfig03_b.py --paper-root <sources_root>/papers/pmc9167783 --out sfig03_b.png
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


def draw_panel_s3b(fig, gs_slot, fov_df: pd.DataFrame, pval_df: pd.DataFrame):
    """Draw Panel S3B (RCN9 % frequency across N, P, MIS, IM sub-ROIs) inside gs_slot."""
    ax = fig.add_subplot(gs_slot)
    ax.text(-0.26, 1.15, "B", transform=ax.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    ax.set_title("Frequency of RCN9", fontsize=7.4, pad=5)

    # Split each FOV into 2x2 spatial quadrants (consistent with step03 S3E sub-ROIs)
    sub_rows = []
    for fid, grp in fov_df.groupby("fov_id"):
        xm, ym = grp["X_um"].median(), grp["Y_um"].median()
        st = str(grp["Stage"].iloc[0])
        for qx in (0, 1):
            for qy in (0, 1):
                qsub = grp[((grp["X_um"] >= xm) == bool(qx)) & ((grp["Y_um"] >= ym) == bool(qy))]
                if len(qsub):
                    pct = float((qsub["RCN"] == "RCN9").mean() * 100.0)
                    sub_rows.append({"Stage": st, "pct": pct})
    qdf = pd.DataFrame(sub_rows)

    stages = [("Normal", "N", "#3F3D6B"), ("Precursor", "P", "#D96B43"), ("MIS", "MIS", "#1D9A6C"), ("IM", "IM", "#B8862D")]
    rng = np.random.default_rng(42)

    means = []
    for xi, (sk, sl, col) in enumerate(stages):
        vals = qdf.loc[qdf["Stage"] == sk, "pct"].to_numpy()
        m = float(np.mean(vals)) if len(vals) else 0.0
        means.append(m)
        ax.bar(xi, m, width=0.58, color="#DCDCDC", edgecolor="none", zorder=1)
        if len(vals):
            jit = rng.uniform(-0.14, 0.14, size=len(vals))
            ax.scatter(np.full(len(vals), xi) + jit, vals, s=16, color=col, edgecolors="#222222", linewidths=0.4, zorder=3)

    ymax = max(float(qdf["pct"].max()) * 1.25, 35.0)
    # Significance labels from figs3e_rcn_stage_pvalues.csv
    r9_p = pval_df[pval_df["RCN"] == "RCN9"].set_index("comparison")["p_value"].to_dict()
    for xa, xb, key, yl in [
        (0, 1, "Normal_vs_Precursor", ymax * 0.72),
        (1, 2, "Precursor_vs_MIS", ymax * 0.80),
        (2, 3, "MIS_vs_IM", ymax * 0.88),
    ]:
        pv = r9_p.get(key, np.nan)
        sig = "*" if (np.isfinite(pv) and pv < 0.05) else "ns"
        cs = "#C62828" if sig == "*" else "#333333"
        ax.plot([xa, xb], [yl, yl], color=cs, lw=0.75)
        ax.text(0.5 * (xa + xb), yl + ymax * 0.015, sig, ha="center", va="bottom", fontsize=6.4, color=cs, fontweight="bold" if sig == "*" else "normal")

    ax.set_xticks(range(len(stages)))
    ax.set_xticklabels([s[1] for s in stages], fontsize=6.2)
    ax.set_ylim(-1, ymax)
    ax.set_ylabel("% Frequency", fontsize=6.6, labelpad=2)
    ax.tick_params(axis="y", labelsize=5.8, length=2.2, pad=1.5)
    for sp in ax.spines.values():
        sp.set_linewidth(0.7)
        sp.set_color("#222222")
    return ax


def main():
    parser = argparse.ArgumentParser(description="Render Supp Figure S3 Panel B (RCN9 frequency).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("sfig03_b.png"))
    args = parser.parse_args()

    fov_df = pd.read_csv(args.paper_root / "runs" / "step03_rcn_lda" / "fov_cells_with_rcn.csv")
    pval_df = pd.read_csv(args.paper_root / "runs" / "step03_rcn_lda" / "figs3e_rcn_stage_pvalues.csv")

    fig = plt.figure(figsize=(2.30, 1.90), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.22, right=0.95, top=0.84, bottom=0.16)
    draw_panel_s3b(fig, gs[0, 0], fov_df, pval_df)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[sfig03_b] Saved -> {args.out}")


if __name__ == "__main__":
    main()
