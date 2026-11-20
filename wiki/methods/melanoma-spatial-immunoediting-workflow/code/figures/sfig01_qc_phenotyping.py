#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Supplementary Figure S1 (1:1 Layout Replica of supp_..._p01.png).
Composes quantitative hierarchical phenotyping tree S1C (Table S5 gates + local counts),
marks S1A/B/D/E/F/G/I as excluded_imaging and S1H as unavailable_pixel_linescan.
Target size: 7.20 in x 9.32 in (W/H=0.7725 vs orig 0.7727).
"""

import gc
from pathlib import Path
import sys

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.gridspec import GridSpec, GridSpecFromSubplotSpec
from PIL import Image
import pandas as pd

SRC_FIGURES = Path(__file__).resolve().parent
sys.path.insert(0, str(SRC_FIGURES.parent / "panels"))

from _fig_common import DEFAULT_PAPER_ROOT
from sfig01_c import draw_panel_s1c

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["pdf.fonttype"] = 42


def _draw_excluded(fig, gs_slot, letter: str, text: str, lx: float = -0.04, ly: float = 1.04):
    ax = fig.add_subplot(gs_slot)
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axis("off")
    if letter:
        ax.text(lx, ly, letter, transform=ax.transAxes, fontsize=11, fontweight="bold", va="top", ha="left")
    ax.add_patch(mpatches.FancyBboxPatch(
        (0.02, 0.03), 0.96, 0.94,
        boxstyle="round,pad=0.02,rounding_size=0.02",
        facecolor="#F7F7F7", edgecolor="#999999", linestyle="--", linewidth=0.8,
    ))
    ax.text(0.50, 0.50, text, ha="center", va="center", fontsize=5.8, color="#555555")


def save_supp_compare(fig, root: Path, slug: str, orig_rel: str, panel_boxes: dict):
    review = root / "review"
    figures = review / "figures"
    panels = review / "panels"
    compare = review / "compare"
    for d in (review, figures, panels, compare):
        d.mkdir(parents=True, exist_ok=True)
    out_png = figures / f"{slug}_replica.png"
    out_pdf = figures / f"{slug}_replica.pdf"
    fig.savefig(out_png, dpi=300, facecolor="white")
    fig.savefig(out_pdf, dpi=300, facecolor="white")
    fig.savefig(review / f"{slug}_replica.png", dpi=300, facecolor="white")
    fig.savefig(review / f"{slug}_replica.pdf", dpi=300, facecolor="white")

    rep_img = Image.open(out_png).convert("RGB")
    w, h = rep_img.size
    for pn, (x0, y0, x1, y1) in panel_boxes.items():
        rep_img.crop((int(w * x0), int(h * y0), int(w * x1), int(h * y1))).save(panels / f"{slug}_panel{pn}.png")

    orig_img = Image.open(root / orig_rel).convert("RGB")
    th = 1150
    ow = int(round(orig_img.width * (th / orig_img.height)))
    rw = int(round(rep_img.width * (th / rep_img.height)))
    canvas = Image.new("RGB", (ow + 24 + rw, th), (255, 255, 255))
    canvas.paste(orig_img.resize((ow, th), Image.Resampling.LANCZOS), (0, 0))
    canvas.paste(rep_img.resize((rw, th), Image.Resampling.LANCZOS), (ow + 24, 0))
    out_cmp = compare / f"{slug}_side_by_side.png"
    canvas.save(out_cmp, format="PNG", optimize=True)
    return out_png, out_cmp


def main():
    root = DEFAULT_PAPER_ROOT
    strat_df = pd.read_csv(root / "runs" / "step01_phenotype" / "stratified_phenotyped.csv")
    rules_df = pd.read_csv(root / "runs" / "step01_phenotype" / "table_s5_panel2_rules.csv")

    fig = plt.figure(figsize=(7.20, 9.32), dpi=300, facecolor="white")
    main_gs = GridSpec(
        2, 1, figure=fig, height_ratios=[3.6, 1.0], hspace=0.14,
        left=0.05, right=0.965, top=0.96, bottom=0.035,
    )

    # Top: S1A (left) | S1C (top-right) + S1D/E/F/G (mid-right)
    top_gs = GridSpecFromSubplotSpec(1, 2, subplot_spec=main_gs[0, 0], width_ratios=[1.0, 1.05], wspace=0.10)
    _draw_excluded(fig, top_gs[0, 0], "A", "S1A: Whole-slide H&E & 5-plex CyCIF\n(Normal skin, Precursor, MIS-IR, EM, IB)\n\n[Excluded per imaging policy (excluded_imaging)]")

    right_gs = GridSpecFromSubplotSpec(2, 1, subplot_spec=top_gs[0, 1], height_ratios=[1.25, 1.0], hspace=0.12)
    draw_panel_s1c(fig, right_gs[0, 0], strat_df, rules_df)
    _draw_excluded(fig, right_gs[1, 0], "D–G", "S1D–S1G: High-res CyCIF microscopy\n(S1D region overview; S1E–G synapse/FOXP3/TIM3)\n\n[Excluded per imaging policy (excluded_imaging)]")

    # Bottom: S1B (left) | S1H (unavailable_pixel_linescan) | S1I (excluded)
    bot_gs = GridSpecFromSubplotSpec(1, 3, subplot_spec=main_gs[1, 0], width_ratios=[1.1, 0.75, 1.65], wspace=0.12)
    _draw_excluded(fig, bot_gs[0, 0], "B", "S1B: S100A/NGFR/MITF\nCyCIF [Excluded imaging]")
    _draw_excluded(fig, bot_gs[0, 1], "H", "S1H: 60× 3D synapse\n0–16 μm pixel line-scan\nnot in S3 CSVs\n[unavailable_pixel_linescan]")
    _draw_excluded(fig, bot_gs[0, 2], "I", "S1I: 3D Z-stack Treg–tumor CyCIF\n[Excluded per imaging policy]")

    out_png, out_cmp = save_supp_compare(
        fig, root, "sfig01",
        "extracted/pages/supp_cd-21-1357-supplementary-figures-s1-s7-suppsf1-sf7_p01.png",
        {"C": (0.48, 0.00, 1.00, 0.45)},
    )
    plt.close(fig)
    del strat_df, rules_df
    gc.collect()
    print(f"[sfig01] Done -> {out_png} | compare -> {out_cmp}")


if __name__ == "__main__":
    main()
