"""Clean 100% stacked proportion bar chart across stages (Cancer Discovery style)."""
import matplotlib.patches as mpatches
import numpy as np

RCN_COLORS = {
    "RCN1": "#EBB39A",
    "RCN2": "#2D9A93",
    "RCN3": "#52B87A",
    "RCN4": "#C3DEC0",
    "RCN5": "#EFE738",
    "RCN6": "#4FC4EA",
    "RCN7": "#5692BC",
    "RCN8": "#F29954",
    "RCN9": "#EB2629",
    "RCN10": "#C7C7C7",
}
FALLBACK_PAL = ["#2D9A93", "#EBB39A", "#52B87A", "#EFE738", "#4FC4EA", "#5692BC", "#F29954", "#EB2629", "#C3DEC0", "#C7C7C7"]


def draw(fig, rect, tables, style):
    prop_df = tables["proportions"]
    ax = fig.add_axes(rect)

    stage_map = [("Normal", "N"), ("Precursor", "P"), ("MIS", "MIS"), ("IM", "IM"), ("EM", "EM")]
    avail = [(sf, sl) for sf, sl in stage_map if sf in prop_df["Stage"].values]
    for s in prop_df["Stage"].unique():
        if s not in [x[0] for x in avail]:
            avail.append((s, str(s)))

    cat_cols = [c for c in prop_df.columns if c != "Stage"]
    pref_rcn = [f"RCN{i}" for i in range(1, 11)]
    if all(r in cat_cols for r in pref_rcn):
        cat_cols = pref_rcn + [c for c in cat_cols if c not in pref_rcn]

    x_pos = np.arange(len(avail))
    bottoms = np.zeros(len(avail))
    bw = float(style.get("bar_width", 0.72))

    for i, cat in enumerate(cat_cols):
        col = RCN_COLORS.get(cat, FALLBACK_PAL[i % len(FALLBACK_PAL)])
        vals = []
        for sf, _ in avail:
            row = prop_df[prop_df["Stage"] == sf]
            vals.append(float(row[cat].iloc[0]) if not row.empty else 0.0)
        vals = np.array(vals, dtype=float)
        ax.bar(x_pos, vals, bottom=bottoms, width=bw, color=col, edgecolor="white", linewidth=0.4, label=cat)
        bottoms += vals

    ax.set_xticks(x_pos)
    ax.set_xticklabels([sl for _, sl in avail], fontsize=8.5)
    ax.set_yticks([0.0, 0.5, 1.0])
    ax.set_yticklabels(["0", "0.5", "1.0"], fontsize=8.0)
    ax.set_ylim(0, 1.02)
    ax.set_ylabel(style.get("ylabel", "Proportion"), fontsize=8.5, labelpad=4)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.spines["left"].set_linewidth(0.8)
    ax.spines["bottom"].set_linewidth(0.8)

    handles = [
        mpatches.Patch(facecolor=RCN_COLORS.get(c, FALLBACK_PAL[i % len(FALLBACK_PAL)]), label=c)
        for i, c in enumerate(cat_cols)
    ]
    ax.legend(
        handles=handles, loc="lower center", bbox_to_anchor=(0.48, 1.03),
        ncol=int(style.get("legend_cols", 4)), frameon=False, fontsize=7.0,
        handlelength=1.0, handleheight=0.7, handletextpad=0.3, columnspacing=0.6,
    )
    return ax
