"""Multi-cluster by multi-marker horizontal positivity fraction bar matrix (Cancer Discovery style)."""
from matplotlib.gridspec import GridSpecFromSubplotSpec
import numpy as np

TCC_COLORS = {
    "TCC1": "#EC607A",
    "TCC2": "#48C999",
    "TCC3": "#F7C654",
    "TCC4": "#227BA3",
    "TCC5": "#0F3D4C",
    "TCC6": "#F19B8E",
    "TCC7": "#F3EED4",
    "TCC8": "#B8E1DF",
    "TCC9": "#8B7D8B",
    "TCC10": "#696D7D",
}
LABEL_MAP = {
    "S100a": "S100A$^+$",
    "MART1": "MART1$^+$",
    "CCND1": "CCND1$^+$",
    "MYC": "MYC$^+$",
    "HLADPB1": "HLA-II$^+$",
}


def draw(fig, rect, tables, style):
    df = tables["positivity"].copy()
    id_col = df.columns[0]
    df = df.set_index(id_col)

    pref_tcc = [f"TCC{i}" for i in range(1, 11)]
    clusters = [c for c in pref_tcc if c in df.index] + [c for c in df.index if c not in pref_tcc]

    pref_markers = ["S100a", "MART1", "CCND1", "MYC", "HLADPB1"]
    markers = [m for m in pref_markers if m in df.columns]
    if not markers:
        markers = list(df.columns[:6])

    gs_outer = fig.add_gridspec(1, 1, left=rect[0], bottom=rect[1], right=rect[0] + rect[2], top=rect[1] + rect[3])
    sub_gs = GridSpecFromSubplotSpec(1, len(markers), subplot_spec=gs_outer[0, 0], wspace=0.16)

    y_pos = np.arange(len(clusters))
    bar_cols = [TCC_COLORS.get(c, "#48C999") for c in clusters]
    bh = float(style.get("bar_height", 0.76))

    axes = []
    for idx, col_name in enumerate(markers):
        ax = fig.add_subplot(sub_gs[0, idx])
        axes.append(ax)
        raw_vals = [float(df.loc[c, col_name]) for c in clusters]
        scale_div = 100.0 if max(raw_vals + [1.0]) > 1.05 else 1.0
        vals = [v / scale_div for v in raw_vals]
        ax.barh(y_pos, vals, height=bh, color=bar_cols, edgecolor="#333333", linewidth=0.25)
        ax.set_xlim(0, 1.06)
        ax.set_ylim(len(clusters) - 0.3, -0.7)
        ax.set_xticks([0, 1])
        ax.set_xticklabels(["0", "1"], fontsize=7.5)
        ax.set_title(LABEL_MAP.get(col_name, col_name), fontsize=8.0, pad=4)

        ax.set_yticks(y_pos)
        if idx == 0:
            ax.set_yticklabels([str(c).replace("TCC", "") for c in clusters], fontsize=7.8)
            ax.set_ylabel(style.get("ylabel", "TCCs"), fontsize=8.5, labelpad=4)
        else:
            ax.set_yticklabels([])
            ax.tick_params(axis="y", length=0)

        ax.spines["top"].set_visible(False)
        ax.spines["right"].set_visible(False)
        ax.spines["left"].set_linewidth(0.75)
        ax.spines["bottom"].set_linewidth(0.75)

    fig.text(
        0.5 * (axes[0].get_position().x0 + axes[-1].get_position().x1),
        axes[0].get_position().y0 - 0.08,
        style.get("xlabel", "Fraction of cells"), ha="center", va="top", fontsize=8.5,
    )
    return axes
