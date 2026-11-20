"""Faceted multi-gene overlapping filled KDE density plots with red significance bar (Cancer Discovery style)."""
import matplotlib.patches as mpatches
from matplotlib.gridspec import GridSpecFromSubplotSpec
import numpy as np
from scipy import stats

GROUP_STYLE = {
    "MIS": ("#689892", "MIS"),
    "EM_and_IM": ("#EBE3B5", "EM and IM"),
}
FALLBACK_COLS = ["#689892", "#EBE3B5", "#D97941", "#4A6984"]


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
    groups = list(df["group"].dropna().unique())[:2]

    gs_outer = fig.add_gridspec(1, 1, left=rect[0], bottom=rect[1], right=rect[0] + rect[2], top=rect[1] + rect[3])
    sub_gs = GridSpecFromSubplotSpec(1, len(genes), subplot_spec=gs_outer[0, 0], wspace=0.26)

    bw = float(style.get("bw_method", 0.45))
    alpha = float(style.get("fill_alpha", 0.76))

    axes = []
    for idx, g in enumerate(genes):
        ax = fig.add_subplot(sub_gs[0, idx])
        axes.append(ax)
        sub = df[df["gene"] == g]
        v_list = [sub.loc[sub["group"] == grp, "log2_expr"].dropna().to_numpy(float) for grp in groups]
        all_v = np.concatenate([v for v in v_list if len(v)])
        xmin, xmax = all_v.min() - 0.8, all_v.max() + 0.8
        xs = np.linspace(xmin, xmax, 250)

        max_d = 0.0
        for gi, (grp, vals) in enumerate(zip(groups, v_list)):
            col = GROUP_STYLE.get(grp, (FALLBACK_COLS[gi % len(FALLBACK_COLS)], str(grp)))[0]
            if len(vals) >= 3 and np.std(vals) > 1e-6:
                kde = stats.gaussian_kde(vals, bw_method=bw)
                ys = kde(xs)
                ax.fill_between(xs, 0, ys, color=col, alpha=alpha, linewidth=0.6, edgecolor="#444444", zorder=2 + gi)
                max_d = max(max_d, float(ys.max()))

        if len(v_list) == 2 and len(v_list[0]) > 1 and len(v_list[1]) > 1:
            _, pv = stats.ttest_ind(v_list[0], v_list[1], equal_var=False)
            sl = _sig_label(pv)
            if sl != "ns":
                m1, m2 = np.median(v_list[0]), np.median(v_list[1])
                y_bar = max_d * 1.07
                ax.plot([m1, m2], [y_bar, y_bar], color="#C62828", lw=1.0, zorder=5)
                ax.text(0.5 * (m1 + m2), y_bar + max_d * 0.02, sl, ha="center", va="bottom",
                        fontsize=8.5, color="#C62828", fontweight="bold")

        ax.set_title(str(g), fontsize=9.0, loc="left", pad=5)
        ax.set_xlim(xmin, xmax)
        ax.set_ylim(0, max_d * 1.24 if max_d > 0 else 1.0)
        ax.set_yticks([0.0, round(max_d, 2)])
        ax.tick_params(labelsize=7.5, length=2.5, pad=2)
        ax.spines["top"].set_visible(False)
        ax.spines["right"].set_visible(False)
        ax.spines["left"].set_linewidth(0.75)
        ax.spines["bottom"].set_linewidth(0.75)

    axes[0].set_ylabel("Density", fontsize=8.8, labelpad=4)
    handles = [
        mpatches.Patch(
            facecolor=GROUP_STYLE.get(grp, (FALLBACK_COLS[i % len(FALLBACK_COLS)], str(grp)))[0],
            label=GROUP_STYLE.get(grp, (FALLBACK_COLS[i % len(FALLBACK_COLS)], str(grp)))[1],
        )
        for i, grp in enumerate(groups)
    ]
    axes[0].legend(handles=handles, loc="upper left", frameon=False, fontsize=7.5, handlelength=1.0, handleheight=0.95)
    fig.text(
        0.5 * (axes[0].get_position().x0 + axes[-1].get_position().x1),
        axes[0].get_position().y0 - 0.11,
        style.get("xlabel", "Log$_2$ expression"), ha="center", va="top", fontsize=8.8,
    )
    return axes
