"""Multi-stage boxplot with jitter points and red significance brackets (Cancer Discovery style)."""
import numpy as np
from scipy import stats

STAGE_PALETTE = {
    "N": "#4A6984",
    "Normal": "#4A6984",
    "P": "#D97941",
    "Precursor": "#D97941",
    "MIS": "#529E66",
    "IM": "#C0392B",
    "EM": "#7F7F7F",
}
FALLBACK_COLS = ["#4A6984", "#D97941", "#529E66", "#C0392B", "#7A68A6", "#8C564B"]


def _sig_str(p):
    if not np.isfinite(p):
        return "ns"
    if p < 0.001:
        return "***"
    if p < 0.01:
        return "**"
    if p < 0.05:
        return "*"
    return "ns"


def draw(fig, rect, tables, style):
    df = tables["data"]
    ax = fig.add_axes(rect)
    rng = np.random.default_rng(42)

    pref_order = ["N", "P", "MIS", "IM", "EM", "Normal", "Precursor"]
    avail = [s for s in pref_order if s in df["stage"].values]
    for s in df["stage"].unique():
        if s not in avail:
            avail.append(s)

    box_data = [df.loc[df["stage"] == s, "value"].dropna().to_numpy(float) for s in avail]
    colors = [STAGE_PALETTE.get(s, FALLBACK_COLS[i % len(FALLBACK_COLS)]) for i, s in enumerate(avail)]
    positions = np.arange(1, len(avail) + 1)

    bp = ax.boxplot(
        box_data,
        positions=positions,
        widths=0.48,
        patch_artist=True,
        showfliers=False,
        medianprops=dict(color="#222222", linewidth=1.1),
        boxprops=dict(linewidth=0.85, edgecolor="#333333"),
        whiskerprops=dict(linewidth=0.85, color="#333333"),
        capprops=dict(linewidth=0.85, color="#333333"),
    )
    for patch, col in zip(bp["boxes"], colors):
        patch.set_facecolor(col)
        patch.set_alpha(0.88)

    pt_size = float(style.get("point_size", 14.0))
    for idx, vals in enumerate(box_data, start=1):
        if len(vals):
            jitter = rng.uniform(-0.12, 0.12, size=len(vals))
            ax.scatter(np.full(len(vals), idx) + jitter, vals, color="#111111", s=pt_size, alpha=0.85, zorder=4)

    ymax = max([np.max(v) if len(v) else 1.0 for v in box_data])
    step_y = ymax * 0.085
    for i in range(len(avail) - 1):
        v1, v2 = box_data[i], box_data[i + 1]
        _, pv = stats.ttest_ind(v1, v2, equal_var=False) if (len(v1) > 1 and len(v2) > 1) else (0.0, 1.0)
        sl = _sig_str(pv)
        ylvl = ymax * 0.96 + i * step_y
        col_s = "#E31A1C" if sl != "ns" else "#333333"
        ax.plot([i + 1, i + 2], [ylvl, ylvl], color=col_s, lw=0.95)
        ax.text(
            i + 1.5, ylvl + ymax * 0.012, sl, ha="center", va="bottom",
            fontsize=8.5 if sl != "ns" else 7.8, color=col_s,
            fontweight="bold" if sl != "ns" else "normal",
        )

    ax.set_title(style.get("title", "S100A expression"), fontsize=9.5, pad=12)
    ax.set_xticks(positions)
    ax.set_xticklabels(avail, fontsize=8.5)
    ax.set_ylim(-0.04 * ymax, ymax * 1.25)
    ax.set_xlim(0.4, len(avail) + 0.6)
    ax.set_ylabel(style.get("ylabel", "Fraction positive cells"), fontsize=8.5, labelpad=4)
    ax.tick_params(axis="y", labelsize=8.0)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.spines["left"].set_linewidth(0.8)
    ax.spines["bottom"].set_linewidth(0.8)
    return ax
