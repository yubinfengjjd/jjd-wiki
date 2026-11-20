#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Main Figure 2 (1:1 Scientific Visual Replica of Nirmal et al., Cancer Discovery 2022, 1518fig2.jpg).
Composes standalone panel modules fig02_a..fig02_e into the 7.20 in x 9.24 in (W/H=0.779) plate.
"""

import gc
from pathlib import Path
import sys

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec, GridSpecFromSubplotSpec
import pandas as pd

SRC_FIGURES = Path(__file__).resolve().parent
sys.path.insert(0, str(SRC_FIGURES.parent / "panels"))

from _fig_common import DEFAULT_PAPER_ROOT, save_replica_and_compare
from fig02_a import densify_umap_cloud, draw_panel_2a, map_16_to_12_2a
from fig02_b import draw_panel_2b
from fig02_c import draw_panel_2c
from fig02_d import draw_panel_2d
from fig02_e import draw_panel_2e

plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["svg.fonttype"] = "none"
plt.rcParams["pdf.fonttype"] = 42


def main():
    root = DEFAULT_PAPER_ROOT
    runs = root / "runs"

    umap_df = pd.read_csv(runs / "step02_umap_gradients" / "umap_coords_markers.csv")
    s100a_roi = pd.read_csv(runs / "step02_umap_gradients" / "fig2c_s100a_by_roi_stage.csv")
    s100a_tests = pd.read_csv(runs / "step02_umap_gradients" / "fig2c_s100a_stage_ttests.csv")
    fov_df = pd.read_csv(runs / "step03_rcn_lda" / "fov_cells_with_rcn.csv")
    lda30_df = pd.read_csv(runs / "step03_rcn_lda" / "lda_cluster30_composition.csv")
    rcn_comp_df = pd.read_csv(runs / "step03_rcn_lda" / "fig2d_rcn_phenotype_composition.csv")
    pie_df = pd.read_csv(runs / "step03_rcn_lda" / "fig2e_rcn_simplified_pie.csv")

    umap_df["cell_type_12"] = map_16_to_12_2a(umap_df)
    umap_dense = densify_umap_cloud(umap_df, target_n=20000, seed=42)

    # Exact aspect ratio of 1518fig2.jpg: 720 x 924 -> W/H = 0.7792 (7.20 in x 9.24 in)
    fig = plt.figure(figsize=(7.20, 9.24), dpi=300, facecolor="white")
    main_gs = GridSpec(
        3, 1,
        figure=fig,
        height_ratios=[1.82, 1.15, 5.20],
        hspace=0.26,
        left=0.070, right=0.955, top=0.965, bottom=0.025,
    )

    # Row 0: Panel 2A
    draw_panel_2a(fig, main_gs[0, 0], umap_dense)

    # Row 1: Panel 2B (left) & 2C (right)
    row1_gs = GridSpecFromSubplotSpec(1, 2, subplot_spec=main_gs[1, 0], width_ratios=[3.6, 1.05], wspace=0.22)
    draw_panel_2b(fig, row1_gs[0, 0], umap_dense)
    draw_panel_2c(fig, row1_gs[0, 1], s100a_roi, s100a_tests)

    # Row 2: Panel 2D (left) & Panel 2E (right)
    row2_gs = GridSpecFromSubplotSpec(1, 2, subplot_spec=main_gs[2, 0], width_ratios=[1.12, 1.0], wspace=0.22)
    draw_panel_2d(fig, row2_gs[0, 0], fov_df, lda30_df)
    draw_panel_2e(fig, row2_gs[0, 1], rcn_comp_df, pie_df)

    panel_boxes = {
        "A": (0.00, 0.00, 1.00, 0.25),
        "B": (0.00, 0.23, 0.75, 0.40),
        "C": (0.72, 0.22, 1.00, 0.40),
        "D": (0.00, 0.38, 0.56, 1.00),
        "E": (0.54, 0.38, 1.00, 1.00),
    }
    out_png, out_cmp = save_replica_and_compare(
        fig, root, "fig02", "1518fig2.jpg", panel_boxes_frac=panel_boxes
    )
    plt.close(fig)

    del umap_df, umap_dense, fov_df
    gc.collect()
    print(f"[fig02] Done -> {out_png} | compare -> {out_cmp}")


if __name__ == "__main__":
    main()
