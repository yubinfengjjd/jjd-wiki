"""Discrete 3-state spatial co-occurrence / avoidance permutation matrix (Cancer Discovery style)."""
import matplotlib.patches as mpatches
from matplotlib.gridspec import GridSpecFromSubplotSpec
import numpy as np


def draw(fig, rect, tables, style):
    df = tables["cooccurrence"]
    gs_outer = fig.add_gridspec(1, 1, left=rect[0], bottom=rect[1], right=rect[0] + rect[2], top=rect[1] + rect[3])
    sub_gs = GridSpecFromSubplotSpec(1, 2, subplot_spec=gs_outer[0, 0], width_ratios=[2.4, 0.95], wspace=0.08)
    ax = fig.add_subplot(sub_gs[0, 0])
    ax_leg = fig.add_subplot(sub_gs[0, 1])

    ax.set_title(style.get("title", "Co-occurrence of spatial lag clusters"), fontsize=9.2, pad=8)

    pref_tcc = [f"TCC{i}" for i in range(1, 11)]
    tcc_cols = [c for c in pref_tcc if c in df["TCC"].values]
    for c in df["TCC"].unique():
        if c not in tcc_cols:
            tcc_cols.append(c)

    all_nbrs = sorted(df["neighbour"].dropna().unique())
    non_tcc = [n for n in all_nbrs if n not in tcc_cols and n != "Unknown"]
    row_order = non_tcc + [n for n in tcc_cols if n in all_nbrs]

    state_colors = {
        "Avoidance": style.get("avoid_color", "#3D164A"),
        "Co-occurrence": style.get("cooccur_color", "#EAE33C"),
        "Non-Sig": style.get("nonsig_color", "#8E8E8E"),
    }

    ax.set_xlim(0, len(tcc_cols))
    ax.set_ylim(len(row_order), 0)

    lookup = df.set_index(["TCC", "neighbour"])["sig_state"].to_dict()
    for ri, rname in enumerate(row_order):
        for ci, cname in enumerate(tcc_cols):
            st = lookup.get((cname, rname), "Non-Sig")
            ax.add_patch(mpatches.Rectangle(
                (ci, ri), 1.0, 1.0,
                facecolor=state_colors.get(st, state_colors["Non-Sig"]),
                edgecolor="#222222", linewidth=0.45,
            ))

    ax.set_xticks(np.arange(len(tcc_cols)) + 0.5)
    ax.set_xticklabels(tcc_cols, rotation=90, fontsize=7.5)
    ax.set_yticks(np.arange(len(row_order)) + 0.5)
    ax.set_yticklabels(row_order, fontsize=7.0)
    ax.tick_params(length=0, pad=3)
    for sp in ax.spines.values():
        sp.set_linewidth(0.8)

    ax_leg.axis("off")
    ax_leg.text(0.05, 0.66, "(P < 0.05)", fontsize=7.6, va="bottom")
    handles = [
        mpatches.Patch(facecolor=state_colors["Avoidance"], edgecolor="#222222", linewidth=0.4, label="Avoidance"),
        mpatches.Patch(facecolor=state_colors["Co-occurrence"], edgecolor="#222222", linewidth=0.4, label="Co-occurrence"),
        mpatches.Patch(facecolor=state_colors["Non-Sig"], edgecolor="#222222", linewidth=0.4, label="Non-Sig (P ≥ 0.05)"),
    ]
    ax_leg.legend(handles=handles, loc="center left", frameon=False, fontsize=7.2, handlelength=1.0, handleheight=0.9, labelspacing=0.4)
    return ax
