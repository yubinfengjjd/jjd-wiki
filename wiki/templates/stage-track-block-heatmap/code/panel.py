"""Top stage-track + multi-block pathway/gene Z-score heatmap (Cancer Discovery style)."""
import matplotlib.patches as mpatches
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap, Normalize
from matplotlib.gridspec import GridSpecFromSubplotSpec
import numpy as np
import pandas as pd


STAGE_COLORS_PRESET = {
    "MIS": "#1E9C78",
    "IR": "#B86646",
    "bTIL": "#C84B93",
    "IB": "#85A933",
    "IM": "#C69032",
    "EM": "#666666",
    "N": "#3F3D6B",
    "Normal": "#3F3D6B",
    "P": "#D96B43",
    "Precursor": "#D96B43",
}

FALLBACK_COLORS = [
    "#1F78B4", "#33A02C", "#FF7F00", "#6A3D9A", "#E31A1C",
    "#A6CEE3", "#B2DF8A", "#FDBF6F", "#CAB2D6", "#7F7F7F",
]

CMAP_PRESETS = {
    "cancer_discovery_score": ["#F8F1C3", "#F3C37A", "#E3704D", "#AC2A55", "#54184E"],
    "cancer_discovery_zscore": ["#3D7889", "#8FC2BD", "#F5EEBE", "#E68358", "#BC2C3B"],
}


def draw(fig, rect, tables, style):
    scores_df = tables["scores"].copy()
    meta_df = tables["sample_meta"].copy()

    # Index scores_df by first column (or feature column)
    feat_col = style.get("feature_col")
    if not feat_col or feat_col not in scores_df.columns:
        feat_col = scores_df.columns[0]
    scores_df[feat_col] = scores_df[feat_col].astype(str)
    scores_df = scores_df.set_index(feat_col)

    sample_col = style.get("sample_col", "sample_id")
    if sample_col not in meta_df.columns:
        sample_col = meta_df.columns[0]
    stage_col = style.get("stage_col", "site")
    if stage_col not in meta_df.columns:
        cand = [c for c in meta_df.columns if c != sample_col]
        stage_col = cand[0] if cand else sample_col

    meta_df[sample_col] = meta_df[sample_col].astype(str)
    meta_df[stage_col] = meta_df[stage_col].astype(str)
    score_cols = {str(c) for c in scores_df.columns}
    meta_sub = meta_df[meta_df[sample_col].isin(score_cols)].copy()
    if meta_sub.empty:
        raise ValueError("sample_meta 中的 sample_id 与 scores 矩阵列名无交集")

    avail_stages = list(dict.fromkeys(meta_sub[stage_col].tolist()))
    preset_stages = [str(s) for s in style.get("stage_order", [])]
    if preset_stages and any(s in avail_stages for s in preset_stages):
        stage_cats = [s for s in preset_stages if s in avail_stages] + [s for s in avail_stages if s not in preset_stages]
    else:
        stage_cats = avail_stages

    meta_sub["_stage_cat"] = pd.Categorical(meta_sub[stage_col], categories=stage_cats, ordered=True)
    meta_sub = meta_sub.sort_values(["_stage_cat", sample_col])
    ordered_samples = meta_sub[sample_col].tolist()
    ordered_stages = meta_sub[stage_col].tolist()

    stage_pal = {}
    fi = 0
    for st in stage_cats:
        if st in STAGE_COLORS_PRESET:
            stage_pal[st] = STAGE_COLORS_PRESET[st]
        else:
            stage_pal[st] = FALLBACK_COLORS[fi % len(FALLBACK_COLORS)]
            fi += 1

    mat_raw = scores_df[ordered_samples].to_numpy(dtype=float)
    vmin = float(style.get("vmin", -1.0))
    vmax = float(style.get("vmax", 1.0))
    norm_mode = style.get("normalize_mode", "zscore_2sd")

    if norm_mode in ("zscore_2sd", "zscore"):
        denom_mult = 2.0 if norm_mode == "zscore_2sd" else 1.0
        row_mean = np.nanmean(mat_raw, axis=1, keepdims=True)
        row_std = np.nanstd(mat_raw, axis=1, keepdims=True)
        row_std = np.where(row_std > 1e-8, row_std, 1.0)
        mat_plot = np.clip((mat_raw - row_mean) / (denom_mult * row_std), vmin, vmax)
    else:
        mat_plot = np.clip(mat_raw, vmin, vmax)

    row_names = scores_df.index.tolist()
    resolved_blocks = []
    for blk in style.get("row_blocks", []):
        keys = blk.get("rows", [])
        pretty = blk.get("pretty", keys)
        matched_idx = []
        matched_lbl = []
        for k, p in zip(keys, pretty):
            if k in row_names:
                matched_idx.append(row_names.index(k))
                matched_lbl.append(p)
        if matched_idx:
            resolved_blocks.append((str(blk.get("label", "")), matched_idx, matched_lbl))

    if not resolved_blocks:
        resolved_blocks = [("", list(range(len(row_names))), row_names)]

    cmap_colors = CMAP_PRESETS.get(
        style.get("cmap_preset", "cancer_discovery_score"),
        CMAP_PRESETS["cancer_discovery_score"],
    )
    cmap = LinearSegmentedColormap.from_list("cd_block_hm", cmap_colors)
    norm = Normalize(vmin=vmin, vmax=vmax)

    block_heights = [max(0.45, 0.36 * len(idx_list)) for _, idx_list, _ in resolved_blocks]
    height_ratios = [0.55, 0.22] + block_heights
    gs_outer = fig.add_gridspec(1, 1, left=rect[0], bottom=rect[1], right=rect[0] + rect[2], top=rect[1] + rect[3])
    sub_gs = GridSpecFromSubplotSpec(
        2 + len(resolved_blocks), 2,
        subplot_spec=gs_outer[0, 0],
        height_ratios=height_ratios,
        width_ratios=[1.0, 0.34],
        hspace=0.14,
        wspace=0.02,
    )

    # Top colorbar slot
    ax_top = fig.add_subplot(sub_gs[0, :])
    ax_top.axis("off")
    top_pos = ax_top.get_position()
    cb_ax = fig.add_axes([top_pos.x0 + top_pos.width * 0.44, top_pos.y0 + top_pos.height * 0.48, top_pos.width * 0.34, 0.016])
    sm = plt.cm.ScalarMappable(cmap=cmap, norm=norm)
    cb = fig.colorbar(sm, cax=cb_ax, orientation="horizontal")
    ticks = np.linspace(vmin, vmax, 5)
    cb.set_ticks(ticks)
    cb.set_ticklabels([f"{t:g}" for t in ticks])
    cb.ax.xaxis.set_ticks_position("top")
    cb.ax.tick_params(labelsize=5.4, length=1.8, pad=1.2)
    cb.outline.set_linewidth(0.45)
    cb_ax.text(-0.06, 0.5, str(style.get("colorbar_title", "Score")), transform=cb_ax.transAxes, fontsize=6.4, va="center", ha="right")

    # Stage color track
    ax_st = fig.add_subplot(sub_gs[1, 0])
    n_s = len(ordered_samples)
    ax_st.set_xlim(0, n_s)
    ax_st.set_ylim(0, 1)
    for i, st in enumerate(ordered_stages):
        ax_st.add_patch(mpatches.Rectangle((i, 0), 1.0, 1.0, facecolor=stage_pal[st], edgecolor="none"))
    for st in stage_cats:
        idxs = [i for i, s in enumerate(ordered_stages) if s == st]
        if idxs:
            mid = 0.5 * (min(idxs) + max(idxs) + 1)
            ax_st.text(mid, 1.15, st, ha="center", va="bottom", fontsize=5.8, color=stage_pal[st], fontweight="bold")
    ax_st.set_xticks([])
    ax_st.set_yticks([])
    for sp in ax_st.spines.values():
        sp.set_visible(False)

    axes = [ax_top, ax_st]
    for b_idx, (blk_lbl, r_indices, pretty_lbls) in enumerate(resolved_blocks):
        ax_b = fig.add_subplot(sub_gs[2 + b_idx, 0])
        axes.append(ax_b)
        sub_mat = mat_plot[r_indices, :]
        ax_b.imshow(sub_mat, aspect="auto", cmap=cmap, norm=norm, interpolation="nearest")
        if blk_lbl:
            ax_b.set_ylabel(blk_lbl, fontsize=6.8, labelpad=4, color="#111111")
        ax_b.set_yticks(np.arange(len(r_indices)))
        ax_b.set_yticklabels(pretty_lbls, fontsize=6.2)
        ax_b.yaxis.tick_right()
        ax_b.tick_params(axis="y", length=0, pad=3)
        ax_b.set_xticks([])
        for sp in ax_b.spines.values():
            sp.set_linewidth(0.5)
            sp.set_color("#444444")
    return axes
