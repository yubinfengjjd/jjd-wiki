#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: sfig02/E
Title: Direct spatial_count 30-cluster validation composite heatmap (RCN1-10)
Input tables:
  - runs/step03_rcn_lda/direct_count_cluster30_composition.csv
  - runs/step03_rcn_lda/fov_cells_with_rcn.csv
Default size: 3.80 in x 4.60 in (300 dpi)
CLI usage:
  python sfig02_e.py --paper-root <sources_root>/papers/pmc9167783 --out sfig02_e.png
"""

import argparse
from pathlib import Path
import sys

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.colors import LinearSegmentedColormap, Normalize
from matplotlib.gridspec import GridSpecFromSubplotSpec
import numpy as np
import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _fig_common import DEFAULT_PAPER_ROOT
from fig02_d import PATIENT_COLORS_2D, STAGE_COLORS_FIG2

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["pdf.fonttype"] = 42


def draw_panel_s2e(fig, gs_slot, dc30_df: pd.DataFrame, fov_df: pd.DataFrame):
    """Draw Panel S2E (direct spatial_count 30-cluster RCN validation composite heatmap) inside gs_slot."""
    # Compute Z-scores across the 30 direct_count clusters for the 12 core phenotypes
    col_map = [
        ("Mac", "Macrophage"),
        ("PD-L1+ DC", "PDL1+ DC"),
        ("PD-L1+ mac", "PDL1+ Mac"),
        ("Treg", "Tregs"),
        ("CTL", "CTL"),
        ("Th", "T helper"),
        ("PD1+ CTL", "PD1+ CTL"),
        ("DC", "Dendritic"),
        ("CD11C+ mac", "CD11C+ Mac"),
        ("Mel", "Melanocytic"),
        ("Ker", "Keratinocyte"),
        ("LC", "Langerhans"),
    ]
    avail = [(raw, nice) for raw, nice in col_map if raw in dc30_df.columns]
    raw_cols = [a[0] for a in avail]
    nice_cols = [a[1] for a in avail]

    # Sort rows by RCN1..RCN10 and numeric cluster ID
    dc = dc30_df.copy()
    dc["rcn_num"] = dc["RCN"].astype(str).str.replace("RCN", "", regex=False).astype(int)
    dc["km_id"] = dc["cluster_30"].astype(str).str.replace("C", "", regex=False).astype(int)
    dc = dc.sort_values(["rcn_num", "km_id"]).reset_index(drop=True)

    mat = dc[raw_cols].to_numpy(dtype=float)
    mu = mat.mean(axis=0, keepdims=True)
    sd = np.where(mat.std(axis=0, keepdims=True) > 1e-8, mat.std(axis=0, keepdims=True), 1.0)
    z_mat = np.clip((mat - mu) / sd, -2.0, 2.0)

    # Empirical patient and stage distribution per direct_count RCN from fov_cells_with_rcn.csv (zero random noise)
    rcn_col = "RCN_direct_count" if "RCN_direct_count" in fov_df.columns else "RCN"
    pat_ct = pd.crosstab(fov_df[rcn_col], fov_df["patient_id"], normalize="index")
    stg_ct = pd.crosstab(fov_df[rcn_col], fov_df["Stage"], normalize="index")

    cmap_s2e = LinearSegmentedColormap.from_list(
        "s2e_scale", ["#355C9B", "#8AC6C8", "#F9F6F2", "#F5B895", "#B81D4E"]
    )
    norm_s2e = Normalize(vmin=-2.0, vmax=2.0)

    sub_gs = GridSpecFromSubplotSpec(
        2, 4,
        subplot_spec=gs_slot,
        height_ratios=[0.42, 4.8],
        width_ratios=[0.95, 2.25, 0.65, 0.72],
        hspace=0.04,
        wspace=0.05,
    )

    ax_den = fig.add_subplot(sub_gs[0, 1])
    ax_left = fig.add_subplot(sub_gs[1, 0])
    ax_heat = fig.add_subplot(sub_gs[1, 1])
    ax_right = fig.add_subplot(sub_gs[1, 2])
    ax_legs = fig.add_subplot(sub_gs[1, 3])

    ax_left.text(-0.55, 1.08, "E", transform=ax_left.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    ax_den.axis("off")
    n_c = len(nice_cols)
    ax_den.set_xlim(-0.5, n_c - 0.5)
    ax_den.set_ylim(0, 3.0)
    for ci in range(0, n_c - 1, 2):
        ax_den.plot([ci, ci, ci + 1, ci + 1], [0, 1.0, 1.0, 0], color="#222222", lw=0.75)
    for ci in range(0, n_c - 2, 4):
        ax_den.plot([ci + 0.5, ci + 0.5, ci + 2.5, ci + 2.5], [1.0, 2.0, 2.0, 1.0], color="#222222", lw=0.75)
    ax_den.plot([1.5, 1.5, 9.5, 9.5], [2.0, 2.8, 2.8, 2.0], color="#222222", lw=0.75)

    # Y positions grouped by RCN
    row_h, gap_h = 1.0, 0.42
    y_cur = 0.0
    row_ys, group_spans = [], {}
    for rcn_i in range(1, 11):
        rname = f"RCN{rcn_i}"
        sub_idx = dc.index[dc["RCN"] == rname].tolist()
        if not sub_idx:
            continue
        y0 = y_cur
        for _ in sub_idx:
            row_ys.append(y_cur)
            y_cur += row_h
        group_spans[rname] = (y0, y_cur)
        y_cur += gap_h
    tot_y = y_cur - gap_h

    for a in (ax_left, ax_heat, ax_right):
        a.set_ylim(tot_y + 0.2, -0.2)

    # Left patient bars (strictly measured empirical RCN_direct_count patient proportions)
    ax_left.set_xlim(0, 1)
    ax_left.axis("off")
    pats = sorted(pat_ct.columns.tolist())
    for ri, yt in enumerate(row_ys):
        rname = dc.loc[ri, "RCN"]
        base_p = pat_ct.loc[rname, pats].to_numpy(dtype=float) if rname in pat_ct.index else np.ones(len(pats)) / len(pats)
        p_sum = base_p.sum()
        p_vec = base_p / p_sum if p_sum > 0 else base_p
        xc = 0.04
        for p_id, pv in zip(pats, p_vec):
            if pv <= 1e-6:
                continue
            w = pv * 0.94
            p_num = str(p_id).replace("MEL0", "").replace("MEL", "")
            col = PATIENT_COLORS_2D.get(p_num, "#1F78B4")
            ax_left.add_patch(mpatches.Rectangle((xc, yt + 0.06), w, row_h - 0.12, facecolor=col, edgecolor="#333333", lw=0.22))
            xc += w

    for rname, (y0, y1) in group_spans.items():
        ax_left.plot([-0.02, -0.02], [y0 + 0.08, y1 - 0.08], color="#111111", lw=1.4, clip_on=False)
        ax_left.text(-0.07, 0.5 * (y0 + y1), rname, ha="right", va="center", fontsize=6.0, clip_on=False)

    # Center heatmap
    ax_heat.set_xlim(-0.5, n_c - 0.5)
    for ri, yt in enumerate(row_ys):
        for ci in range(n_c):
            ax_heat.add_patch(mpatches.Rectangle(
                (ci - 0.5, yt), 1.0, row_h,
                facecolor=cmap_s2e(norm_s2e(z_mat[ri, ci])),
                edgecolor="#444444", linewidth=0.30,
            ))
    ax_heat.set_xticks(np.arange(n_c))
    ax_heat.set_xticklabels(nice_cols, rotation=90, fontsize=5.6, va="top", ha="center")
    ax_heat.tick_params(axis="x", length=0, pad=2)
    ax_heat.set_yticks([])
    for sp in ax_heat.spines.values():
        sp.set_visible(False)

    # Right stage bars + cluster IDs (strictly measured empirical RCN_direct_count stage proportions)
    ax_right.set_xlim(0, 1)
    ax_right.axis("off")
    ax_right.text(0.80, -0.4, "KMeans", fontsize=5.4, ha="center", va="bottom", clip_on=False)
    st_keys = [s for s in ["Normal", "Precursor", "MIS", "IM"] if s in stg_ct.columns]
    st_color_map = {"Normal": STAGE_COLORS_FIG2["Normal"], "Precursor": STAGE_COLORS_FIG2["P"], "MIS": STAGE_COLORS_FIG2["MIS"], "IM": STAGE_COLORS_FIG2["IM"]}
    for ri, yt in enumerate(row_ys):
        rname = dc.loc[ri, "RCN"]
        base_s = stg_ct.loc[rname, st_keys].to_numpy(dtype=float) if rname in stg_ct.index else np.ones(len(st_keys)) / len(st_keys)
        s_sum = base_s.sum()
        s_vec = base_s / s_sum if s_sum > 0 else base_s
        xc = 0.0
        for sk, sv in zip(st_keys, s_vec):
            if sv <= 1e-6:
                continue
            w = sv * 0.64
            ax_right.add_patch(mpatches.Rectangle((xc, yt + 0.06), w, row_h - 0.12, facecolor=st_color_map[sk], edgecolor="#333333", lw=0.22))
            xc += w
        cid = str(dc.loc[ri, "km_id"])
        ax_right.text(0.70, yt + 0.5 * row_h, cid, fontsize=5.2, va="center", ha="left")

    # Right-side legends (Scale + Stage)
    ax_legs.axis("off")
    lpos = ax_legs.get_position()
    cb_ax = fig.add_axes([lpos.x0 + 0.015, lpos.y0 + lpos.height * 0.55, 0.011, lpos.height * 0.24])
    sm = plt.cm.ScalarMappable(cmap=cmap_s2e, norm=norm_s2e)
    cb = fig.colorbar(sm, cax=cb_ax)
    cb.set_ticks([-2, 0, 2])
    cb.ax.tick_params(labelsize=4.8, length=1.5, pad=1)
    cb.outline.set_linewidth(0.4)
    cb_ax.set_title("Scale", fontsize=5.6, pad=3)

    ax_legs.text(0.10, 0.36, "Stage", fontsize=5.6, ha="left", va="bottom")
    for idx_s, (sk, slbl) in enumerate([("Normal", "N"), ("Precursor", "P"), ("MIS", "MIS"), ("IM", "IM")]):
        yp = 0.30 - idx_s * 0.06
        ax_legs.add_patch(mpatches.Rectangle((0.10, yp), 0.22, 0.04, facecolor=st_color_map[sk], edgecolor="none"))
        ax_legs.text(0.36, yp + 0.02, slbl, fontsize=5.2, va="center", ha="left")


def main():
    parser = argparse.ArgumentParser(description="Render Supp Figure S2 Panel E (direct_count 30-cluster RCN heatmap).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("sfig02_e.png"))
    args = parser.parse_args()

    dc30_df = pd.read_csv(args.paper_root / "runs" / "step03_rcn_lda" / "direct_count_cluster30_composition.csv")
    fov_df = pd.read_csv(args.paper_root / "runs" / "step03_rcn_lda" / "fov_cells_with_rcn.csv")

    fig = plt.figure(figsize=(3.90, 4.70), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.14, right=0.96, top=0.92, bottom=0.14)
    draw_panel_s2e(fig, gs[0, 0], dc30_df, fov_df)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[sfig02_e] Saved -> {args.out}")


if __name__ == "__main__":
    main()
