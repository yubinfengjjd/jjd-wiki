#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: fig01/D
Title: Cell-type UMAP with Tumor dashed envelope + 3x3 marker intensity Feature UMAP grid
Input tables: runs/step02_umap_gradients/umap_coords_markers.csv
Default size: 3.10 in x 4.90 in (300 dpi)
CLI usage:
  python fig01_d.py --paper-root <sources_root>/papers/pmc9167783 --out fig01_d.png
"""

import argparse
from pathlib import Path
import sys

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.lines as mlines
import matplotlib.patches as mpatches
from matplotlib.colors import LinearSegmentedColormap, Normalize
from matplotlib.gridspec import GridSpecFromSubplotSpec
import numpy as np
import pandas as pd
from scipy.spatial import ConvexHull

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _fig_common import DEFAULT_PAPER_ROOT
from fig02_a import densify_umap_cloud

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["pdf.fonttype"] = 42

CELL_ORDER_1D = [
    ("Macrophages", "#98CD87"),
    ("Langerhans", "#D3E298"),
    ("CTL", "#F2C84B"),
    ("Tregs", "#E3256B"),
    ("T helper", "#F08C4B"),
    ("Exhausted", "#E87BA9"),
    ("Keratinocytes", "#8A6240"),
    ("Endothelial", "#7D95B5"),
    ("Mast cell", "#9B7AB8"),
    ("Tumor", "#9E9E9E"),
    ("Dendritic", "#227BA3"),
    ("PDL1+ DCs", "#1A5B8C"),
    ("PDL1+ Macs", "#2CA298"),
    ("CD11C+ Macs", "#74A892"),
    ("PD1+ CTL", "#D95F43"),
]


def map_1d_celltype(df: pd.DataFrame) -> pd.Series:
    mapping = {
        "Mac": "Macrophages",
        "LC": "Langerhans",
        "CTL": "CTL",
        "Treg": "Tregs",
        "Th": "T helper",
        "Tex": "Exhausted",
        "Ker": "Keratinocytes",
        "Endo": "Endothelial",
        "Mast cell": "Mast cell",
        "Mel": "Tumor",
        "DC": "Dendritic",
        "PD-L1+ DC": "PDL1+ DCs",
        "PD-L1+ mac": "PDL1+ Macs",
        "CD11C+ mac": "CD11C+ Macs",
        "PD1+ CTL": "PD1+ CTL",
        "Unknown": "Tumor",
    }
    res = df["phenotype_abbrev"].map(mapping).fillna("Tumor")
    # Reassign non-SOX10 Unknowns based on markers
    unk = df["phenotype_abbrev"] == "Unknown"
    if unk.any():
        sub = df.loc[unk]
        vals = []
        for _, r in sub.iterrows():
            if r.get("SOX10", 0) >= 0.35:
                vals.append("Tumor")
            elif r.get("pan-CK", 0) >= 0.35:
                vals.append("Keratinocytes")
            elif r.get("CD31", 0) >= 0.35:
                vals.append("Endothelial")
            elif r.get("CD11c", 0) >= 0.35:
                vals.append("CD11C+ Macs")
            else:
                vals.append("Macrophages")
        res.loc[unk] = vals
    return res


def draw_panel_1d(fig, gs_slot, umap_dense: pd.DataFrame):
    """Draw Panel 1D (UMAP by cell type + Tumor dashed hull + 3x3 marker UMAPs) inside gs_slot."""
    sub_gs = GridSpecFromSubplotSpec(
        3, 1, subplot_spec=gs_slot, height_ratios=[1.18, 1.35, 0.16], hspace=0.14
    )

    # Top: main UMAP + legend
    top_gs = GridSpecFromSubplotSpec(1, 2, subplot_spec=sub_gs[0, 0], width_ratios=[1.55, 0.85], wspace=0.05)
    ax_u = fig.add_subplot(top_gs[0, 0])
    ax_leg = fig.add_subplot(top_gs[0, 1])

    ax_u.text(-0.14, 1.06, "D", transform=ax_u.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    x = umap_dense["UMAP_1"].to_numpy()
    y = umap_dense["UMAP_2"].to_numpy()

    ct_col = umap_dense["cell_type_1d"]
    for cname, col in CELL_ORDER_1D:
        m = (ct_col == cname).to_numpy()
        if m.any():
            ax_u.scatter(x[m], y[m], c=col, s=0.9, alpha=0.68, edgecolors="none", rasterized=True)

    # Dashed convex hull around the single densest primary Tumor cluster only
    from sklearn.cluster import DBSCAN
    t_pts = np.column_stack([x[ct_col == "Tumor"], y[ct_col == "Tumor"]])
    if len(t_pts) >= 20:
        lbls = DBSCAN(eps=0.75, min_samples=15).fit_predict(t_pts)
        valid_lbls, counts = np.unique(lbls[lbls >= 0], return_counts=True)
        if len(valid_lbls) > 0:
            main_lbl = valid_lbls[np.argmax(counts)]
            core = t_pts[lbls == main_lbl]
        else:
            c0 = np.median(t_pts, axis=0)
            dists = np.linalg.norm(t_pts - c0, axis=1)
            core = t_pts[dists <= np.percentile(dists, 55)]
        if len(core) >= 4:
            c_core = core.mean(axis=0)
            hull = ConvexHull(core)
            hp = c_core + (core[hull.vertices] - c_core) * 1.06
            ax_u.add_patch(mpatches.Polygon(hp, closed=True, facecolor="none", edgecolor="#333333", linestyle="--", lw=0.85, zorder=5))
            ax_u.text(hp[:, 0].min() + 0.3, hp[:, 1].max() + 0.3, "Tumor", fontsize=6.4, color="#222222")

    xmin, xmax = np.percentile(x, [0.5, 99.5])
    ymin, ymax = np.percentile(y, [0.5, 99.5])
    ax_u.text(xmin + 0.05 * (xmax - xmin), ymin - 0.04 * (ymax - ymin), "UMAP1", fontsize=5.8, ha="left", va="top", color="#333333")
    ax_u.text(xmin - 0.04 * (xmax - xmin), ymin + 0.05 * (ymax - ymin), "UMAP2", fontsize=5.8, ha="right", va="bottom", rotation=90, color="#333333")
    ax_u.set_xticks([])
    ax_u.set_yticks([])
    for sp in ax_u.spines.values():
        sp.set_visible(False)

    ax_leg.axis("off")
    handles = [
        mlines.Line2D([], [], color="none", marker="o", markersize=4.0,
                      markerfacecolor=col, markeredgecolor="none",
                      label=cname.replace("+", "$^+$"))
        for cname, col in CELL_ORDER_1D
    ]
    ax_leg.legend(handles=handles, loc="center left", frameon=False, fontsize=5.0, handletextpad=0.1, labelspacing=0.16, borderpad=0.0)

    # Middle: 3x3 Feature UMAPs
    feat_gs = GridSpecFromSubplotSpec(3, 3, subplot_spec=sub_gs[1, 0], hspace=0.22, wspace=0.06)
    markers = [
        ("CD3", "CD3d"),
        ("CD8", "CD8a"),
        ("PD1", "PD1"),
        ("CD11C", "CD11c"),
        ("S100A (KI67 proxy)", "S100a"),
        ("SOX10", "SOX10"),
        ("HLADR (S100B proxy)", "HLADR"),
        ("HLAA (MITF proxy)", "HLAA"),
        ("KERATIN", "pan-CK"),
    ]
    cmap_1d = LinearSegmentedColormap.from_list("fig1d_bwr", ["#3B75AF", "#AFCBE3", "#EAEAEA", "#E5876A", "#B2182B"])
    for idx, (mlbl, mcol) in enumerate(markers):
        r, c = divmod(idx, 3)
        ax_m = fig.add_subplot(feat_gs[r, c])
        vals = umap_dense[mcol].to_numpy() if mcol in umap_dense.columns else np.zeros(len(umap_dense))
        order = np.argsort(vals)
        ax_m.scatter(x[order], y[order], c=vals[order], cmap=cmap_1d, vmin=0.0, vmax=1.0,
                     s=0.45, alpha=0.80, edgecolors="none", rasterized=True)
        ax_m.set_title(mlbl, fontsize=5.4, pad=2)
        ax_m.set_xticks([])
        ax_m.set_yticks([])
        for sp in ax_m.spines.values():
            sp.set_visible(False)

    # Bottom Expression colorbar
    ax_cb = fig.add_subplot(sub_gs[2, 0])
    cb_pos = ax_cb.get_position()
    ax_cb.axis("off")
    cb_ax = fig.add_axes([cb_pos.x0 + cb_pos.width * 0.25, cb_pos.y0 + 0.008, cb_pos.width * 0.38, 0.010])
    sm = plt.cm.ScalarMappable(cmap=cmap_1d, norm=Normalize(vmin=0.0, vmax=1.0))
    cb = fig.colorbar(sm, cax=cb_ax, orientation="horizontal")
    cb.set_ticks([0.0, 0.5, 1.0])
    cb.set_ticklabels(["0.0", "0.5", "1.0"])
    cb.ax.xaxis.set_ticks_position("top")
    cb.ax.tick_params(labelsize=5.0, length=1.6, pad=1)
    cb.outline.set_linewidth(0.4)
    cb_ax.text(-0.08, 0.5, "Expression", transform=cb_ax.transAxes, fontsize=5.8, va="center", ha="right")


def main():
    parser = argparse.ArgumentParser(description="Render Main Figure 1 Panel D (UMAP + 9 markers).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("fig01_d.png"))
    args = parser.parse_args()

    umap_df = pd.read_csv(args.paper_root / "runs" / "step02_umap_gradients" / "umap_coords_markers.csv")
    umap_df["cell_type_1d"] = map_1d_celltype(umap_df)
    umap_dense = densify_umap_cloud(umap_df, target_n=18000, seed=42)

    fig = plt.figure(figsize=(3.20, 4.90), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.08, right=0.96, top=0.94, bottom=0.04)
    draw_panel_1d(fig, gs[0, 0], umap_dense)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[fig01_d] Saved -> {args.out}")


if __name__ == "__main__":
    main()
