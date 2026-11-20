"""Spatial single-cell binary highlight scatter grid with side group tracks (Cancer Discovery style)."""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.gridspec import GridSpecFromSubplotSpec


def draw(fig, rect, tables, style):
    d5d = tables["highlights"]
    fov_df = tables["background"]

    pref_order = ["TCC1", "TCC2", "TCC5", "TCC6", "TCC7", "TCC8", "TCC9", "TCC10", "TCC3", "TCC4"]
    avail = [t for t in pref_order if t in d5d["TCC"].values]
    for t in d5d["TCC"].unique():
        if t not in avail:
            avail.append(t)
    avail = avail[:10]

    gs_outer = fig.add_gridspec(1, 1, left=rect[0], bottom=rect[1], right=rect[0] + rect[2], top=rect[1] + rect[3])
    sub_gs = GridSpecFromSubplotSpec(
        6, 3, subplot_spec=gs_outer[0, 0],
        height_ratios=[1.0, 1.0, 1.0, 1.0, 1.0, 0.28],
        width_ratios=[1.0, 1.0, 0.16],
        hspace=0.24, wspace=0.10,
    )

    bg_col = style.get("bg_color", "#D8D8D8")
    fg_col = style.get("fg_color", "#194B5F")
    bg_sz = float(style.get("bg_size", 3.0))
    fg_sz = float(style.get("fg_size", 11.0))

    axes = []
    for idx, tname in enumerate(avail):
        r, c = divmod(idx, 2)
        ax = fig.add_subplot(sub_gs[r, c])
        axes.append(ax)
        sub_t = d5d[d5d["TCC"] == tname]
        fov_id = sub_t["fov_id"].value_counts().index[0] if not sub_t.empty else fov_df["fov_id"].iloc[0]
        bg = fov_df[fov_df["fov_id"] == fov_id]
        ymax = bg["Y_um"].max() if not bg.empty else 1.0

        ax.scatter(bg["X_um"], ymax - bg["Y_um"], s=bg_sz, color=bg_col, edgecolors="none", rasterized=True, zorder=1)
        fg = sub_t[sub_t["fov_id"] == fov_id]
        if not fg.empty:
            ax.scatter(fg["X_um"], ymax - fg["Y_um"], s=fg_sz, color=fg_col, edgecolors="none", zorder=3)

        ax.set_title(tname, fontsize=7.8, loc="left", pad=2)
        st_tag = str(bg["Stage"].iloc[0]) if (not bg.empty and "Stage" in bg.columns) else ""
        ax.text(0.96, 0.06, st_tag, transform=ax.transAxes, ha="right", va="bottom", fontsize=6.0, color="#666666")
        ax.set_xticks([])
        ax.set_yticks([])
        for sp in ax.spines.values():
            sp.set_visible(False)

    if len(axes) >= 2:
        fig.text(
            0.5 * (axes[0].get_position().x0 + axes[1].get_position().x1),
            axes[0].get_position().y1 + 0.025,
            style.get("title", "Mapping of TCCs to physical location"),
            ha="center", va="bottom", fontsize=9.2,
        )

    ax_non = fig.add_subplot(sub_gs[0:4, 2])
    ax_non.axis("off")
    ax_non.add_patch(mpatches.Rectangle((0.12, 0.01), 0.76, 0.98, facecolor="#F5F3BE", edgecolor="none"))
    ax_non.text(0.50, 0.50, "Immune noninteracting", rotation=270, ha="center", va="center", fontsize=7.2, color="#222222")

    ax_int = fig.add_subplot(sub_gs[4, 2])
    ax_int.axis("off")
    ax_int.add_patch(mpatches.Rectangle((0.12, 0.02), 0.76, 0.96, facecolor="#EAE342", edgecolor="none"))
    ax_int.text(0.50, 0.50, "Immune\ninteracting", rotation=270, ha="center", va="center", fontsize=6.6, color="#222222")

    if len(axes) >= 9:
        p3 = axes[6].get_position()
        p4 = axes[8].get_position()
        y_sep = 0.5 * (p3.y0 + p4.y1)
        fig.add_artist(plt.Line2D([p3.x0, axes[1].get_position().x1], [y_sep, y_sep], color="#666666", linestyle="--", lw=0.85))

    ax_leg = fig.add_subplot(sub_gs[5, :2])
    ax_leg.axis("off")
    handles = [
        mpatches.Patch(facecolor=bg_col, label="All cells"),
        mpatches.Patch(facecolor=fg_col, label="Cells within TCC"),
    ]
    ax_leg.legend(handles=handles, loc="center", ncol=2, frameon=False, fontsize=7.5, handlelength=1.0, handleheight=0.85)
    return axes
