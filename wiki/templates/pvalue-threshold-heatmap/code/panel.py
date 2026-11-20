"""Pairwise stage comparison p-value threshold numeric heatmap (Cancer Discovery style)."""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.colors import LinearSegmentedColormap, Normalize
from matplotlib.gridspec import GridSpecFromSubplotSpec
import numpy as np

COMP_LABELS = {
    "Normal_vs_Precursor": "N v P",
    "Precursor_vs_MIS": "P v MIS",
    "Precursor_vs_IM": "P v IM",
    "MIS_vs_IM": "MIS v IM",
}


def draw(fig, rect, tables, style):
    pval_df = tables["pvalues"]
    gs_outer = fig.add_gridspec(1, 1, left=rect[0], bottom=rect[1], right=rect[0] + rect[2], top=rect[1] + rect[3])
    sub_gs = GridSpecFromSubplotSpec(2, 1, subplot_spec=gs_outer[0, 0], height_ratios=[5.2, 0.65], hspace=0.08)
    ax = fig.add_subplot(sub_gs[0, 0])
    ax_cb = fig.add_subplot(sub_gs[1, 0])

    ax.set_title(style.get("title", "Differences between stages"), fontsize=9.2, pad=18)

    pref_rcn = [f"RCN{i}" for i in range(1, 11)]
    rcn_list = [r for r in pref_rcn if r in pval_df["RCN"].values]
    for r in pval_df["RCN"].unique():
        if r not in rcn_list:
            rcn_list.append(r)

    pref_comps = ["Normal_vs_Precursor", "Precursor_vs_MIS", "Precursor_vs_IM", "MIS_vs_IM"]
    comp_keys = [c for c in pref_comps if c in pval_df["comparison"].values]
    for c in pval_df["comparison"].unique():
        if c not in comp_keys:
            comp_keys.append(c)

    alpha_cut = float(style.get("alpha_threshold", 0.05))
    ns_col = style.get("ns_color", "#A6A6A6")
    cmap_p = LinearSegmentedColormap.from_list("cd_pval", ["#BA242A", "#D96F56", "#83C8BE"])
    norm_p = Normalize(vmin=0.0, vmax=alpha_cut)

    ax.set_xlim(0, len(comp_keys))
    ax.set_ylim(len(rcn_list), 0)

    for ri, rname in enumerate(rcn_list):
        for ci, ckey in enumerate(comp_keys):
            row = pval_df[(pval_df["RCN"] == rname) & (pval_df["comparison"] == ckey)]
            pv = float(row["p_value"].iloc[0]) if not row.empty else np.nan
            if not np.isfinite(pv):
                fc = "#111111"
                txt = ""
            elif pv >= alpha_cut:
                fc = ns_col
                txt = f"{pv:.3f}"
            else:
                fc = cmap_p(norm_p(pv))
                txt = f"{pv:.3f}"
            ax.add_patch(mpatches.Rectangle((ci, ri), 1.0, 1.0, facecolor=fc, edgecolor="white", lw=0.8))
            if txt:
                ax.text(ci + 0.5, ri + 0.5, txt, ha="center", va="center", fontsize=7.0, color="white")

    ax.set_xticks(np.arange(len(comp_keys)) + 0.5)
    ax.set_xticklabels([COMP_LABELS.get(c, c) for c in comp_keys], fontsize=7.6)
    ax.xaxis.tick_top()
    ax.tick_params(axis="x", length=0, pad=3)
    ax.set_yticks(np.arange(len(rcn_list)) + 0.5)
    ax.set_yticklabels(rcn_list, fontsize=7.8)
    ax.yaxis.tick_right()
    ax.tick_params(axis="y", length=0, pad=3)
    for sp in ax.spines.values():
        sp.set_visible(False)

    cb_pos = ax_cb.get_position()
    ax_cb.axis("off")
    cb_ax = fig.add_axes([cb_pos.x0 + cb_pos.width * 0.24, cb_pos.y0 + 0.02, cb_pos.width * 0.44, 0.014])
    sm = plt.cm.ScalarMappable(cmap=cmap_p, norm=norm_p)
    cb = fig.colorbar(sm, cax=cb_ax, orientation="horizontal")
    cb.set_ticks([0.0, alpha_cut])
    cb.set_ticklabels(["0", f"{alpha_cut:g}"])
    cb.ax.tick_params(labelsize=6.8, length=2, pad=1.5)
    cb.outline.set_linewidth(0.5)
    cb_ax.text(-0.10, 0.5, "P-value", transform=cb_ax.transAxes, fontsize=7.2, va="center", ha="right")

    ax_cb.add_patch(mpatches.Rectangle((0.76, 0.30), 0.09, 0.36, facecolor=ns_col, edgecolor="none"))
    ax_cb.text(0.88, 0.48, "ns", fontsize=7.2, va="center", ha="left")
    return ax
