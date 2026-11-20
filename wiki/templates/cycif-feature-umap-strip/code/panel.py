"""Multi-marker continuous protein intensity UMAP strip (Cancer Discovery style)."""
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap, Normalize
from matplotlib.gridspec import GridSpecFromSubplotSpec
import numpy as np


def draw(fig, rect, tables, style):
    df = tables["cells"]
    meta_cols = {"cell_id", "umap_1", "umap_2"}
    markers = [c for c in df.columns if c not in meta_cols]
    n_m = len(markers)

    gs_outer = fig.add_gridspec(1, 1, left=rect[0], bottom=rect[1], right=rect[0] + rect[2], top=rect[1] + rect[3])
    sub_gs = GridSpecFromSubplotSpec(1, n_m + 1, subplot_spec=gs_outer[0, 0], width_ratios=[1.0] * n_m + [0.35], wspace=0.08)

    cmap_bwr = LinearSegmentedColormap.from_list(
        "cd_bwr", ["#3B75AF", "#AFCBE3", "#EAEAEA", "#E5876A", "#B2182B"]
    )
    x = df["umap_1"].to_numpy(float)
    y = df["umap_2"].to_numpy(float)
    pt_size = float(style.get("point_size", 2.4))
    alpha = float(style.get("alpha", 0.84))

    axes = []
    for idx, col_name in enumerate(markers):
        ax = fig.add_subplot(sub_gs[0, idx])
        axes.append(ax)
        vals = np.clip(df[col_name].to_numpy(float), 0.0, 1.0)
        order = np.argsort(vals)
        ax.scatter(
            x[order], y[order], c=vals[order], cmap=cmap_bwr, vmin=0.0, vmax=1.0,
            s=pt_size, alpha=alpha, edgecolors="none", rasterized=True,
        )
        ax.set_title(col_name, fontsize=8.5, pad=4, color="#111111")
        ax.set_xticks([])
        ax.set_yticks([])
        for sp in ax.spines.values():
            sp.set_visible(False)

    hdr = style.get("header_title", "Marker intensities across all specimens")
    if hdr and axes:
        axes[0].text(0.0, 1.24, hdr, transform=axes[0].transAxes, fontsize=9.2, va="top", ha="left", color="#222222")

    cax = fig.add_subplot(sub_gs[0, n_m])
    cax_pos = cax.get_position()
    cax.set_axis_off()
    cb_ax = fig.add_axes([cax_pos.x0 + 0.012, cax_pos.y0 + cax_pos.height * 0.15, 0.012, cax_pos.height * 0.68])
    sm = plt.cm.ScalarMappable(cmap=cmap_bwr, norm=Normalize(vmin=0.0, vmax=1.0))
    cb = fig.colorbar(sm, cax=cb_ax)
    cb.set_ticks([0.0, 0.5, 1.0])
    cb.set_ticklabels(["0.0", "0.5", "1.0"])
    cb.ax.tick_params(labelsize=7.0, length=2, pad=2)
    cb.outline.set_linewidth(0.6)
    cb_ax.set_ylabel("Intensity", fontsize=7.8, labelpad=3)
    cb_ax.yaxis.set_label_position("left")
    return axes
