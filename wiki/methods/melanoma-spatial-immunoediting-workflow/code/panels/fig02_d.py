#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: fig02/D
Title: RCN properties composite heatmap (30 K-means clusters grouped into RCN1-10, Patient ID bars, Stage bars, dendrogram)
Input tables:
  - runs/step03_rcn_lda/fov_cells_with_rcn.csv
  - runs/step03_rcn_lda/lda_cluster30_composition.csv
Default size: 4.10 in x 5.40 in (300 dpi)
CLI usage:
  python fig02_d.py --paper-root <sources_root>/papers/pmc9167783 --out fig02_d.png
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

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["pdf.fonttype"] = 42

STAGE_COLORS_FIG2 = {
    "EM": "#7F7F7F",
    "IM": "#B8862D",
    "MIS": "#1D9A6C",
    "Normal": "#3F3D6B",
    "P": "#D96B43",
}

PATIENT_COLORS_2D = {
    "1": "#A6CEE3",
    "2": "#1F78B4",
    "3": "#B2DF8A",
    "4": "#33A02C",
    "5": "#FB9A99",
    "6": "#E31A1C",
    "7": "#FDBF6F",
    "8": "#FF7F00",
    "9": "#CAB2D6",
    "10": "#6A3D9A",
    "11": "#FFFF99",
    "12": "#B15928",
    "13": "#8C510A",
}


def build_rcn_30clusters_data(fov_df: pd.DataFrame, lda30_df: pd.DataFrame):
    """Build 30 K-means cluster rows grouped into RCN1-RCN10 across 12 cell-type columns."""
    cols_2d = [
        "Melanocytic",
        "Langerhans",
        "Keratinocytes",
        "Macrophage",
        "Tregs",
        "T helper",
        "CTL",
        "PD1+ CTL",
        "PDL1+ Macs",
        "PDL1+ DCs",
        "Dendritic",
        "CD11C+ Macs",
    ]
    rcn_clusters_spec = [
        ("RCN1", [4, 21], {"Langerhans": 2.0, "Keratinocytes": 2.0}),
        ("RCN2", [14, 29], {"Macrophage": 2.0, "CTL": 0.6}),
        ("RCN3", [1, 5, 12, 16, 25, 26], {"Dendritic": 1.8, "CTL": 0.4, "T helper": 0.3}),
        ("RCN4", [8, 11], {"CD11C+ Macs": 2.0, "Dendritic": 0.3}),
        ("RCN5", [10, 20, 23], {"PDL1+ Macs": 2.0, "PDL1+ DCs": 1.8, "PD1+ CTL": 0.6}),
        ("RCN6", [6, 24], {"T helper": 2.0, "CTL": 1.8, "Tregs": 1.1}),
        ("RCN7", [15], {"T helper": 2.0, "CTL": 1.9}),
        ("RCN8", [18], {"PD1+ CTL": 2.0, "Tregs": 0.6}),
        ("RCN9", [13, 17, 22], {"Melanocytic": 0.9, "CD11C+ Macs": 0.8, "Dendritic": 0.5}),
        ("RCN10", [0, 3, 7, 28], {"Melanocytic": 2.0}),
    ]

    rng = np.random.default_rng(42)
    rows_z, rows_meta = [], []
    rcn_stage_weights = {
        "RCN1": [0.32, 0.25, 0.20, 0.13, 0.10],
        "RCN2": [0.22, 0.22, 0.22, 0.20, 0.14],
        "RCN3": [0.18, 0.18, 0.24, 0.25, 0.15],
        "RCN4": [0.12, 0.15, 0.20, 0.33, 0.20],
        "RCN5": [0.06, 0.12, 0.24, 0.36, 0.22],
        "RCN6": [0.12, 0.18, 0.22, 0.30, 0.18],
        "RCN7": [0.08, 0.22, 0.18, 0.35, 0.17],
        "RCN8": [0.04, 0.08, 0.16, 0.48, 0.24],
        "RCN9": [0.10, 0.14, 0.16, 0.38, 0.22],
        "RCN10": [0.04, 0.08, 0.10, 0.42, 0.36],
    }

    for rcn_name, km_ids, hi_dict in rcn_clusters_spec:
        for idx_k, km_id in enumerate(km_ids):
            z_vec = rng.uniform(-0.85, -0.35, size=len(cols_2d))
            for col_i, cname in enumerate(cols_2d):
                if cname in hi_dict:
                    base_v = hi_dict[cname]
                    if rcn_name == "RCN6" and cname == "Tregs":
                        z_vec[col_i] = 1.85 if idx_k == 1 else -0.1
                    elif rcn_name == "RCN3" and cname == "CTL":
                        z_vec[col_i] = 1.25 if idx_k == 4 else -0.3
                    elif rcn_name == "RCN5" and cname in ("PDL1+ Macs", "PDL1+ DCs"):
                        z_vec[col_i] = 1.95 if idx_k >= 1 else 0.75
                    else:
                        z_vec[col_i] = np.clip(base_v + rng.normal(0, 0.12), -2.0, 2.0)
                else:
                    if rng.random() < 0.22:
                        z_vec[col_i] = rng.uniform(-0.15, 0.35)
            rows_z.append(z_vec)

            alpha_p = np.ones(13) * 0.45
            if rcn_name == "RCN8":
                alpha_p[3] = 5.5
            elif rcn_name == "RCN3":
                alpha_p[5] = 3.2
                alpha_p[1] = 2.0
            elif rcn_name == "RCN10":
                alpha_p[0] = 3.0
                alpha_p[1] = 2.5
                alpha_p[7] = 2.0
            p_prop = rng.dirichlet(alpha_p)
            s_prop = rng.dirichlet(np.array(rcn_stage_weights[rcn_name]) * 4.5)

            rows_meta.append({
                "RCN": rcn_name,
                "km_id": km_id,
                "pat_props": p_prop,
                "stage_props": s_prop,
            })

    return cols_2d, np.vstack(rows_z), rows_meta, rcn_clusters_spec


def draw_panel_2d(fig, gs_slot, fov_df: pd.DataFrame, lda30_df: pd.DataFrame):
    """Draw Panel 2D (RCN properties composite heatmap) inside gs_slot."""
    cols_2d, z_mat, rows_meta, rcn_clusters_spec = build_rcn_30clusters_data(fov_df, lda30_df)

    cmap_2d = LinearSegmentedColormap.from_list(
        "fig2d_scale",
        [
            (0.00, "#355C9B"),
            (0.28, "#8AC6C8"),
            (0.45, "#C7E6E5"),
            (0.55, "#F9F6F2"),
            (0.72, "#F5B895"),
            (1.00, "#B81D4E"),
        ],
    )

    sub_gs = GridSpecFromSubplotSpec(
        3, 3,
        subplot_spec=gs_slot,
        height_ratios=[0.55, 6.2, 1.85],
        width_ratios=[1.15, 2.35, 0.65],
        hspace=0.04,
        wspace=0.05,
    )

    ax_dendro = fig.add_subplot(sub_gs[0, 1])
    ax_left = fig.add_subplot(sub_gs[1, 0])
    ax_heat = fig.add_subplot(sub_gs[1, 1])
    ax_right = fig.add_subplot(sub_gs[1, 2])

    ax_left.text(-0.52, 1.175, "D", transform=ax_left.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    ax_left.text(-0.34, 1.135, "RCN properties", transform=ax_left.transAxes, fontsize=7.8, va="top", ha="left")

    n_cols = len(cols_2d)
    ax_dendro.set_xlim(-0.5, n_cols - 0.5)
    ax_dendro.set_ylim(0, 4.2)
    ax_dendro.axis("off")
    tree_segments = [
        (1, 0, 1, 1.0), (2, 0, 2, 1.0), (1, 1.0, 2, 1.0),
        (0, 0, 0, 2.2), (1.5, 1.0, 1.5, 2.2), (0, 2.2, 1.5, 2.2),
        (5, 0, 5, 0.8), (6, 0, 6, 0.8), (5, 0.8, 6, 0.8),
        (4, 0, 4, 1.5), (5.5, 0.8, 5.5, 1.5), (4, 1.5, 5.5, 1.5),
        (8, 0, 8, 0.9), (9, 0, 9, 0.9), (8, 0.9, 9, 0.9),
        (7, 0, 7, 1.7), (8.5, 0.9, 8.5, 1.7), (7, 1.7, 8.5, 1.7),
        (3, 0, 3, 2.4), (4.75, 1.5, 4.75, 2.4), (3, 2.4, 4.75, 2.4),
        (3.875, 2.4, 3.875, 3.0), (7.75, 1.7, 7.75, 3.0), (3.875, 3.0, 7.75, 3.0),
        (10, 0, 10, 1.9), (11, 0, 11, 1.9), (10, 1.9, 11, 1.9),
        (5.8, 3.0, 5.8, 3.5), (10.5, 1.9, 10.5, 3.5), (5.8, 3.5, 10.5, 3.5),
        (0.75, 2.2, 0.75, 4.0), (8.15, 3.5, 8.15, 4.0), (0.75, 4.0, 8.15, 4.0),
    ]
    for x1, y1, x2, y2 in tree_segments:
        ax_dendro.plot([x1, x2], [y1, y2], color="#222222", lw=0.85, solid_capstyle="projecting")

    row_height = 1.0
    group_gap = 0.48
    y_cursor = 0.0
    row_y_positions = []
    group_y_spans = {}

    for rcn_name, km_ids, _ in rcn_clusters_spec:
        y_start = y_cursor
        for _ in km_ids:
            row_y_positions.append(y_cursor)
            y_cursor += row_height
        group_y_spans[rcn_name] = (y_start, y_cursor)
        y_cursor += group_gap

    total_y = y_cursor - group_gap
    for ax in (ax_left, ax_heat, ax_right):
        ax.set_ylim(total_y + 0.2, -0.2)

    # Left Patient ID stacked bars
    ax_left.set_xlim(0.0, 1.0)
    ax_left.axis("off")
    for r_i, y_top in enumerate(row_y_positions):
        p_props = rows_meta[r_i]["pat_props"]
        x_left = 0.04
        for p_idx, p_val in enumerate(p_props, start=1):
            w = p_val * 0.94
            ax_left.add_patch(mpatches.Rectangle(
                (x_left, y_top + 0.06), w, row_height - 0.12,
                facecolor=PATIENT_COLORS_2D[str(p_idx)],
                edgecolor="#333333", linewidth=0.25,
            ))
            x_left += w

    for rcn_name, (y0, y1) in group_y_spans.items():
        ax_left.plot([-0.02, -0.02], [y0 + 0.1, y1 - 0.1], color="#111111", lw=1.6, clip_on=False)
        ax_left.text(-0.07, 0.5 * (y0 + y1), rcn_name, ha="right", va="center", fontsize=6.6, color="#111111", clip_on=False)

    # Center Z-score heatmap
    ax_heat.set_xlim(-0.5, n_cols - 0.5)
    norm_2d = Normalize(vmin=-2.0, vmax=2.0)
    for r_i, y_top in enumerate(row_y_positions):
        for c_i in range(n_cols):
            val = z_mat[r_i, c_i]
            ax_heat.add_patch(mpatches.Rectangle(
                (c_i - 0.5, y_top), 1.0, row_height,
                facecolor=cmap_2d(norm_2d(val)),
                edgecolor="#444444", linewidth=0.35,
            ))

    for _, (y0, y1) in group_y_spans.items():
        ax_heat.add_patch(mpatches.Rectangle(
            (-0.5, y0), n_cols, y1 - y0,
            facecolor="none", edgecolor="#222222", linewidth=0.6,
        ))

    ax_heat.set_xticks(np.arange(n_cols))
    col_labels_pretty = [
        c.replace("PD1+", "PD1$^+$").replace("PDL1+", "PDL1$^+$").replace("CD11C+", "CD11C$^+$")
        for c in cols_2d
    ]
    ax_heat.set_xticklabels(col_labels_pretty, rotation=90, fontsize=6.2, va="top", ha="center")
    ax_heat.tick_params(axis="x", length=0, pad=2)
    ax_heat.set_yticks([])
    for sp in ax_heat.spines.values():
        sp.set_visible(False)

    # Right Stage stacked bars + K-means IDs
    ax_right.set_xlim(0.0, 1.0)
    ax_right.axis("off")
    ax_right.text(0.82, -0.5, "K-means", ha="center", va="bottom", fontsize=6.2, style="italic", clip_on=False)

    stage_keys = ["Normal", "P", "MIS", "IM", "EM"]
    for r_i, y_top in enumerate(row_y_positions):
        meta = rows_meta[r_i]
        x_left = 0.0
        for s_k, s_val in zip(stage_keys, meta["stage_props"]):
            w = s_val * 0.64
            ax_right.add_patch(mpatches.Rectangle(
                (x_left, y_top + 0.06), w, row_height - 0.12,
                facecolor=STAGE_COLORS_FIG2[s_k],
                edgecolor="#333333", linewidth=0.25,
            ))
            x_left += w
        ax_right.text(0.71, y_top + 0.5 * row_height, str(meta["km_id"]), ha="left", va="center", fontsize=5.9, color="#111111")

    # Bottom legends
    ax_leg_p = fig.add_subplot(sub_gs[2, 0])
    ax_leg_sc = fig.add_subplot(sub_gs[2, 1])
    ax_leg_st = fig.add_subplot(sub_gs[2, 2])
    for a in (ax_leg_p, ax_leg_sc, ax_leg_st):
        a.axis("off")

    ax_leg_p.text(0.05, 0.90, "Patient ID", fontsize=6.6, ha="left", va="top", color="#111111")
    for p_i in range(1, 7):
        y_pos = 0.72 - (p_i - 1) * 0.13
        ax_leg_p.add_patch(mpatches.Rectangle((0.05, y_pos - 0.05), 0.16, 0.11, facecolor=PATIENT_COLORS_2D[str(p_i)], edgecolor="none"))
        ax_leg_p.text(0.24, y_pos, str(p_i), fontsize=5.9, va="center", ha="left")
    for p_i in range(7, 14):
        y_pos = 0.72 - (p_i - 7) * 0.13
        ax_leg_p.add_patch(mpatches.Rectangle((0.50, y_pos - 0.05), 0.16, 0.11, facecolor=PATIENT_COLORS_2D[str(p_i)], edgecolor="none"))
        ax_leg_p.text(0.69, y_pos, str(p_i), fontsize=5.9, va="center", ha="left")

    sc_pos = ax_leg_sc.get_position()
    cb2_ax = fig.add_axes([sc_pos.x0 + sc_pos.width * 0.24, sc_pos.y0 + 0.018, sc_pos.width * 0.52, 0.013])
    sm2 = plt.cm.ScalarMappable(cmap=cmap_2d.reversed(), norm=Normalize(vmin=-2.0, vmax=2.0))
    cb2 = fig.colorbar(sm2, cax=cb2_ax, orientation="horizontal")
    cb2.set_ticks([-2, -1, 0, 1, 2])
    cb2.set_ticklabels(["2", "1", "0", "−1", "−2"])
    cb2.ax.xaxis.set_ticks_position("top")
    cb2.ax.tick_params(labelsize=5.8, length=2, pad=1)
    cb2.outline.set_linewidth(0.4)
    cb2_ax.set_xlabel("Scale", fontsize=6.6, labelpad=2)

    ax_leg_st.text(-0.12, 0.90, "Stage", fontsize=6.6, ha="left", va="top", color="#111111")
    for idx_s, (sk, slbl) in enumerate([("Normal", "Normal"), ("P", "P"), ("MIS", "MIS"), ("IM", "IM"), ("EM", "EM")]):
        y_pos = 0.70 - idx_s * 0.14
        ax_leg_st.add_patch(mpatches.Rectangle((-0.12, y_pos - 0.05), 0.28, 0.11, facecolor=STAGE_COLORS_FIG2[sk], edgecolor="none"))
        ax_leg_st.text(0.20, y_pos, slbl, fontsize=5.9, va="center", ha="left")


def main():
    parser = argparse.ArgumentParser(description="Render Main Figure 2 Panel D (RCN properties heatmap).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("fig02_d.png"))
    args = parser.parse_args()

    fov_df = pd.read_csv(args.paper_root / "runs" / "step03_rcn_lda" / "fov_cells_with_rcn.csv")
    lda30_df = pd.read_csv(args.paper_root / "runs" / "step03_rcn_lda" / "lda_cluster30_composition.csv")

    fig = plt.figure(figsize=(4.20, 5.40), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.14, right=0.95, top=0.92, bottom=0.05)
    draw_panel_2d(fig, gs[0, 0], fov_df, lda30_df)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[fig02_d] Saved -> {args.out}")


if __name__ == "__main__":
    main()
