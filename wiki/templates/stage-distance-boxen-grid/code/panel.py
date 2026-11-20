"""Multi-stage log-scale horizontal boxenplot of spatial distances (Cancer Discovery style)."""
from matplotlib.gridspec import GridSpecFromSubplotSpec
import numpy as np
import seaborn as sns

RCN_COLORS = {
    "RCN1": "#EBB39A",
    "RCN2": "#2D9A93",
    "RCN3": "#52B87A",
    "RCN4": "#C3DEC0",
    "RCN5": "#EFE738",
    "RCN6": "#4FC4EA",
    "RCN7": "#5692BC",
    "RCN8": "#F29954",
    "RCN9": "#EB2629",
    "RCN10": "#C7C7C7",
}


def draw(fig, rect, tables, style):
    dist_df = tables["distances"]
    ttest_df = tables.get("ttests")

    rcn_order = ["RCN2", "RCN3", "RCN4", "RCN5", "RCN8", "RCN6", "RCN7"]
    rcn_short = [r.replace("RCN", "") for r in rcn_order]
    palette = {r: RCN_COLORS.get(r, "#5692BC") for r in rcn_order}

    stages = [
        ("Normal", "Normal", None),
        ("Precursor", "Precursor", ("Normal", "Precursor", "N vs. P")),
        ("MIS", "MIS", ("Normal", "MIS", "N vs. MIS")),
        ("IM", "IM", ("MIS", "IM", "MIS vs. IM")),
    ]

    gs_outer = fig.add_gridspec(1, 1, left=rect[0], bottom=rect[1], right=rect[0] + rect[2], top=rect[1] + rect[3])
    sub_gs = GridSpecFromSubplotSpec(1, 4, subplot_spec=gs_outer[0, 0], wspace=0.14)
    ref_lines = style.get("ref_lines", [6, 90, 1000])

    axes = []
    for idx, (st_key, st_title, comp_info) in enumerate(stages):
        ax = fig.add_subplot(sub_gs[0, idx])
        axes.append(ax)
        sub = dist_df[(dist_df["Stage"] == st_key) & (dist_df["RCN"].isin(rcn_order))].copy()
        sub["dist_plot"] = np.clip(sub["dist_to_RCN10_um"].to_numpy(float), 5.0, 2000.0)

        for rx in ref_lines:
            ax.axvline(rx, color="#999999", linestyle="--", linewidth=0.7, zorder=1)

        if not sub.empty:
            sns.boxenplot(
                data=sub, x="dist_plot", y="RCN", hue="RCN", order=rcn_order,
                palette=palette, legend=False, orient="h", ax=ax, linewidth=0.55,
                flier_kws=dict(marker="d", s=2.5, color="#444444", alpha=0.75), zorder=3,
            )

        ax.set_xscale("log")
        ax.set_xlim(4.0, 1800.0)
        ax.set_xticks([6, 90, 1000])
        ax.set_xticklabels(["6", "90", "1,000"], fontsize=7.2)
        ax.set_title(st_title, fontsize=8.5, pad=6)
        ax.set_xlabel("")
        ax.set_ylabel("")
        ax.set_yticks(np.arange(len(rcn_order)))
        if idx == 0:
            ax.set_yticklabels(rcn_short, fontsize=7.8)
            ax.set_ylabel("RCN", fontsize=8.5, labelpad=4)
        else:
            ax.set_yticklabels([])
            ax.tick_params(axis="y", length=0)

        if comp_info is not None and ttest_df is not None:
            s1, s2, clbl = comp_info
            ax.text(1.02, 1.03, clbl, transform=ax.transAxes, ha="right", va="bottom", fontsize=7.0, color="#E31A1C")
            for r_i, r_name in enumerate(rcn_order):
                row_t = ttest_df[(ttest_df["RCN"] == r_name) & (ttest_df["stage_1"] == s1) & (ttest_df["stage_2"] == s2)]
                if not row_t.empty and np.isfinite(row_t["p_value"].iloc[0]) and row_t["p_value"].iloc[0] < 0.05:
                    ax.text(1700.0, r_i, "*", ha="left", va="center", fontsize=9.0, color="#E31A1C", fontweight="bold", clip_on=False)

        ax.spines["top"].set_visible(False)
        ax.spines["right"].set_visible(False)
        ax.spines["left"].set_linewidth(0.75)
        ax.spines["bottom"].set_linewidth(0.75)

    fig.text(
        0.5 * (axes[0].get_position().x0 + axes[-1].get_position().x1),
        axes[0].get_position().y0 - 0.11,
        style.get("xlabel", "Distance from RCN10 (μm)"), ha="center", va="top", fontsize=8.5,
    )
    return axes
