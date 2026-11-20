#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: fig06/I
Title: S100B co-expression network (r >= 0.6) with 1-step orange hubs and pill labels
Input tables:
  - runs/step07_network_survival/fig6i_network_nodes.csv
  - runs/step07_network_survival/fig6i_network_edges.csv
Default size: 2.90 in x 2.00 in (300 dpi)
CLI usage:
  python fig06_i.py --paper-root <sources_root>/papers/pmc9167783 --out fig06_i.png
"""

import argparse
from pathlib import Path
import sys

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.collections import LineCollection
import numpy as np
import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _fig_common import DEFAULT_PAPER_ROOT

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["pdf.fonttype"] = 42


def draw_panel_6i(fig, gs_slot, nodes_df: pd.DataFrame, edges_df: pd.DataFrame):
    """Draw Panel 6I (S100B co-expression network) inside gs_slot."""
    ax = fig.add_subplot(gs_slot)
    ax.text(-0.12, 1.08, "I", transform=ax.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")

    pos = {r["gene_symbol"]: (float(r["x"]), float(r["y"])) for _, r in nodes_df.iterrows()}
    segs = []
    for _, er in edges_df.iterrows():
        u, v = er["from"], er["to"]
        if u in pos and v in pos:
            segs.append([pos[u], pos[v]])

    if segs:
        lc = LineCollection(segs, colors="#9E9E9E", linewidths=0.45, alpha=0.55, zorder=1)
        ax.add_collection(lc)

    # Background grey nodes vs burnt-orange S100B 1-step module nodes
    bg = nodes_df[~nodes_df["in_s100b_1step"]]
    fg = nodes_df[nodes_df["in_s100b_1step"]]
    s100b = nodes_df[nodes_df["gene_symbol"] == "S100B"]

    ax.scatter(bg["x"], bg["y"], s=20, c="#BDBDBD", edgecolors="#666666", linewidths=0.35, zorder=2)
    ax.scatter(fg["x"], fg["y"], s=32, c="#D95F02", edgecolors="#444444", linewidths=0.45, zorder=3)
    if not s100b.empty:
        ax.scatter(s100b["x"], s100b["y"], s=52, c="#C44100", edgecolors="#111111", linewidths=0.65, zorder=4)

    # Center and zoom around the S100B 1-step core so the orange module sits in the visual center
    cx = float(fg["x"].median()) if not fg.empty else float(nodes_df["x"].median())
    cy = float(fg["y"].median()) if not fg.empty else float(nodes_df["y"].median())
    half_w, half_h = 11.5, 10.5

    # Key hub labels fanned radially around the S100B core with zero overlap
    wanted = ["S100B", "SERPINE2", "CTSL", "SCD", "PMEL", "NRP2", "TYR", "TBC1D7"]
    sub_lbl = nodes_df[nodes_df["gene_symbol"].isin(wanted)].copy()
    label_targets = {
        "SERPINE2": (cx + 4.8, cy + 4.6),
        "CTSL":     (cx - 5.2, cy + 4.8),
        "SCD":      (cx - 6.2, cy + 1.6),
        "S100B":    (cx + 5.8, cy + 1.2),
        "PMEL":     (cx - 5.8, cy - 2.2),
        "NRP2":     (cx - 2.4, cy - 5.4),
        "TYR":      (cx + 2.4, cy - 5.6),
        "TBC1D7":   (cx + 6.0, cy - 2.6),
    }

    for _, row in sub_lbl.iterrows():
        g = row["gene_symbol"]
        nx, ny = float(row["x"]), float(row["y"])
        tx, ty = label_targets.get(g, (nx + 2.5, ny + 2.5))
        ax.annotate(
            g,
            xy=(nx, ny),
            xytext=(tx, ty),
            fontsize=5.4,
            style="italic",
            fontweight="bold" if g == "S100B" else "normal",
            ha="center",
            va="center",
            color="#111111",
            bbox=dict(boxstyle="round,pad=0.18", facecolor="white", edgecolor="#888888", linewidth=0.45, alpha=0.94),
            arrowprops=dict(arrowstyle="-", color="#555555", lw=0.45, shrinkA=0, shrinkB=2),
            zorder=6,
        )

    ax.text(
        0.04, 0.94,
        f"Total nodes: {len(nodes_df)}\nTotal edges: {len(edges_df)}\nr ≥ 0.6",
        transform=ax.transAxes, ha="left", va="top", fontsize=5.6, color="#222222",
    )

    ax.set_xlim(cx - half_w, cx + half_w)
    ax.set_ylim(cy - half_h, cy + half_h)
    ax.set_xticks([])
    ax.set_yticks([])
    for sp in ax.spines.values():
        sp.set_linewidth(0.7)
        sp.set_color("#222222")
    return ax


def main():
    parser = argparse.ArgumentParser(description="Render Main Figure 6 Panel I (S100B co-expression network).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("fig06_i.png"))
    args = parser.parse_args()

    nodes_df = pd.read_csv(args.paper_root / "runs" / "step07_network_survival" / "fig6i_network_nodes.csv")
    edges_df = pd.read_csv(args.paper_root / "runs" / "step07_network_survival" / "fig6i_network_edges.csv")

    fig = plt.figure(figsize=(3.00, 2.00), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.06, right=0.96, top=0.92, bottom=0.05)
    draw_panel_6i(fig, gs[0, 0], nodes_df, edges_df)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[fig06_i] Saved -> {args.out}")


if __name__ == "__main__":
    main()
