"""2D KDE density contour quadrant scatter + stacked quadrant proportion bar combo (Cancer Discovery style)."""
import matplotlib.patches as mpatches
from matplotlib.gridspec import GridSpecFromSubplotSpec
import numpy as np
import seaborn as sns


def draw(fig, rect, tables, style):
    cells_df = tables["cells"]
    quad_df = tables["quadrants"]

    gs_outer = fig.add_gridspec(1, 1, left=rect[0], bottom=rect[1], right=rect[0] + rect[2], top=rect[1] + rect[3])
    sub_gs = GridSpecFromSubplotSpec(
        2, 2, subplot_spec=gs_outer[0, 0],
        height_ratios=[2.3, 0.85], width_ratios=[1.85, 0.95],
        hspace=0.28, wspace=0.20,
    )
    ax = fig.add_subplot(sub_gs[0, 0])
    ax_bar = fig.add_subplot(sub_gs[0, 1])
    ax_leg = fig.add_subplot(sub_gs[1, :])

    fig.text(
        0.5 * (ax.get_position().x0 + ax_bar.get_position().x1),
        ax.get_position().y1 + 0.025,
        style.get("title", "Cell states (CCND1 vs MART1)"), ha="center", va="bottom", fontsize=9.2,
    )

    x = cells_df["y_scaled"].to_numpy(float)
    y = cells_df["x_scaled"].to_numpy(float)

    ax.scatter(x, y, s=9.0, color="#777777", alpha=0.55, edgecolors="none", zorder=1)
    if len(cells_df) >= 10:
        sns.kdeplot(x=x, y=y, ax=ax, levels=8, color="#333333", linewidths=0.85, zorder=2)

    gx = float(style.get("gate_x", 0.5))
    gy = float(style.get("gate_y", 0.5))
    ax.axvline(gx, color="#222222", linewidth=0.9, zorder=3)
    ax.axhline(gy, color="#222222", linewidth=0.9, zorder=3)
    ax.set_xlim(-0.08, 1.08)
    ax.set_ylim(-0.08, 1.08)
    ax.set_xticks([0.0, 0.5, 1.0])
    ax.set_yticks([0.0, 0.5, 1.0])
    ax.tick_params(labelsize=7.5, length=2.5, pad=2)
    ax.set_xlabel(style.get("xlabel", "Scaled MART1 (MITF proxy)"), fontsize=8.2, labelpad=3)
    ax.set_ylabel(style.get("ylabel", "Scaled CCND1 (KI67 proxy)"), fontsize=8.2, labelpad=3)
    for sp in ax.spines.values():
        sp.set_linewidth(0.8)

    sub_q = quad_df.groupby("quadrant", as_index=False)["n_cells"].sum()
    sub_q["pct"] = sub_q["n_cells"] / max(1, sub_q["n_cells"].sum()) * 100.0
    q_map = dict(zip(sub_q["quadrant"], sub_q["pct"]))

    q_specs = [
        ("CCND1_high__MART1_low",  "#D62728", "CCND1$^{hi}$ MART1$^{lo}$"),
        ("CCND1_low__MART1_low",   "#8C3B96", "CCND1$^{lo}$ MART1$^{lo}$"),
        ("CCND1_high__MART1_high", "#A65628", "CCND1$^{hi}$ MART1$^{hi}$"),
        ("CCND1_low__MART1_high",  "#B8B8B8", "CCND1$^{lo}$ MART1$^{hi}$"),
    ]
    ax_bar.set_xlim(0, 1)
    ax_bar.set_ylim(0, 100)
    bot = 0.0
    for qkey, col, _ in q_specs:
        pct = float(q_map.get(qkey, 0.0))
        if pct > 0:
            ax_bar.bar([0.35], [pct], bottom=bot, width=0.45, color=col, edgecolor="white", lw=0.5)
            if pct >= 6.0:
                ax_bar.text(0.35, bot + pct * 0.5, f"{pct:.0f}%", ha="center", va="center", fontsize=7.2, color="white", fontweight="bold")
            bot += pct
    ax_bar.axis("off")

    ax_leg.axis("off")
    handles = [mpatches.Patch(facecolor=col, label=lbl) for _, col, lbl in reversed(q_specs)]
    ax_leg.legend(handles=handles, loc="center", ncol=2, frameon=False, fontsize=7.4, handlelength=1.0, handleheight=0.85, labelspacing=0.3)
    return ax
