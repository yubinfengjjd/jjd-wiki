#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Panel ID: sfig01/C
Title: Quantitative Hierarchical Phenotyping Decision Tree (Table S5 rules + local cell counts)
Input tables:
  - runs/step01_phenotype/table_s5_panel2_rules.csv
  - runs/step01_phenotype/stratified_phenotyped.csv
Default size: 4.00 in x 4.50 in (300 dpi)
CLI usage:
  python sfig01_c.py --paper-root <sources_root>/papers/pmc9167783 --out sfig01_c.png
"""

import argparse
from pathlib import Path
import sys

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _fig_common import DEFAULT_PAPER_ROOT

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["pdf.fonttype"] = 42


def draw_panel_s1c(fig, gs_slot, strat_df: pd.DataFrame, rules_df: pd.DataFrame):
    """Draw Panel S1C (quantitative hierarchical phenotyping gating tree) inside gs_slot."""
    ax = fig.add_subplot(gs_slot)
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 100)
    ax.axis("off")
    ax.text(-0.04, 1.03, "C", transform=ax.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")

    counts = strat_df["phenotype_abbrev"].value_counts().to_dict()
    n_tot = len(strat_df)

    def cnt(keys):
        return sum(counts.get(k, 0) for k in keys)

    # Nodes: (id, x, y, w, h, label)
    nodes = {
        "all":      (62, 93, 18, 5.5, f"All Cells\n(n={n_tot:,})"),
        "ker":      (10, 81, 17, 6.5, f"Keratinocyte\n(Ker, n={cnt(['Ker'])})"),
        "endo":     (29, 81, 17, 6.5, f"Endothelial\n(Endo, n={cnt(['Endo'])})"),
        "rest":     (48, 81, 15, 6.5, f"All-rest\n(n={n_tot - cnt(['Ker','Endo','Mel'])})"),
        "mel":      (86, 81, 18, 6.5, f"Melanocyte / Mel\n(n={cnt(['Mel'])})"),
        "myeloid":  (14, 65, 18, 6.5, f"Myeloid Lineage\n(n={cnt(['DC','Mac','CD11C+ mac','PD-L1+ DC','PD-L1+ mac','LC'])})"),
        "mast":     (44, 65, 16, 6.5, f"Mast Cell\n(n={cnt(['Mast cell'])})"),
        "tcell":    (74, 65, 16, 6.5, f"T Cell\n(n={cnt(['Th','CTL','Treg','PD1+ CTL','Tex'])})"),
        "tumor":    (91, 65, 14, 6.5, f"S100A+ / Mel\n(n={int((strat_df['S100a_pos']==1).sum()) if 'S100a_pos' in strat_df.columns else cnt(['Mel'])})"),
        "mac":      (14, 48, 17, 6.5, f"Macrophage\n(Mac, n={cnt(['Mac'])})"),
        "lc":       (34, 48, 16, 6.5, f"Langerhans\n(LC, n={cnt(['LC'])})"),
        "th":       (62, 48, 16, 6.5, f"Helper T (Th)\n(n={cnt(['Th'])})"),
        "ctl":      (85, 48, 17, 6.5, f"Cytotoxic T (CTL)\n(n={cnt(['CTL'])})"),
        "dc":       (11, 30, 17, 7.5, f"Dendritic Cell\n(DC, n={cnt(['DC'])})"),
        "cmac":     (31, 30, 19, 7.5, f"CD11C+ Mac\n(n={cnt(['CD11C+ mac'])})"),
        "treg":     (60, 30, 17, 7.5, f"Regulatory T\n(Treg, n={cnt(['Treg'])})"),
        "pctl":     (85, 30, 18, 7.5, f"Activated CTL\n(PD1+ CTL, n={cnt(['PD1+ CTL'])})"),
        "pdc":      (11, 10, 18, 8.5, f"PD-L1+ DC\n(n={cnt(['PD-L1+ DC'])})"),
        "pmac":     (33, 10, 19, 8.5, f"PD-L1+ Mac\n(n={cnt(['PD-L1+ mac'])})"),
        "tex":      (85, 10, 18, 8.5, f"Exhausted T\n(Tex, n={cnt(['Tex'])})"),
    }

    edges = [
        ("all", "ker", "panCK+"),
        ("all", "endo", "CD31+"),
        ("all", "rest", ""),
        ("all", "mel", "SOX10+"),
        ("rest", "myeloid", "CD11c+/CD163+"),
        ("rest", "mast", "C-Kit+/CD90+"),
        ("rest", "tcell", "CD3d+"),
        ("mel", "tumor", "S100A+"),
        ("myeloid", "mac", "CD163+"),
        ("myeloid", "lc", "CD207+"),
        ("myeloid", "dc", "CD11c+ CD163-"),
        ("mac", "cmac", "CD11c+"),
        ("tcell", "th", "CD8-"),
        ("tcell", "ctl", "CD8+"),
        ("th", "treg", "FOXP3+"),
        ("ctl", "pctl", "PD1+"),
        ("dc", "pdc", "PD-L1+"),
        ("cmac", "pmac", "PD-L1+"),
        ("pctl", "tex", "TIM3+/LAG3+"),
    ]

    for u, v, elbl in edges:
        ux, uy, _, uh, _ = nodes[u]
        vx, vy, _, vh, _ = nodes[v]
        ax.annotate(
            "", xy=(vx, vy + vh * 0.5), xytext=(ux, uy - uh * 0.5),
            arrowprops=dict(arrowstyle="-|>", color="#333333", lw=0.75, mutation_scale=7),
            zorder=2,
        )
        if elbl:
            mx, my = 0.5 * (ux + vx), 0.5 * ((uy - uh * 0.5) + (vy + vh * 0.5))
            ax.text(mx, my, elbl, fontsize=4.6, ha="center", va="center", color="#222222",
                    bbox=dict(boxstyle="square,pad=0.08", facecolor="white", edgecolor="none", alpha=0.85), zorder=3)

    for nid, (cx, cy, w, h, lbl) in nodes.items():
        box = mpatches.FancyBboxPatch(
            (cx - w * 0.5, cy - h * 0.5), w, h,
            boxstyle="round,pad=0.15,rounding_size=0.6",
            facecolor="white", edgecolor="#222222", linewidth=0.75, zorder=4,
        )
        ax.add_patch(box)
        ax.text(cx, cy, lbl, fontsize=4.9, ha="center", va="center", color="#111111", zorder=5)


def main():
    parser = argparse.ArgumentParser(description="Render Supp Figure S1 Panel C (phenotyping hierarchy).")
    parser.add_argument("--paper-root", type=Path, default=DEFAULT_PAPER_ROOT)
    parser.add_argument("--out", type=Path, default=Path("sfig01_c.png"))
    args = parser.parse_args()

    strat_df = pd.read_csv(args.paper_root / "runs" / "step01_phenotype" / "stratified_phenotyped.csv")
    rules_df = pd.read_csv(args.paper_root / "runs" / "step01_phenotype" / "table_s5_panel2_rules.csv")

    fig = plt.figure(figsize=(4.20, 4.80), dpi=300, facecolor="white")
    gs = fig.add_gridspec(1, 1, left=0.05, right=0.97, top=0.95, bottom=0.03)
    draw_panel_s1c(fig, gs[0, 0], strat_df, rules_df)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out, dpi=300, facecolor="white")
    plt.close(fig)
    print(f"[sfig01_c] Saved -> {args.out}")


if __name__ == "__main__":
    main()
