"""Tri-panel UMAP colored by cell type, progression stage, and patient ID (Cancer Discovery style)."""
import matplotlib.lines as mlines
from matplotlib.gridspec import GridSpecFromSubplotSpec
import numpy as np


DEFAULT_CT_PALETTE = {
    "Tumor": "#623594",
    "PDL1+ dendritic": "#1A5B8C",
    "Dendritic": "#227BA3",
    "Macrophage": "#A8D18D",
    "CTL": "#F2C84B",
    "PDL1+ Macs": "#2CA298",
    "CD11C+ Macs": "#74A892",
    "Treg": "#E3256B",
    "Keratinocytes": "#8A6240",
    "Langerhans": "#D3E298",
    "PD1+ CTL": "#D95F43",
    "T helper": "#F08C4B",
    "Other": "#BDBDBD",
}

DEFAULT_STAGE_PALETTE = {
    "N": "#3F3D6B",
    "P": "#D96B43",
    "MIS": "#1D9A6C",
    "IM": "#B8862D",
    "EM": "#7F7F7F",
}

TAB_FALLBACK = [
    "#1F78B4", "#FF7F00", "#33A02C", "#E31A1C", "#6A3D9A",
    "#8C564B", "#E377C2", "#17BECF", "#BCBD22", "#7F7F7F",
]


def _pick_colors(cats, preset):
    out = {}
    i = 0
    for c in cats:
        if c in preset:
            out[c] = preset[c]
        else:
            out[c] = TAB_FALLBACK[i % len(TAB_FALLBACK)]
            i += 1
    return out


def draw(fig, rect, tables, style):
    df = tables["cells"]
    col1 = style.get("panel1_col", "cell_type")
    col2 = style.get("panel2_col", "stage")
    col3 = style.get("panel3_col", "patient_id")
    titles = style.get("panel_titles", ["UMAP by cell type", "UMAP by stage", "UMAP by patient"])
    pt_size = float(style.get("point_size", 4.5))
    alpha = float(style.get("alpha", 0.78))

    gs_outer = fig.add_gridspec(1, 1, left=rect[0], bottom=rect[1], right=rect[0] + rect[2], top=rect[1] + rect[3])
    sub_gs = GridSpecFromSubplotSpec(1, 3, subplot_spec=gs_outer[0, 0], width_ratios=[1.0, 0.92, 0.92], wspace=0.58)

    x = df["umap_1"].to_numpy(float)
    y = df["umap_2"].to_numpy(float)
    xmin, xmax = np.percentile(x, [0.5, 99.5])
    ymin, ymax = np.percentile(y, [0.5, 99.5])

    panels = [
        (col1, titles[0], DEFAULT_CT_PALETTE),
        (col2, titles[1], DEFAULT_STAGE_PALETTE),
        (col3, titles[2], {}),
    ]

    axes = []
    for idx, (col, ttl, preset) in enumerate(panels):
        ax = fig.add_subplot(sub_gs[0, idx])
        axes.append(ax)
        cats = [str(c) for c in df[col].dropna().unique()]
        if col == col1:
            ordered = [c for c in DEFAULT_CT_PALETTE if c in cats] + [c for c in sorted(cats) if c not in DEFAULT_CT_PALETTE]
        elif col == col2:
            ordered = [c for c in ["N", "P", "MIS", "IM", "EM"] if c in cats] + [c for c in sorted(cats) if c not in ["N", "P", "MIS", "IM", "EM"]]
        else:
            ordered = sorted(cats)
        pal = _pick_colors(ordered, preset)
        svals = df[col].astype(str)
        for cat in ordered:
            m = (svals == cat).to_numpy()
            if m.any():
                ax.scatter(x[m], y[m], c=pal[cat], s=pt_size, alpha=alpha, edgecolors="none", rasterized=True)
        ax.set_title(ttl, fontsize=9.0, pad=6, loc="center", color="#111111")
        handles = [
            mlines.Line2D([], [], color="none", marker="o", markersize=5.0,
                          markerfacecolor=pal[cat], markeredgecolor="none", label=cat)
            for cat in ordered
        ]
        ax.legend(
            handles=handles, loc="center left", bbox_to_anchor=(0.98, 0.50),
            frameon=False, fontsize=7.0, handletextpad=0.15, labelspacing=0.30, borderpad=0.0,
        )
        ax.set_xticks([])
        ax.set_yticks([])
        for sp in ax.spines.values():
            sp.set_visible(False)

    axes[0].text(xmin + 0.04 * (xmax - xmin), ymin - 0.05 * (ymax - ymin), "UMAP1", fontsize=7.5, ha="left", va="top", color="#333333")
    axes[0].text(xmin - 0.05 * (xmax - xmin), ymin + 0.04 * (ymax - ymin), "UMAP2", fontsize=7.5, ha="right", va="bottom", rotation=90, color="#333333")
    return axes
