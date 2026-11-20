"""PCA variance ratio scree plot + PC1/PC2 ranked feature loadings panel (Cancer Discovery style)."""
from matplotlib.gridspec import GridSpecFromSubplotSpec
import numpy as np


def draw(fig, rect, tables, style):
    scree_df = tables["scree"]
    load_df = tables["loadings"]

    gs_outer = fig.add_gridspec(1, 1, left=rect[0], bottom=rect[1], right=rect[0] + rect[2], top=rect[1] + rect[3])
    sub_gs = GridSpecFromSubplotSpec(2, 2, subplot_spec=gs_outer[0, 0], width_ratios=[1.05, 1.2], hspace=0.16, wspace=0.28)
    ax_sc = fig.add_subplot(sub_gs[:, 0])
    ax_p1 = fig.add_subplot(sub_gs[0, 1])
    ax_p2 = fig.add_subplot(sub_gs[1, 1])

    x = scree_df["pc_num"].to_numpy(float)
    y = scree_df["explained_variance_ratio"].to_numpy(float)
    ax_sc.plot(
        x, y, marker="s", markersize=4.5, markerfacecolor="white",
        markeredgecolor="#333333", color="#333333", linewidth=0.9,
    )
    for xi, yi, pc in zip(x[:10], y[:10], scree_df["PC"].iloc[:10]):
        x_off = xi + 0.24 if int(round(xi)) == 2 else xi
        ax_sc.text(x_off, yi + 0.015, str(pc), rotation=90, fontsize=6.4, ha="center", va="bottom", color="#222222")
    ax_sc.text(0.95, 0.94, "Variance ratio", transform=ax_sc.transAxes, ha="right", va="top", fontsize=8.5)
    ax_sc.set_xlabel("ranking by PC", fontsize=8.2, labelpad=4)
    ax_sc.set_ylim(0, max(y.max() * 1.24, 0.25))
    ax_sc.tick_params(labelsize=7.5, length=2.5, pad=2)
    for sp in ax_sc.spines.values():
        sp.set_linewidth(0.8)

    top_hi = int(style.get("top_highlight_n", 2))
    max_lbl = int(style.get("max_labeled_features", 18))
    for ax_p, col_name, lbl in [(ax_p1, "abs_PC1", "PC1"), (ax_p2, "abs_PC2", "PC2")]:
        sub = load_df.sort_values(col_name, ascending=False).reset_index(drop=True)
        n_m = len(sub)
        xs = np.arange(n_m)
        ys = sub[col_name].to_numpy(float)
        ax_p.scatter(xs, ys, s=8.0, color="#666666", zorder=2)
        for i in range(min(max_lbl, n_m)):
            col_t = "#C62828" if i < top_hi else "#333333"
            fw = "bold" if i < top_hi else "normal"
            ax_p.text(i, ys[i] + 0.016, str(sub.loc[i, "marker"]), rotation=90, fontsize=5.3, fontweight=fw, ha="center", va="bottom", color=col_t)
        ax_p.text(0.96, 0.92, lbl, transform=ax_p.transAxes, ha="right", va="top", fontsize=8.5)
        ax_p.set_ylim(-0.02, ys.max() * 1.68)
        ax_p.set_xticks([])
        ax_p.tick_params(axis="y", labelsize=7.2, length=2.5, pad=2)
        for sp in ax_p.spines.values():
            sp.set_linewidth(0.75)
    ax_p2.set_xlabel("ranking by feature", fontsize=8.2, labelpad=4)
    return [ax_sc, ax_p1, ax_p2]
