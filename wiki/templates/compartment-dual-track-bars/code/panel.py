"""Dual-compartment (Epidermis vs Dermis) multi-track horizontal stacked bar comparison (Cancer Discovery style)."""
import matplotlib.patches as mpatches
from matplotlib.gridspec import GridSpecFromSubplotSpec
import numpy as np
import pandas as pd


CANON_TRACKS = [
    ("Stroma", [
        ("Ker", "Keratinocytes", "#8A6240"),
        ("LC", "Langerhans", "#D3E298"),
        ("Mast cell", "Mast cells", "#C8D7E8"),
        ("Endo", "Endothelial", "#CBE4D0"),
        ("Mel", "Melanocytes", "#5B2C82"),
        ("Unknown", "Other/Stroma", "#DCDCDC"),
    ]),
    ("Myeloid", [
        ("PD-L1+ DC", "PDL1+ DCs", "#1A5B8C"),
        ("PD-L1+ mac", "PDL1+ Macs", "#2CA298"),
        ("DC", "Dendritic", "#227BA3"),
        ("CD11C+ mac", "CD11C+ macs", "#74A892"),
        ("Mac", "Macrophages", "#98CD87"),
    ]),
    ("Lymphoid", [
        ("Tex", "Exhausted", "#EA7AA6"),
        ("CTL", "CTL", "#F2C84B"),
        ("Treg", "Tregs", "#E3256B"),
        ("Th", "T helper", "#F08C4B"),
        ("PD1+ CTL", "PD1+ CTL", "#D95F43"),
    ]),
]

FALLBACK_COLORS = [
    "#1F78B4", "#33A02C", "#FF7F00", "#6A3D9A", "#E31A1C",
    "#A6CEE3", "#B2DF8A", "#FDBF6F", "#CAB2D6", "#FB9A99",
]


def _build_tracks(numeric_cols):
    known = {}
    tracks = []
    for trk_name, items in CANON_TRACKS:
        present = [(c, lbl, col) for c, lbl, col in items if c in numeric_cols]
        if present:
            tracks.append((trk_name, present))
            for c, _, _ in present:
                known[c] = col
    extra = [c for c in numeric_cols if c not in known]
    if extra:
        extra_items = [
            (c, c, FALLBACK_COLORS[i % len(FALLBACK_COLORS)])
            for i, c in enumerate(extra)
        ]
        tracks.append(("Other", extra_items))
    return tracks


def _draw_track_bars(ax, row: pd.Series | None, tracks, show_ylabels: bool = False, show_xticks: bool = False):
    ax.set_xlim(0.0, 1.0)
    ax.set_ylim(len(tracks), 0)
    if row is not None and not row.empty:
        for ti, (_, items) in enumerate(tracks):
            vals = [max(float(row[c]), 0.0) if (c in row.index and pd.notna(row[c])) else 0.0 for c, _, _ in items]
            tot = sum(vals)
            vals = [v / tot if tot > 0 else 0.0 for v in vals]
            xc = 0.0
            for (_, _, col_hex), v in zip(items, vals):
                if v > 1e-6:
                    ax.add_patch(mpatches.Rectangle(
                        (xc, ti + 0.08), v, 0.84,
                        facecolor=col_hex, edgecolor="white", linewidth=0.25,
                    ))
                    xc += v
    if show_xticks:
        ax.set_xticks([0.0, 0.5, 1.0])
        ax.set_xticklabels(["0", "0.5", "1.0"], fontsize=5.4)
        ax.tick_params(axis="x", length=2, width=0.5, pad=1)
    else:
        ax.set_xticks([])
    if show_ylabels:
        ax.set_yticks([i + 0.5 for i in range(len(tracks))])
        ax.set_yticklabels([t for t, _ in tracks], fontsize=5.8)
        ax.yaxis.tick_right()
        ax.tick_params(axis="y", length=0, pad=3)
    else:
        ax.set_yticks([])
    for sp in ax.spines.values():
        sp.set_linewidth(0.55)
        sp.set_color("#333333")


def draw(fig, rect, tables, style):
    df = tables["composition"].copy()

    stage_col = style.get("stage_col", "Stage")
    if stage_col not in df.columns:
        str_cols = [c for c in df.columns if not pd.api.types.is_numeric_dtype(df[c])]
        stage_col = str_cols[0] if str_cols else df.columns[0]

    comp_col = style.get("compartment_col", "compartment_proxy")
    if comp_col not in df.columns:
        if "compartment" in df.columns:
            comp_col = "compartment"
        else:
            str_cols = [c for c in df.columns if c != stage_col and not pd.api.types.is_numeric_dtype(df[c])]
            comp_col = str_cols[0] if str_cols else stage_col

    df[stage_col] = df[stage_col].astype(str)
    df[comp_col] = df[comp_col].astype(str)

    numeric_cols = [c for c in df.columns if c not in (stage_col, comp_col) and pd.api.types.is_numeric_dtype(df[c])]
    tracks = _build_tracks(numeric_cols)

    avail_stages = list(dict.fromkeys(df[stage_col].tolist()))
    preset_stages = [str(s) for s in style.get("stage_order", [])]
    if preset_stages and any(s in avail_stages for s in preset_stages):
        stages = [s for s in preset_stages if s in avail_stages]
    else:
        stages = avail_stages

    avail_comps = list(dict.fromkeys(df[comp_col].tolist()))
    top_comp = str(style.get("top_compartment", "Epidermis"))
    bot_comp = str(style.get("bottom_compartment", "Dermis"))
    if top_comp not in avail_comps:
        top_comp = avail_comps[0]
    if bot_comp not in avail_comps:
        bot_comp = avail_comps[1] if len(avail_comps) > 1 else avail_comps[0]

    stage_labels = style.get("stage_labels", {})
    top_color = style.get("top_color", "#3E7A56")
    bot_color = style.get("bottom_color", "#D98B38")

    n_cols = max(len(stages), 1)
    gs_outer = fig.add_gridspec(1, 1, left=rect[0], bottom=rect[1], right=rect[0] + rect[2], top=rect[1] + rect[3])
    sub_gs = GridSpecFromSubplotSpec(
        3, n_cols,
        subplot_spec=gs_outer[0, 0],
        height_ratios=[1.0, 1.0, 0.72],
        hspace=0.22,
        wspace=0.10,
    )

    axes = []
    for ci, st_k in enumerate(stages):
        ax_top = fig.add_subplot(sub_gs[0, ci])
        ax_bot = fig.add_subplot(sub_gs[1, ci])
        axes.extend([ax_top, ax_bot])

        top_sub = df[(df[stage_col] == st_k) & (df[comp_col] == top_comp)]
        bot_sub = df[(df[stage_col] == st_k) & (df[comp_col] == bot_comp)]
        top_row = top_sub[numeric_cols].mean() if not top_sub.empty else None
        bot_row = bot_sub[numeric_cols].mean() if not bot_sub.empty else None

        _draw_track_bars(ax_top, top_row, tracks, show_ylabels=(ci == n_cols - 1), show_xticks=False)
        _draw_track_bars(ax_bot, bot_row, tracks, show_ylabels=(ci == n_cols - 1), show_xticks=True)

        ax_top.set_title(stage_labels.get(st_k, st_k), fontsize=7.4, pad=5, color="#111111")
        if ci == 0:
            ax_top.set_ylabel(top_comp.upper(), fontsize=6.4, color=top_color, fontweight="bold", labelpad=5)
            ax_bot.set_ylabel(bot_comp.upper(), fontsize=6.4, color=bot_color, fontweight="bold", labelpad=5)
        if ci == n_cols // 2:
            ax_bot.set_xlabel("Fraction of cells", fontsize=6.4, labelpad=2, color="#222222")

    ax_leg = fig.add_subplot(sub_gs[2, :])
    ax_leg.axis("off")
    handles = []
    for _, items in tracks:
        for _, lbl, col_hex in items:
            handles.append(mpatches.Patch(facecolor=col_hex, label=lbl))
    ax_leg.legend(
        handles=handles, loc="center", ncol=min(6, max(len(handles), 1)), frameon=False,
        fontsize=5.2, handlelength=0.9, handleheight=0.7, columnspacing=0.7, labelspacing=0.25,
    )
    axes.append(ax_leg)
    return axes
