"""Minimalist monochrome brown/grey DESeq2 volcano plot (Cancer Discovery style)."""
import numpy as np
import pandas as pd


def draw(fig, rect, tables, style):
    deg_df = tables["deg"]
    ax = fig.add_axes(rect)

    df = deg_df.dropna(subset=["log2FoldChange", "padj"]).copy()
    p_clipped = np.clip(df["padj"].to_numpy(dtype=float), 1e-120, 1.0)
    df["neg_log10_padj"] = -np.log10(p_clipped)
    lfc = df["log2FoldChange"].to_numpy(dtype=float)
    yval = df["neg_log10_padj"].to_numpy(dtype=float)

    lfc_cut = float(style.get("lfc_cutoff", 2.0))
    p_cut = float(style.get("padj_cutoff", 0.05))
    sig_col = style.get("sig_color", "#9E623E")
    ns_col = style.get("nonsig_color", "#BDBDBD")

    sig_mask = (np.abs(lfc) >= lfc_cut) & (df["padj"].to_numpy(float) < p_cut)
    ax.scatter(lfc[~sig_mask], yval[~sig_mask], s=8.0, color=ns_col, alpha=0.55, edgecolors="none", rasterized=True, zorder=2)
    ax.scatter(lfc[sig_mask], yval[sig_mask], s=12.0, color=sig_col, alpha=0.84, edgecolors="none", rasterized=True, zorder=3)

    ax.axhline(-np.log10(p_cut), color="#777777", linestyle="--", linewidth=0.85, zorder=1)
    ax.axvline(-lfc_cut, color="#777777", linestyle="--", linewidth=0.85, zorder=1)
    ax.axvline(lfc_cut, color="#777777", linestyle="--", linewidth=0.85, zorder=1)

    top_n = int(style.get("top_n_each_side", 6))
    top_pos = df[(df["log2FoldChange"] > lfc_cut) & (df["padj"] < p_cut)].sort_values("neg_log10_padj", ascending=False).head(top_n)
    top_neg = df[(df["log2FoldChange"] < -lfc_cut) & (df["padj"] < p_cut)].sort_values("neg_log10_padj", ascending=False).head(max(0, top_n - 1))
    to_label = pd.concat([top_pos, top_neg], ignore_index=True)

    placed = []
    for _, row in to_label.iterrows():
        gx, gy = float(row["log2FoldChange"]), float(row["neg_log10_padj"])
        tx = gx + (1.8 if gx < 0 else -1.8)
        ty = gy
        for px, py in placed:
            if abs(tx - px) < 11.0 and abs(ty - py) < 8.5:
                ty = py - 8.5 if ty > 25 else py + 8.5
        placed.append((tx, ty))
        ha = "left" if gx < 0 else "right"
        ax.text(tx, ty, str(row["gene_symbol"]), fontsize=7.2, style="italic", color="#111111", ha=ha, va="center", zorder=5)

    ax.set_xlim(lfc.min() - 10, lfc.max() + 10)
    ax.set_ylim(-4, yval.max() * 1.08)
    ax.set_xlabel("Log$_2$ fold change", fontsize=8.8, labelpad=4)
    ax.set_ylabel("−Log$_{10}$ $P_{adj}$", fontsize=8.8, labelpad=4)
    ax.tick_params(labelsize=7.8, length=3, pad=2)
    for sp in ax.spines.values():
        sp.set_linewidth(0.8)
        sp.set_color("#222222")
    return ax
