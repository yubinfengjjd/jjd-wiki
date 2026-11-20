"""Ordered sample module expression curve with bottom stage color track bar (Cancer Discovery style)."""
import matplotlib.patches as mpatches
from matplotlib.gridspec import GridSpecFromSubplotSpec
import numpy as np
import pandas as pd

SITE_ORDER = ["MIS", "IR", "bTIL", "IB", "IM", "EM"]
SITE_COLORS = {
    "MIS": "#1E9C78",
    "IR": "#B86646",
    "bTIL": "#C84B93",
    "IB": "#85A933",
    "IM": "#C69032",
    "EM": "#666666",
}
FALLBACK_COLS = ["#1E9C78", "#B86646", "#C84B93", "#85A933", "#C69032", "#666666"]


def draw(fig, rect, tables, style):
    df = tables["curve"].copy()
    avail_sites = [s for s in SITE_ORDER if s in df["site"].values]
    for s in df["site"].dropna().unique():
        if s not in avail_sites:
            avail_sites.append(s)

    df["site_cat"] = pd.Categorical(df["site"], categories=avail_sites, ordered=True)
    df = df.sort_values(["site_cat", "sample_id"]).reset_index(drop=True)

    gs_outer = fig.add_gridspec(1, 1, left=rect[0], bottom=rect[1], right=rect[0] + rect[2], top=rect[1] + rect[3])
    sub_gs = GridSpecFromSubplotSpec(2, 1, subplot_spec=gs_outer[0, 0], height_ratios=[1.0, 0.09], hspace=0.05)
    ax_line = fig.add_subplot(sub_gs[0, 0])
    ax_bar = fig.add_subplot(sub_gs[1, 0])

    x = np.arange(len(df))
    y = df["mean_log2_norm"].to_numpy(float)
    pt_sz = float(style.get("point_size", 9.0))
    ax_line.plot(x, y, color="#111111", linewidth=0.9, zorder=2)
    ax_line.scatter(x, y, s=pt_sz, color="#111111", zorder=3)

    ax_line.set_xlim(-1, len(df))
    ax_line.set_ylim(0, max(y.max() * 1.14, 8.2))
    ax_line.set_ylabel(style.get("ylabel", "Mean expression (log$_2$)
S100B module"), fontsize=8.5, labelpad=4)
    ax_line.set_xticks([])
    ax_line.tick_params(axis="y", labelsize=7.8, length=3, pad=2)
    for sp in ax_line.spines.values():
        sp.set_linewidth(0.8)
        sp.set_color("#222222")

    handles = [
        mpatches.Patch(facecolor=SITE_COLORS.get(s, FALLBACK_COLS[i % len(FALLBACK_COLS)]), label=s)
        for i, s in enumerate(avail_sites)
    ]
    ax_line.legend(
        handles=handles, loc="upper left", bbox_to_anchor=(0.02, 0.98),
        frameon=False, fontsize=7.5, handlelength=1.0, handleheight=1.0, labelspacing=0.3,
    )

    ax_bar.set_xlim(-1, len(df))
    ax_bar.set_ylim(0, 1)
    for i, st in enumerate(df["site"]):
        col = SITE_COLORS.get(st, "#666666")
        ax_bar.add_patch(mpatches.Rectangle((i - 0.5, 0), 1.0, 1.0, facecolor=col, edgecolor="none"))
    ax_bar.set_xlabel(style.get("xlabel", "mROI"), fontsize=8.5, labelpad=4)
    ax_bar.set_xticks([])
    ax_bar.set_yticks([])
    for sp in ax_bar.spines.values():
        sp.set_visible(False)
    return ax_line
