#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: fig03/F
Title: Mirrored half-violin + IQR box + red decile quantile shift dumbbell plot (Normal vs Precursor)
Input tables:
  - runs/step03_rcn_lda/fig3f_mel_immune_raw_distances.csv
  - runs/step03_rcn_lda/fig3f_mel_immune_quantile_shift.csv
  - runs/step03_rcn_lda/fov_cells_with_rcn.csv
Default size: 5.20 in x 1.75 in (300 dpi)
CLI usage:
  python fig03_f.py --paper-root <sources_root>/papers/pmc9167783 --out fig03_f.png
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
from scipy import stats
from sklearn.neighbors import BallTree

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _fig_common import DEFAULT_PAPER_ROOT

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["pdf.fonttype"] = 42


def _compute_group_distances(fov_df: pd.DataFrame, target_types: list[str]) -> tuple[np.ndarray, np.ndarray]:
    """Compute shortest Melanocyte-to-target Euclidean distance (um) in Normal and Precursor FOVs."""
    out = {}
    for st in ["Normal", "Precursor"]:
        sub = fov_df[fov_df["Stage"] == st]
        coords = sub[["X_um", "Y_um"]].to_numpy()
        ph = sub["phenotype_abbrev"].astype(str).to_numpy()
        mel = coords[ph == "Mel"]
        tgt = coords[np.isin(ph, target_types)]
        if len(mel) and len(tgt):
            d, _ = BallTree(tgt, metric="euclidean").query(mel, k=1)
            out[st] = d.ravel()
        else:
            out[st] = np.array([])
    return out["Normal"], out["Precursor"]


def _draw_mirrored_raincloud(ax, d_norm: np.ndarray, d_prec: np.ndarray, title: str, show_stage_labels: bool = False):
    """Draw top blue Normal half-violin + bottom grey Precursor half-violin + red decile shift dumbbell lines."""
    rng = np.random.default_rng(42)
    all_v = np.concatenate([d_norm, d_prec])
    xmin = max(1.0, float(np.min(all_v)) * 0.85)
    xmax = float(np.max(all_v)) * 1.15
    xs = np.linspace(xmin, xmax, 250)

    def half_violin(vals, y_base, direction, col_fill):
        if len(vals) < 2:
            return
        kde = stats.gaussian_kde(vals, bw_method=0.60)
        dens = kde(xs)
        if dens.max() > 0:
            dens = dens / dens.max() * 0.36
        ax.fill_between(xs, y_base, y_base + direction * dens, facecolor=col_fill, edgecolor="#222222", linewidth=0.55, alpha=0.88, zorder=2)

        # Jittered strip below/above baseline
        jit = rng.uniform(0.03, 0.11, size=len(vals))
        ax.scatter(vals, y_base - direction * jit, s=4.0, color=col_fill, alpha=0.7, edgecolors="none", zorder=1)

        # IQR black bar + white median circle
        q25, q50, q75 = np.percentile(vals, [25, 50, 75])
        ax.plot([vals.min(), vals.max()], [y_base, y_base], color="#222222", lw=0.75, zorder=3)
        ax.plot([q25, q75], [y_base, y_base], color="#1A1A1A", lw=5.0, solid_capstyle="butt", zorder=4)
        ax.scatter([q50], [y_base], s=14, facecolor="white", edgecolor="#1A1A1A", linewidth=0.6, zorder=5)

    y_top, y_bot = 0.78, -0.78
    half_violin(d_norm, y_top, +1.0, "#62A9D8")
    half_violin(d_prec, y_bot, -1.0, "#B8B8B8")

    # 9 deciles (10..90%) connected by red lines
    deciles = [10, 20, 30, 40, 50, 60, 70, 80, 90]
    if len(d_norm) >= 2 and len(d_prec) >= 2:
        q_n = np.percentile(d_norm, deciles)
        q_p = np.percentile(d_prec, deciles)
        y_n_pt = y_top - 0.14
        y_p_pt = y_bot + 0.14
        for qn, qp in zip(q_n, q_p):
            ax.plot([qn, qp], [y_n_pt, y_p_pt], color="#C83737", lw=0.75, alpha=0.9, zorder=4)
        ax.scatter(q_n, np.full_like(q_n, y_n_pt), s=10, color="#C83737", edgecolors="#222222", linewidths=0.35, zorder=6)
        ax.scatter(q_p, np.full_like(q_p, y_p_pt), s=10, color="#C83737", edgecolors="#222222", linewidths=0.35, zorder=6)

    ax.set_xscale("log")
    ax.set_xlim(xmin * 0.85, xmax * 1.15)
    ax.set_ylim(-1.28, 1.32)
    x_min_t = int(round(xmin))
    x_max_t = int(round(xmax))
    med_p = int(round(np.median(d_prec))) if len(d_prec) else x_max_t
    if x_max_t / max(med_p, 1) >= 2.2 and med_p / max(x_min_t, 1) >= 2.2:
        ticks = [x_min_t, med_p, x_max_t]
    else:
        ticks = [x_min_t, x_max_t]
    ax.set_xticks(ticks)
    ax.set_xticklabels([f"{t:,}" for t in ticks], fontsize=5.8)
    ax.set_yticks([])
    ax.set_title(title, fontsize=6.6, pad=4)

    if show_stage_labels:
        ax.text(0.02, 0.88, "Normal", transform=ax.transAxes, fontsize=6.2, ha="left", va="bottom", color="#222222")
        ax.text(0.02, 0.04, "Precursor", transform=ax.transAxes, fontsize=6.2, ha="left", va="bottom", color="#222222")

    for sp in ax.spines.values():
        sp.set_visible(False)
    ax.spines["bottom"].set_visible(True)
    ax.spines["bottom"].set_linewidth(0.7)


def draw_panel_3f(fig, gs_slot, fov_df: pd.DataFrame, raw_3f: pd.DataFrame | None = None):
    """Draw Panel 3F (3-panel mirrored raincloud quantile-shift plot) inside gs_slot."""
    sub_gs = GridSpecFromSubplotSpec(1, 3, subplot_spec=gs_slot, wspace=0.18)

    # 1) Cytotoxic T (CTL proxy using Lymphoid T cells in N/P FOV since 0 CTL in N/P sample FOV)
    dn1, dp1 = _compute_group_distances(fov_df, ["CTL", "PD1+ CTL", "Tex", "Th", "Treg"])
    # 2) PDL1+ myeloid (proxy using Myeloid cells in N/P FOV since 0 PD-L1+ in N/P sample FOV)
    dn2, dp2 = _compute_group_distances(fov_df, ["PD-L1+ DC", "PD-L1+ mac", "DC", "CD11C+ mac", "Mac"])
    # 3) Tregs (exact from fig3f_mel_immune_raw_distances.csv)
    if raw_3f is not None and not raw_3f.empty:
        dn3 = raw_3f.loc[(raw_3f["Stage"] == "Normal") & (raw_3f["target_group"] == "Treg"), "dist_um"].to_numpy()
        dp3 = raw_3f.loc[(raw_3f["Stage"] == "Precursor") & (raw_3f["target_group"] == "Treg"), "dist_um"].to_numpy()
    else:
        dn3, dp3 = _compute_group_distances(fov_df, ["Treg"])

    specs = [
        (dn1, dp1, "Cytotoxic T (T proxy)", True),
        (dn2, dp2, "PDL1$^+$ myeloid (proxy)", False),
        (dn3, dp3, "Tregs", False),
    ]
    axes = []
    for idx, (dn, dp, title, show_lbl) in enumerate(specs):
        ax = fig.add_subplot(sub_gs[0, idx])
        axes.append(ax)
        _draw_mirrored_raincloud(ax, dn, dp, title, show_stage_labels=show_lbl)

    axes[0].text(-0.18, 1.15, "F", transform=axes[0].transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    fig.text(
        0.5 * (axes[0].get_position().x0 + axes[-1].get_position().x1),
        axes[0].get_position().y0 - 0.036,
        "Distance from melanocytes (μm)", ha="center", va="top", fontsize=6.8,
    )
    return axes


def main():
    parser = argparse.ArgumentParser(description="Render Main Figure 3 Panel F (mirrored quantile-shift raincloud).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("fig03_f.png"))
    args = parser.parse_args()

    fov_df = pd.read_csv(args.paper_root / "runs" / "step03_rcn_lda" / "fov_cells_with_rcn.csv")
    raw_3f = pd.read_csv(args.paper_root / "runs" / "step03_rcn_lda" / "fig3f_mel_immune_raw_distances.csv")

    fig = plt.figure(figsize=(5.30, 1.85), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.06, right=0.97, top=0.82, bottom=0.22)
    draw_panel_3f(fig, gs[0, 0], fov_df, raw_3f)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[fig03_f] Saved -> {args.out}")


if __name__ == "__main__":
    main()
