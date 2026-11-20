"""2D physical-coordinate protein/gene expression contour topography (Cancer Discovery style)."""
import math
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap, Normalize
from matplotlib.gridspec import GridSpecFromSubplotSpec
import numpy as np
import pandas as pd


def draw(fig, rect, tables, style):
    cont_df = tables["contours"].copy()
    cells_df = tables.get("cells")

    fov_col = style.get("fov_col", "fov_id")
    x_col = style.get("x_col", "X_um")
    y_col = style.get("y_col", "Y_um")

    if fov_col in cont_df.columns:
        target_fov = str(style.get("fov_id", "") or "")
        avail_fovs = cont_df[fov_col].dropna().astype(str).unique().tolist()
        if target_fov not in avail_fovs and avail_fovs:
            target_fov = avail_fovs[0]
        sub_cont = cont_df[cont_df[fov_col].astype(str) == target_fov].copy()
        if cells_df is not None and fov_col in cells_df.columns:
            sub_cells = cells_df[cells_df[fov_col].astype(str) == target_fov].copy()
        else:
            sub_cells = cells_df.copy() if cells_df is not None else None
    else:
        sub_cont = cont_df.copy()
        sub_cells = cells_df.copy() if cells_df is not None else None

    excluded_cols = {fov_col, x_col, y_col}
    numeric_feats = [
        c for c in sub_cont.columns
        if c not in excluded_cols and pd.api.types.is_numeric_dtype(sub_cont[c])
    ]
    req_feats = [f for f in style.get("features", []) if f in numeric_feats]
    features = req_feats if req_feats else numeric_feats
    if not features:
        raise ValueError("contours 表未检测到可绘制的数值特征列")

    feat_labels = style.get("feature_labels", {})
    border_colors = style.get("border_colors", {})
    flip_y = bool(style.get("flip_y", True))
    levels_fill = int(style.get("levels_fill", 16))
    levels_line = int(style.get("levels_line", 12))
    pt_size = float(style.get("point_size", 3.5))

    cmap = LinearSegmentedColormap.from_list(
        "cd_spatial_contour", ["#4E739C", "#9EC1D1", "#F2EBC9", "#DF754B", "#AE212C"]
    )

    gx = np.sort(sub_cont[x_col].unique())
    gy = np.sort(sub_cont[y_col].unique())
    GX, GY = np.meshgrid(gx, gy)
    ymax = float(sub_cells[y_col].max()) if (sub_cells is not None and not sub_cells.empty) else float(gy.max())
    GY_plot = (ymax - GY) if flip_y else GY

    n_feats = len(features)
    ncols = int(style.get("ncols", 1 if n_feats <= 3 else 2))
    nrows = math.ceil(n_feats / ncols)

    gs_outer = fig.add_gridspec(1, 1, left=rect[0], bottom=rect[1], right=rect[0] + rect[2], top=rect[1] + rect[3])
    sub_gs = GridSpecFromSubplotSpec(
        nrows, ncols + 1,
        subplot_spec=gs_outer[0, 0],
        width_ratios=[1.0] * ncols + [0.08],
        hspace=0.07,
        wspace=0.06,
    )

    axes = []
    for idx, col_name in enumerate(features):
        r, c = divmod(idx, ncols)
        ax = fig.add_subplot(sub_gs[r, c])
        axes.append(ax)

        piv_df = sub_cont.pivot_table(index=y_col, columns=x_col, values=col_name, aggfunc="mean")
        piv = piv_df.reindex(index=gy, columns=gx).to_numpy(dtype=float)
        vmin = float(np.nanmin(piv))
        vmax = float(np.nanmax(piv))
        if vmax <= vmin:
            vmax = vmin + 1e-6
        norm = Normalize(vmin=vmin, vmax=vmax)

        ax.contourf(GX, GY_plot, piv, levels=levels_fill, cmap=cmap, norm=norm, alpha=0.86)
        ax.contour(GX, GY_plot, piv, levels=levels_line, colors="white", linewidths=0.45, alpha=0.76)

        if sub_cells is not None and not sub_cells.empty:
            cx = sub_cells[x_col].to_numpy(dtype=float)
            cy_raw = sub_cells[y_col].to_numpy(dtype=float)
            cy = (ymax - cy_raw) if flip_y else cy_raw
            ix = np.clip(np.searchsorted(gx, cx), 0, len(gx) - 1)
            iy = np.clip(np.searchsorted(gy, cy_raw), 0, len(gy) - 1)
            cvals = piv[iy, ix]
            ax.scatter(
                cx, cy, c=cvals, cmap=cmap, norm=norm,
                s=pt_size, alpha=0.80, edgecolors="none", rasterized=True, zorder=3,
            )

        lbl = feat_labels.get(col_name, col_name)
        ax.text(
            0.96, 0.94, lbl, transform=ax.transAxes, ha="right", va="top",
            fontsize=6.4, color="#111111",
            bbox=dict(boxstyle="round,pad=0.16", facecolor="white", edgecolor="none", alpha=0.78),
        )
        ax.set_xlim(gx.min(), gx.max())
        ax.set_ylim(GY_plot.min(), GY_plot.max())
        ax.set_xticks([])
        ax.set_yticks([])

        bcol = border_colors.get(col_name, "#333333")
        blw = 1.5 if col_name in border_colors else 0.8
        for sp in ax.spines.values():
            sp.set_linewidth(blw)
            sp.set_color(bcol)

    # Compact relative expression colorbar on right
    ax_cb_slot = fig.add_subplot(sub_gs[:, ncols])
    cb_pos = ax_cb_slot.get_position()
    ax_cb_slot.axis("off")
    cb_ax = fig.add_axes([cb_pos.x0 + 0.01, cb_pos.y0 + cb_pos.height * 0.25, 0.018, cb_pos.height * 0.50])
    sm = plt.cm.ScalarMappable(cmap=cmap, norm=Normalize(vmin=0.0, vmax=1.0))
    cb = fig.colorbar(sm, cax=cb_ax)
    cb.set_ticks([0.0, 0.5, 1.0])
    cb.set_ticklabels(["Low", "Mid", "High"])
    cb.ax.tick_params(labelsize=5.4, length=1.8, pad=2)
    cb.outline.set_linewidth(0.45)
    cb_ax.set_title("Expr", fontsize=5.8, pad=4)
    return axes
