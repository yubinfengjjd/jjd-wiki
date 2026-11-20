"""RCN horizontal stacked composition bars + highlighted target cell type + grouped functional pie charts (Cancer Discovery style)."""
import math
import re
import matplotlib.lines as mlines
import matplotlib.patches as mpatches
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpecFromSubplotSpec
import numpy as np
import pandas as pd


CELL_COLORS = {
    "Mel": "#623594",
    "Melanocytic": "#623594",
    "PD-L1+ DC": "#0D0D0D",
    "PDL1+ DCs": "#0D0D0D",
    "DC": "#227BA3",
    "Dendritic": "#227BA3",
    "PD-L1+ mac": "#2CA298",
    "PDL1+ Macs": "#2CA298",
    "CD11C+ mac": "#74A892",
    "CD11C+ Macs": "#74A892",
    "PD1+ CTL": "#DCDCDC",
    "PD1+ CTLs": "#DCDCDC",
    "LC": "#D3E298",
    "CTL": "#F2C84B",
    "Treg": "#E3256B",
    "Mac": "#A8D18D",
    "Macrophage": "#A8D18D",
    "Th": "#F08C4B",
    "T helper": "#F08C4B",
    "Ker": "#8A6240",
    "Keratinocyte": "#8A6240",
    "Tex": "#EA7AA6",
    "Mast cell": "#C8D7E8",
    "Endo": "#CBE4D0",
    "Unknown": "#B8B8B8",
}

PIE_COLORS = {
    "Keratinocytes": "#F2C84B",
    "Lymphoid": "#F08C4B",
    "CTL, Treg, T helper": "#F08C4B",
    "Immune-suppressive": "#D95F43",
    "PDL1+ DCs and Macs, PD1+ CTL": "#D95F43",
    "Myeloid": "#2CA298",
    "Dendritic, CD11C+ Macs, Macrophage, Langerhans": "#2CA298",
    "Melanocytes": "#1B3644",
    "Melanocytic": "#1B3644",
    "Stroma/Unknown": "#BDBDBD",
}

FALLBACK_COLORS = [
    "#1F78B4", "#33A02C", "#FF7F00", "#6A3D9A", "#E31A1C",
    "#A6CEE3", "#B2DF8A", "#FDBF6F", "#CAB2D6", "#FB9A99",
    "#8C564B", "#17BECF", "#BCBD22", "#E377C2", "#7F7F7F",
]


def _natural_sort_key(text: str):
    return [int(tok) if tok.isdigit() else tok.lower() for tok in re.split(r"(\d+)", str(text))]


def _pick_palette(names, preset):
    out = {}
    i = 0
    for name in names:
        if name in preset:
            out[name] = preset[name]
        else:
            out[name] = FALLBACK_COLORS[i % len(FALLBACK_COLORS)]
            i += 1
    return out


def draw(fig, rect, tables, style):
    bars_df = tables["bars"].copy()
    pies_df = tables["pies"].copy()

    id_col = style.get("id_col", "RCN")
    if id_col not in bars_df.columns:
        id_col = bars_df.columns[0]
    pie_id_col = id_col if id_col in pies_df.columns else pies_df.columns[0]

    bars_df[id_col] = bars_df[id_col].astype(str)
    pies_df[pie_id_col] = pies_df[pie_id_col].astype(str)

    # Order IDs: use preset order only if overlapping, else natural sort
    preset_order = [str(x) for x in style.get("rcn_order", [])]
    avail_ids = bars_df[id_col].tolist()
    if preset_order and any(x in avail_ids for x in preset_order):
        ordered_ids = [x for x in preset_order if x in avail_ids] + [
            x for x in sorted(avail_ids, key=_natural_sort_key) if x not in preset_order
        ]
    else:
        ordered_ids = sorted(avail_ids, key=_natural_sort_key)

    bars_indexed = bars_df.set_index(id_col).loc[ordered_ids]
    cell_cols = [c for c in bars_indexed.columns if pd.api.types.is_numeric_dtype(bars_indexed[c])]
    # Order cell columns: Mel/Ker/immune canonical order if present, then remaining
    canon_order = [
        "Mel", "Melanocytic", "Th", "T helper", "Treg", "PD1+ CTL", "PD1+ CTLs",
        "CTL", "Tex", "LC", "Mac", "Macrophage", "CD11C+ mac", "CD11C+ Macs",
        "PD-L1+ mac", "PDL1+ Macs", "Ker", "Keratinocyte", "DC", "Dendritic",
        "PD-L1+ DC", "PDL1+ DCs", "Mast cell", "Endo", "Unknown",
    ]
    ordered_cells = [c for c in canon_order if c in cell_cols] + [c for c in cell_cols if c not in canon_order]
    cell_pal = _pick_palette(ordered_cells, CELL_COLORS)

    highlight_col = str(style.get("highlight_col", "PD1+ CTL"))
    hl_fill = style.get("highlight_fill", "#E2E2E2")
    hl_edge = style.get("highlight_edge", "#C82829")
    if highlight_col in cell_pal:
        cell_pal[highlight_col] = hl_fill

    # Pie columns & groups
    pies_indexed = pies_df.set_index(pie_id_col)
    pie_group_col = style.get("pie_group_col", "pie_group")
    pie_cols = [
        c for c in pies_indexed.columns
        if c != pie_group_col and pd.api.types.is_numeric_dtype(pies_indexed[c])
    ]
    pie_pal = _pick_palette(pie_cols, PIE_COLORS)

    sub_gs = GridSpecFromSubplotSpec(
        3, 1,
        subplot_spec=fig.add_gridspec(
            1, 1, left=rect[0], bottom=rect[1], right=rect[0] + rect[2], top=rect[1] + rect[3]
        )[0, 0],
        height_ratios=[3.2, 1.05, 3.25],
        hspace=0.14,
    )
    ax_bars = fig.add_subplot(sub_gs[0, 0])
    ax_leg = fig.add_subplot(sub_gs[1, 0])
    ax_pies = fig.add_subplot(sub_gs[2, 0])

    # 1) Top horizontal stacked bars
    ax_bars.set_title(style.get("bar_title", "RCN cell types"), fontsize=8.4, loc="left", pad=5, color="#111111")
    ax_bars.set_xlim(0.0, 1.0)
    ax_bars.set_ylim(len(ordered_ids) - 0.3, -0.7)

    for idx_r, rid in enumerate(ordered_ids):
        row = bars_indexed.loc[rid, ordered_cells].to_numpy(dtype=float)
        row = np.nan_to_num(row, nan=0.0, posinf=0.0, neginf=0.0)
        tot = float(row.sum())
        if tot > 0:
            row = row / tot
        x_cur = 0.0
        for cname, prop in zip(ordered_cells, row):
            if prop <= 1e-6:
                continue
            if cname == highlight_col:
                patch = mpatches.Rectangle(
                    (x_cur, idx_r - 0.38), prop, 0.76,
                    facecolor=hl_fill, edgecolor=hl_edge, linewidth=1.25, zorder=5,
                )
            else:
                patch = mpatches.Rectangle(
                    (x_cur, idx_r - 0.38), prop, 0.76,
                    facecolor=cell_pal[cname], edgecolor="white", linewidth=0.22, zorder=2,
                )
            ax_bars.add_patch(patch)
            x_cur += prop

    ax_bars.set_yticks(np.arange(len(ordered_ids)))
    ax_bars.set_yticklabels(ordered_ids, fontsize=6.8)
    ax_bars.tick_params(axis="y", length=3, width=0.6, pad=2)
    ax_bars.set_xticks([0.0, 0.5, 1.0])
    ax_bars.set_xticklabels(["0", "0.5", "1.0"], fontsize=5.8)
    ax_bars.tick_params(axis="x", length=2, width=0.5, pad=1)
    for sp in ("top", "right"):
        ax_bars.spines[sp].set_visible(False)
    ax_bars.spines["left"].set_linewidth(0.7)
    ax_bars.spines["bottom"].set_linewidth(0.6)

    # 2) Middle cell-type legend (dynamic ncol=4)
    ax_leg.axis("off")
    leg_handles = []
    for cname in ordered_cells:
        if cname == highlight_col:
            leg_handles.append(mpatches.Patch(facecolor=hl_fill, edgecolor=hl_edge, linewidth=1.1, label=cname))
        else:
            leg_handles.append(mpatches.Patch(facecolor=cell_pal[cname], edgecolor="none", label=cname))
    ax_leg.legend(
        handles=leg_handles, loc="center", ncol=4, frameon=False,
        fontsize=5.4, handlelength=0.9, handleheight=0.75, columnspacing=0.75, labelspacing=0.35,
    )

    # 3) Bottom dashed-box grouped pie charts
    ax_pies.axis("off")
    ax_pies.set_xlim(0, 1)
    ax_pies.set_ylim(0, 1)

    pie_ids = [rid for rid in ordered_ids if rid in pies_indexed.index]
    preset_boxes = style.get("pie_box_groups", [])
    boxes_resolved = []
    if preset_boxes:
        used = set()
        for grp in preset_boxes:
            items = [str(i) for i in grp.get("items", []) if str(i) in pie_ids]
            if items:
                boxes_resolved.append((str(grp.get("title", "")), items))
                used.update(items)
        rem = [rid for rid in pie_ids if rid not in used]
        if rem:
            boxes_resolved.append(("Other", rem))
    if not boxes_resolved:
        if pie_group_col in pies_indexed.columns:
            for gname, gdf in pies_indexed.loc[pie_ids].groupby(pie_group_col, sort=False):
                boxes_resolved.append((str(gname), list(gdf.index)))
        else:
            dom_map = {}
            for rid in pie_ids:
                vals = pies_indexed.loc[rid, pie_cols].to_numpy(dtype=float)
                dom = pie_cols[int(np.argmax(vals))]
                dom_map.setdefault(dom, []).append(rid)
            boxes_resolved = list(dom_map.items())

    # Layout boxes in 2 rows (max ~5-6 items per row)
    row1, row2 = [], []
    tot_items = sum(len(it) for _, it in boxes_resolved)
    cur_count = 0
    for btitle, items in boxes_resolved:
        if not row1 or (cur_count + len(items) <= math.ceil(tot_items * 0.6) and len(row1) < 3):
            row1.append((btitle, items))
            cur_count += len(items)
        else:
            row2.append((btitle, items))
    rows = [r for r in (row1, row2) if r]

    p_bbox = ax_pies.get_position()
    fig_w, fig_h = fig.get_figwidth(), fig.get_figheight()
    pie_colors_list = [pie_pal[c] for c in pie_cols]

    n_rows = len(rows)
    y_top_area = 0.90
    y_bot_area = 0.18
    row_h = (y_top_area - y_bot_area) / max(n_rows, 1)
    box_h = row_h * 0.72

    max_row_slots = max(sum(len(it) for _, it in r) + 0.35 * max(len(r) - 1, 0) for r in rows)
    slot_w = 0.96 / max(max_row_slots, 1.0)
    pie_diam_in = min(box_h * 0.68 * p_bbox.height * fig_h, slot_w * 0.86 * p_bbox.width * fig_w)
    pie_w_fig = pie_diam_in / fig_w
    pie_h_fig = pie_diam_in / fig_h

    for r_idx, r_boxes in enumerate(rows):
        by = y_top_area - (r_idx + 1) * row_h + 0.04
        bx = 0.02
        for btitle, items in r_boxes:
            bw = len(items) * slot_w
            ax_pies.text(bx, by + box_h + 0.022, btitle, fontsize=6.4, ha="left", va="bottom", color="#111111")
            ax_pies.add_patch(mpatches.Rectangle(
                (bx, by), bw, box_h,
                facecolor="none", edgecolor="#666666", linewidth=0.65, linestyle="--",
            ))
            for k, rid in enumerate(items):
                px = bx + (k + 0.5) * slot_w
                py = by + box_h * 0.42
                ax_pies.text(px, by + box_h - 0.015, rid, fontsize=5.5, ha="center", va="top", color="#111111")
                vals = pies_indexed.loc[rid, pie_cols].to_numpy(dtype=float)
                vals = np.maximum(np.nan_to_num(vals, nan=0.0), 0.0)
                if vals.sum() <= 0:
                    vals = np.ones_like(vals)
                cx_fig = p_bbox.x0 + px * p_bbox.width
                cy_fig = p_bbox.y0 + py * p_bbox.height
                pax = fig.add_axes([cx_fig - 0.5 * pie_w_fig, cy_fig - 0.5 * pie_h_fig, pie_w_fig, pie_h_fig])
                pax.pie(
                    vals, colors=pie_colors_list, startangle=90, counterclock=False,
                    wedgeprops=dict(linewidth=0.25, edgecolor="white"), radius=1.0,
                )
                pax.set_aspect("equal")
            bx += bw + 0.35 * slot_w

    # Bottom diamond legend for pie functional groups
    d_handles = [
        plt.Line2D([], [], color="none", marker="D", markersize=4.5, markerfacecolor=pie_pal[c], markeredgecolor="none", label=c)
        for c in pie_cols
    ]
    ax_pies.legend(
        handles=d_handles, loc="lower center", bbox_to_anchor=(0.5, -0.02),
        ncol=min(3, len(pie_cols)), frameon=False, fontsize=5.2,
        handletextpad=0.2, columnspacing=0.65, labelspacing=0.25,
    )
    return [ax_bars, ax_leg, ax_pies]
