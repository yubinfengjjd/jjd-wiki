"""Tumor-stroma boundary spatial fluorescence intensity gradient line profile (Cancer Discovery style)."""
import numpy as np

MARKER_COLORS = {
    "SOX10": ("#2B3058", "SOX10"),
    "HLADPB1": ("#E86850", "HLADPB1 / MHC-II"),
    "CD11c": ("#3853A4", "CD11C"),
    "HLADR": ("#D4A017", "HLA-DR"),
    "PDL1": ("#2CA298", "PD-L1"),
    "CD8a": ("#C84B93", "CD8A"),
}
FALLBACK_COLS = ["#2B3058", "#E86850", "#3853A4", "#D4A017", "#2CA298"]


def draw(fig, rect, tables, style):
    df = tables["gradient"].sort_values("dist_bin_um").copy()
    ax = fig.add_axes(rect)

    x = df["dist_bin_um"].to_numpy(float)
    ax.axvline(0.0, color="#264C96", linestyle="--", linewidth=1.1, zorder=1)
    ax.axvline(-15.0, color="#C8D6E5", linestyle="--", linewidth=0.8, zorder=1)
    ax.axvline(15.0, color="#C8D6E5", linestyle="--", linewidth=0.8, zorder=1)

    req_markers = style.get("markers", ["SOX10", "HLADPB1", "CD11c"])
    avail_m = [m for m in req_markers if m in df.columns]
    if not avail_m:
        avail_m = [c for c in df.columns if c not in ("dist_bin_um", "compartment")][:3]

    lw = float(style.get("line_width", 2.0))
    ymax_data = 1.0
    for i, m in enumerate(avail_m):
        y = df[m].to_numpy(float)
        ymax_data = max(ymax_data, float(np.nanmax(y)))
        col, lbl = MARKER_COLORS.get(m, (FALLBACK_COLS[i % len(FALLBACK_COLS)], m))
        ax.plot(x, y, color=col, linewidth=lw, label=lbl, zorder=3 + i)

    ymax = ymax_data * 1.18
    ax.set_xlim(x.min() - 5, x.max() + 5)
    ax.set_ylim(0, ymax)
    ax.set_xticks([-100, -50, 0, 50, 100])
    ax.set_xticklabels(["100", "50", "0", "50", "100"], fontsize=7.8)
    ax.set_yticks([0.0, 0.5, 1.0])
    ax.set_yticklabels(["0.0", "0.5", "1.0"], fontsize=7.8)

    ax.annotate("", xy=(-95, ymax * 0.93), xytext=(-6, ymax * 0.93),
                arrowprops=dict(arrowstyle="->", color="#222222", lw=0.85))
    ax.text(-50, ymax * 0.95, "Tumor", ha="center", va="bottom", fontsize=7.8)
    ax.annotate("", xy=(95, ymax * 0.93), xytext=(6, ymax * 0.93),
                arrowprops=dict(arrowstyle="->", color="#222222", lw=0.85))
    ax.text(50, ymax * 0.95, "Stroma", ha="center", va="bottom", fontsize=7.8)

    ax.set_xlabel(style.get("xlabel", "Distance from boundary (μm)"), fontsize=8.5, labelpad=4)
    ax.set_ylabel(style.get("ylabel", "Fluorescence intensity"), fontsize=8.5, labelpad=4)
    ax.legend(loc="lower left", frameon=False, fontsize=7.2, handlelength=1.2, labelspacing=0.3)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.spines["left"].set_linewidth(0.8)
    ax.spines["bottom"].set_linewidth(0.8)
    return ax
