"""Mirrored half-violin + IQR box + red decile shift dumbbell plot across two groups."""
from matplotlib.gridspec import GridSpecFromSubplotSpec
import numpy as np
from scipy import stats


def _draw_one(ax, d_top, d_bot, title, top_lbl, bot_lbl, show_lbls):
    rng = np.random.default_rng(42)
    all_v = np.concatenate([d_top, d_bot])
    xmin = max(1.0, float(np.min(all_v)) * 0.85)
    xmax = float(np.max(all_v)) * 1.15
    xs = np.linspace(xmin, xmax, 250)

    def half_violin(vals, y_base, direction, col_fill):
        if len(vals) < 2:
            return
        kde = stats.gaussian_kde(vals, bw_method=0.60)
        dens = kde(xs)
        if dens.max() > 0:
            dens = dens / dens.max() * 0.36
        ax.fill_between(xs, y_base, y_base + direction * dens, facecolor=col_fill, edgecolor="#222222", lw=0.6, alpha=0.88, zorder=2)
        jit = rng.uniform(0.03, 0.11, size=len(vals))
        ax.scatter(vals, y_base - direction * jit, s=5.0, color=col_fill, alpha=0.72, edgecolors="none", zorder=1)
        q25, q50, q75 = np.percentile(vals, [25, 50, 75])
        ax.plot([vals.min(), vals.max()], [y_base, y_base], color="#222222", lw=0.8, zorder=3)
        ax.plot([q25, q75], [y_base, y_base], color="#1A1A1A", lw=5.5, solid_capstyle="butt", zorder=4)
        ax.scatter([q50], [y_base], s=18, facecolor="white", edgecolor="#1A1A1A", lw=0.7, zorder=5)

    y_top, y_bot = 0.78, -0.78
    half_violin(d_top, y_top, +1.0, "#62A9D8")
    half_violin(d_bot, y_bot, -1.0, "#B8B8B8")

    deciles = [10, 20, 30, 40, 50, 60, 70, 80, 90]
    if len(d_top) >= 2 and len(d_bot) >= 2:
        qn_arr = np.percentile(d_top, deciles)
        qp_arr = np.percentile(d_bot, deciles)
        y1, y2 = y_top - 0.14, y_bot + 0.14
        for qn, qp in zip(qn_arr, qp_arr):
            ax.plot([qn, qp], [y1, y2], color="#C83737", lw=0.85, alpha=0.92, zorder=4)
        ax.scatter(qn_arr, np.full_like(qn_arr, y1), s=13, color="#C83737", edgecolors="#222222", lw=0.4, zorder=6)
        ax.scatter(qp_arr, np.full_like(qp_arr, y2), s=13, color="#C83737", edgecolors="#222222", lw=0.4, zorder=6)

    ax.set_xscale("log")
    ax.set_xlim(xmin * 0.85, xmax * 1.15)
    ax.set_ylim(-1.28, 1.32)
    x_min_t = int(round(xmin))
    x_max_t = int(round(xmax))
    med_b = int(round(np.median(d_bot))) if len(d_bot) else x_max_t
    if x_max_t / max(med_b, 1) >= 2.2 and med_b / max(x_min_t, 1) >= 2.2:
        ticks = [x_min_t, med_b, x_max_t]
    else:
        ticks = [x_min_t, x_max_t]
    ax.set_xticks(ticks)
    ax.set_xticklabels([f"{t:,}" for t in ticks], fontsize=7.2)
    ax.set_yticks([])
    ax.set_title(title, fontsize=8.4, pad=5)
    if show_lbls:
        ax.text(0.02, 0.88, top_lbl, transform=ax.transAxes, fontsize=7.4, ha="left", va="bottom", color="#222222")
        ax.text(0.02, 0.04, bot_lbl, transform=ax.transAxes, fontsize=7.4, ha="left", va="bottom", color="#222222")
    for sp in ax.spines.values():
        sp.set_visible(False)
    ax.spines["bottom"].set_visible(True)
    ax.spines["bottom"].set_linewidth(0.8)


def draw(fig, rect, tables, style):
    df = tables["distances"]
    panels = list(dict.fromkeys(df["panel"].astype(str).tolist()))
    top_grp = style.get("top_group", "Normal")
    bot_grp = style.get("bottom_group", "Precursor")
    xlab = style.get("xlabel", "Distance from melanocytes (um)")

    gs_outer = fig.add_gridspec(1, 1, left=rect[0], bottom=rect[1], right=rect[0] + rect[2], top=rect[1] + rect[3])
    sub_gs = GridSpecFromSubplotSpec(1, len(panels), subplot_spec=gs_outer[0, 0], wspace=0.18)

    axes = []
    for idx, pname in enumerate(panels):
        ax = fig.add_subplot(sub_gs[0, idx])
        axes.append(ax)
        sub = df[df["panel"].astype(str) == pname]
        d1 = sub.loc[sub["group"].astype(str) == top_grp, "value"].to_numpy(float)
        d2 = sub.loc[sub["group"].astype(str) == bot_grp, "value"].to_numpy(float)
        _draw_one(ax, d1, d2, pname, top_grp, bot_grp, show_lbls=(idx == 0))

    fig.text(
        0.5 * (axes[0].get_position().x0 + axes[-1].get_position().x1),
        axes[0].get_position().y0 - 0.11,
        xlab, ha="center", va="top", fontsize=8.5, color="#111111",
    )
    return axes
