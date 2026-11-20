"""RCN cluster Z-score composite heatmap with column dendrogram and left/right stacked composition bars."""
import matplotlib.patches as mpatches
from matplotlib.colors import LinearSegmentedColormap, Normalize
from matplotlib.gridspec import GridSpecFromSubplotSpec
import numpy as np
from scipy.cluster.hierarchy import dendrogram, linkage


STAGE_COLORS = {
    "Normal": "#3F3D6B",
    "Precursor": "#D96B43",
    "P": "#D96B43",
    "MIS": "#1D9A6C",
    "IM": "#B8862D",
    "EM": "#7F7F7F",
}

PATIENT_PALETTE = [
    "#1F78B4", "#FF7F00", "#33A02C", "#E31A1C", "#6A3D9A",
    "#A6CEE3", "#B2DF8A", "#FB9A99", "#FDBF6F", "#CAB2D6",
    "#FFFF99", "#B15928", "#8C510A",
]


def draw(fig, rect, tables, style):
    z_df = tables["zscore_matrix"].copy()
    tr_df = tables["cluster_tracks"].copy()

    z_cols = [c for c in z_df.columns if c not in ("rcn_group", "cluster_id")]
    z_mat = z_df[z_cols].to_numpy(float)

    # Hierarchical clustering of columns using Ward linkage on real Z-scores
    col_link = linkage(z_mat.T, method="ward", metric="euclidean")
    den = dendrogram(col_link, no_plot=True)
    col_order = den["leaves"]
    z_cols_ord = [z_cols[i] for i in col_order]
    z_mat_ord = z_mat[:, col_order]

    # Recompute dendrogram coordinates mapped onto 0..n_cols-1
    den_ord = dendrogram(linkage(z_mat_ord.T, method="ward", metric="euclidean"), no_plot=True)

    pat_cols = [c for c in tr_df.columns if c.startswith("patient_")]
    stg_cols = [c for c in tr_df.columns if c.startswith("stage_")]
    pat_names = [c.replace("patient_", "") for c in pat_cols]
    stg_names = [c.replace("stage_", "") for c in stg_cols]

    cmap = LinearSegmentedColormap.from_list(
        "rcn_scale",
        [(0.00, "#355C9B"), (0.28, "#8AC6C8"), (0.45, "#C7E6E5"), (0.55, "#F9F6F2"), (0.72, "#F5B895"), (1.00, "#B81D4E")],
    )
    zmin = float(style.get("z_min", -2.0))
    zmax = float(style.get("z_max", 2.0))
    norm = Normalize(vmin=zmin, vmax=zmax)

    gs_outer = fig.add_gridspec(1, 1, left=rect[0], bottom=rect[1], right=rect[0] + rect[2], top=rect[1] + rect[3])
    sub_gs = GridSpecFromSubplotSpec(
        3, 3, subplot_spec=gs_outer[0, 0],
        height_ratios=[0.65, 6.0, 1.55], width_ratios=[1.05, 2.55, 0.85],
        hspace=0.05, wspace=0.06,
    )

    ax_den = fig.add_subplot(sub_gs[0, 1])
    ax_left = fig.add_subplot(sub_gs[1, 0])
    ax_heat = fig.add_subplot(sub_gs[1, 1])
    ax_right = fig.add_subplot(sub_gs[1, 2])

    # Column dendrogram (scipy leaf x positions are 5, 15, 25, ...)
    n_cols = len(z_cols_ord)
    ax_den.set_xlim(-0.5, n_cols - 0.5)
    max_d = max(max(y) for y in den_ord["dcoord"]) if den_ord["dcoord"] else 1.0
    ax_den.set_ylim(0, max_d * 1.08)
    for xs, ys in zip(den_ord["icoord"], den_ord["dcoord"]):
        xs_idx = [(x - 5.0) / 10.0 for x in xs]
        ax_den.plot(xs_idx, ys, color="#222222", lw=0.95)
    ax_den.axis("off")

    # Row geometry grouped by rcn_group
    row_h = 1.0
    gap_h = 0.45
    y_cur = 0.0
    row_ys = []
    group_spans = {}
    groups_in_order = list(dict.fromkeys(z_df["rcn_group"].astype(str).tolist()))
    for grp in groups_in_order:
        idxs = z_df.index[z_df["rcn_group"].astype(str) == grp].tolist()
        y0 = y_cur
        for _ in idxs:
            row_ys.append(y_cur)
            y_cur += row_h
        group_spans[grp] = (y0, y_cur)
        y_cur += gap_h
    tot_y = y_cur - gap_h

    # Reindex row_ys in original dataframe row order
    row_y_by_idx = {}
    cursor = 0.0
    for grp in groups_in_order:
        idxs = z_df.index[z_df["rcn_group"].astype(str) == grp].tolist()
        for ri in idxs:
            row_y_by_idx[ri] = cursor
            cursor += row_h
        cursor += gap_h

    for ax in (ax_left, ax_heat, ax_right):
        ax.set_ylim(tot_y + 0.2, -0.2)

    # Left stacked patient bars + group brackets
    ax_left.set_xlim(0, 1)
    ax_left.axis("off")
    ax_left.text(0.5, -0.5, "Patients", ha="center", va="bottom", fontsize=7.0, color="#222222", clip_on=False)
    for ri in range(len(z_df)):
        yt = row_y_by_idx[ri]
        vals = tr_df.loc[ri, pat_cols].to_numpy(float)
        s = vals.sum()
        if s > 0:
            vals = vals / s
        xc = 0.04
        for pi, pv in enumerate(vals):
            if pv <= 0:
                continue
            w = pv * 0.94
            ax_left.add_patch(mpatches.Rectangle((xc, yt + 0.06), w, row_h - 0.12,
                                                 facecolor=PATIENT_PALETTE[pi % len(PATIENT_PALETTE)],
                                                 edgecolor="#333333", lw=0.25))
            xc += w
    for grp, (y0, y1) in group_spans.items():
        ax_left.plot([-0.02, -0.02], [y0 + 0.08, y1 - 0.08], color="#111111", lw=1.6, clip_on=False)
        ax_left.text(-0.07, 0.5 * (y0 + y1), grp, ha="right", va="center", fontsize=7.2, color="#111111", clip_on=False)

    # Center Z-score heatmap
    ax_heat.set_xlim(-0.5, n_cols - 0.5)
    for ri in range(len(z_df)):
        yt = row_y_by_idx[ri]
        for ci in range(n_cols):
            ax_heat.add_patch(mpatches.Rectangle(
                (ci - 0.5, yt), 1.0, row_h,
                facecolor=cmap(norm(z_mat_ord[ri, ci])),
                edgecolor="#444444", linewidth=0.35,
            ))
    for _, (y0, y1) in group_spans.items():
        ax_heat.add_patch(mpatches.Rectangle((-0.5, y0), n_cols, y1 - y0, facecolor="none", edgecolor="#222222", lw=0.65))
    ax_heat.set_xticks(np.arange(n_cols))
    ax_heat.set_xticklabels(z_cols_ord, rotation=90, fontsize=6.8, va="top", ha="center")
    ax_heat.tick_params(axis="x", length=0, pad=2)
    ax_heat.set_yticks([])
    for sp in ax_heat.spines.values():
        sp.set_visible(False)

    # Right stacked Stage bars + K-means ID
    ax_right.set_xlim(0, 1)
    ax_right.axis("off")
    ax_right.text(0.32, -0.5, "Stage", ha="center", va="bottom", fontsize=7.0, color="#222222", clip_on=False)
    ax_right.text(0.84, -0.5, "Cluster", ha="center", va="bottom", fontsize=6.5, style="italic", color="#222222", clip_on=False)
    for ri in range(len(z_df)):
        yt = row_y_by_idx[ri]
        vals = tr_df.loc[ri, stg_cols].to_numpy(float)
        s = vals.sum()
        if s > 0:
            vals = vals / s
        xc = 0.0
        for sname, sv in zip(stg_names, vals):
            if sv <= 0:
                continue
            w = sv * 0.66
            ax_right.add_patch(mpatches.Rectangle((xc, yt + 0.06), w, row_h - 0.12,
                                                  facecolor=STAGE_COLORS.get(sname, "#999999"),
                                                  edgecolor="#333333", lw=0.25))
            xc += w
        ax_right.text(0.73, yt + 0.5 * row_h, str(z_df.loc[ri, "cluster_id"]), ha="left", va="center", fontsize=6.4, color="#111111")

    # Bottom legends
    ax_lp = fig.add_subplot(sub_gs[2, 0])
    ax_lsc = fig.add_subplot(sub_gs[2, 1])
    ax_lst = fig.add_subplot(sub_gs[2, 2])
    for a in (ax_lp, ax_lsc, ax_lst):
        a.axis("off")

    ax_lp.text(0.02, 0.72, "Patient ID", fontsize=7.2, ha="left", va="top", color="#111111")
    for pi, pname in enumerate(pat_names[:6]):
        yp = 0.50 - pi * 0.13
        ax_lp.add_patch(mpatches.Rectangle((0.02, yp - 0.04), 0.18, 0.09, facecolor=PATIENT_PALETTE[pi % len(PATIENT_PALETTE)], edgecolor="none"))
        ax_lp.text(0.24, yp, pname, fontsize=6.6, va="center", ha="left")

    sc_pos = ax_lsc.get_position()
    cb_ax = fig.add_axes([sc_pos.x0 + sc_pos.width * 0.22, sc_pos.y0 + 0.032, sc_pos.width * 0.56, 0.016])
    sm = plt.cm.ScalarMappable(cmap=cmap, norm=norm)
    cb = fig.colorbar(sm, cax=cb_ax, orientation="horizontal")
    cb.set_ticks([zmin, 0.0, zmax])
    cb.ax.xaxis.set_ticks_position("top")
    cb.ax.tick_params(labelsize=6.5, length=2, pad=1)
    cb.outline.set_linewidth(0.45)
    cb_ax.set_xlabel("Scale (Z-score)", fontsize=7.0, labelpad=3)

    ax_lst.text(0.0, 0.72, "Stage", fontsize=7.2, ha="left", va="top", color="#111111")
    for si, sname in enumerate(stg_names[:5]):
        yp = 0.50 - si * 0.13
        ax_lst.add_patch(mpatches.Rectangle((0.0, yp - 0.04), 0.26, 0.09, facecolor=STAGE_COLORS.get(sname, "#999999"), edgecolor="none"))
        ax_lst.text(0.32, yp, sname, fontsize=6.6, va="center", ha="left")
