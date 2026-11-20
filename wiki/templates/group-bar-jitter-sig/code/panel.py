"""Faceted multi-gene mean +/- SEM barplot with jittered dots and red significance brackets (Cancer Discovery style)."""
import math
import matplotlib.patches as mpatches
from matplotlib.gridspec import GridSpecFromSubplotSpec
import numpy as np
from scipy import stats

GRP_COLORS = {
    "MIS": "#689892",
    "Immune": "#EB582B",
    "Tumor": "#EBE3B5",
    "IM": "#C87A53",
    "EM": "#666666",
    "bTIL": "#C84B93",
    "IB": "#85A933",
}
FALLBACK_COLS = ["#689892", "#EB582B", "#EBE3B5", "#C84B93", "#85A933"]


def _sig_label(p):
    if not np.isfinite(p):
        return "ns"
    if p < 0.001:
        return "***"
    if p < 0.01:
        return "**"
    if p < 0.05:
        return "*"
    return "ns"


def draw(fig, rect, tables, style):
    df = tables["expr"]
    genes = list(df["gene"].dropna().unique())
    pref_groups = ["MIS", "Immune", "Tumor", "IM", "EM", "bTIL", "IB"]
    groups = [g for g in pref_groups if g in df["group"].values]
    for g in df["group"].dropna().unique():
        if g not in groups:
            groups.append(g)

    ncol = int(style.get("ncol", 3))
    n_slots = len(genes) + 1
    nrow = max(1, math.ceil(n_slots / ncol))

    gs_outer = fig.add_gridspec(1, 1, left=rect[0], bottom=rect[1], right=rect[0] + rect[2], top=rect[1] + rect[3])
    sub_gs = GridSpecFromSubplotSpec(nrow, ncol, subplot_spec=gs_outer[0, 0], hspace=0.45, wspace=0.32)
    rng = np.random.default_rng(42)
    pt_size = float(style.get("point_size", 6.0))

    axes = []
    for idx, gene in enumerate(genes):
        r, c = divmod(idx, ncol)
        ax = fig.add_subplot(sub_gs[r, c])
        axes.append(ax)
        sub = df[df["gene"] == gene]

        means, sems, vals_list = [], [], []
        for g in groups:
            v = sub.loc[sub["group"] == g, "log2_expr"].dropna().to_numpy(float)
            vals_list.append(v)
            means.append(np.mean(v) if len(v) else 0.0)
            sems.append(stats.sem(v) if len(v) > 1 else 0.0)

        x_pos = np.arange(len(groups))
        cols = [GRP_COLORS.get(g, FALLBACK_COLS[i % len(FALLBACK_COLS)]) for i, g in enumerate(groups)]
        ax.bar(x_pos, means, width=0.68, color=cols, edgecolor="#333333", linewidth=0.3, zorder=2)
        ax.errorbar(
            x_pos, means, yerr=sems, fmt="none", ecolor="#222222",
            elinewidth=0.85, capsize=2.4, capthick=0.85, zorder=4,
        )
        for xi, v in enumerate(vals_list):
            if len(v):
                jit = rng.uniform(-0.18, 0.18, size=len(v))
                ax.scatter(np.full(len(v), xi) + jit, v, s=pt_size, color="#2A3240", alpha=0.78, zorder=3)

        ymax_pts = max([np.max(v) if len(v) else 0 for v in vals_list] + [1.0])
        if len(groups) >= 3:
            _, p01 = stats.ttest_ind(vals_list[0], vals_list[1], equal_var=False)
            _, p12 = stats.ttest_ind(vals_list[1], vals_list[2], equal_var=False)
            _, p02 = stats.ttest_ind(vals_list[0], vals_list[2], equal_var=False)
            pairs = [(0, 1, p01, ymax_pts * 1.04), (1, 2, p12, ymax_pts * 1.04), (0, 2, p02, ymax_pts * 1.16)]
        elif len(groups) == 2:
            _, p01 = stats.ttest_ind(vals_list[0], vals_list[1], equal_var=False)
            pairs = [(0, 1, p01, ymax_pts * 1.06)]
        else:
            pairs = []

        for xa, xb, pv, y_lvl in pairs:
            sl = _sig_label(pv)
            col_sig = "#C62828" if sl != "ns" else "#444444"
            ax.plot([xa, xb], [y_lvl, y_lvl], color=col_sig, lw=0.85)
            ax.text(
                0.5 * (xa + xb), y_lvl + ymax_pts * 0.012, sl, ha="center", va="bottom",
                fontsize=7.6 if sl != "ns" else 6.8, color=col_sig,
                fontweight="bold" if sl != "ns" else "normal",
            )

        ax.set_title(str(gene), fontsize=8.8, pad=4)
        ax.set_ylim(0, ymax_pts * 1.30)
        ax.set_xticks([])
        ax.tick_params(axis="y", labelsize=7.2, length=2.5, pad=2)
        ax.spines["top"].set_visible(False)
        ax.spines["right"].set_visible(False)
        ax.spines["left"].set_linewidth(0.75)
        ax.spines["bottom"].set_linewidth(0.75)

    fig.text(
        axes[0].get_position().x0 - 0.06,
        0.5 * (axes[-1].get_position().y0 + axes[0].get_position().y1),
        style.get("ylabel", "Expression (log$_2$)"), rotation=90, va="center", ha="center", fontsize=8.8,
    )

    r_leg, c_leg = divmod(len(genes), ncol)
    ax_leg = fig.add_subplot(sub_gs[r_leg, c_leg])
    ax_leg.axis("off")
    handles = [
        mpatches.Patch(facecolor=GRP_COLORS.get(g, FALLBACK_COLS[i % len(FALLBACK_COLS)]), edgecolor="#333333", linewidth=0.3, label=g)
        for i, g in enumerate(groups)
    ]
    ax_leg.legend(handles=handles, loc="center left", frameon=False, fontsize=8.2, handlelength=1.2, handleheight=1.1, labelspacing=0.5)
    return axes
