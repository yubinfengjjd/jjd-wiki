"""GSEA running enrichment score curve + peak vertical guide + barcode rug + NES/FDR annotation (Cancer Discovery style)."""
import numpy as np


def _clean_pathway_title(raw: str) -> str:
    txt = str(raw).strip()
    for prefix in ("HALLMARK_", "KEGG_", "REACTOME_", "GOBP_"):
        if txt.startswith(prefix):
            txt = txt[len(prefix):]
    return txt.replace("_", " ")


def draw(fig, rect, tables, style):
    curves_df = tables["curves"].copy()
    summary_df = tables["summary"].copy()

    target_panel = str(style.get("panel_id", "") or "")
    filter_col = None
    for cand in ("panel", "pathway", "Description", "ID"):
        if cand in curves_df.columns:
            vals = curves_df[cand].dropna().astype(str).unique().tolist()
            if target_panel and target_panel in vals:
                filter_col = cand
                break
    if filter_col is not None:
        sub = curves_df[curves_df[filter_col].astype(str) == target_panel].copy()
    elif "panel" in curves_df.columns:
        first_p = curves_df["panel"].dropna().astype(str).iloc[0]
        target_panel = first_p
        sub = curves_df[curves_df["panel"].astype(str) == first_p].copy()
    elif "pathway" in curves_df.columns:
        first_p = curves_df["pathway"].dropna().astype(str).iloc[0]
        target_panel = first_p
        sub = curves_df[curves_df["pathway"].astype(str) == first_p].copy()
    else:
        sub = curves_df.copy()

    sub = sub.sort_values("x")
    x = sub["x"].to_numpy(dtype=float)
    es = sub["runningScore"].to_numpy(dtype=float)
    hits = sub.loc[sub["position"].astype(int) == 1, "x"].to_numpy(dtype=float)

    # Match summary row by panel / ID / Description, or fallback to row 0
    srow = None
    for cand in ("panel", "ID", "Description"):
        if cand in summary_df.columns and target_panel:
            m = summary_df[summary_df[cand].astype(str) == target_panel]
            if not m.empty:
                srow = m.iloc[0]
                break
    if srow is None and not summary_df.empty:
        srow = summary_df.iloc[0]

    ax = fig.add_axes(rect)
    line_col = style.get("line_color", "#E35B3A")
    rug_col = style.get("rug_color", "#3A3A3A")

    ax.axhline(0.0, color="#333333", linestyle="--", linewidth=0.8, zorder=1)
    peak_idx = int(np.argmax(np.abs(es)))
    peak_x = x[peak_idx]
    ax.axvline(peak_x, color=line_col, linestyle="--", linewidth=1.0, alpha=0.88, zorder=2)
    ax.plot(x, es, color=line_col, linewidth=1.7, zorder=3)

    ymin_cur = min(float(es.min()), -0.05)
    ymax_cur = max(float(es.max()), 0.30)
    span = max(ymax_cur - ymin_cur, 0.3)
    bar_bot = ymin_cur - 0.16 * span
    bar_top = ymin_cur - 0.03 * span
    if hits.size > 0:
        ax.vlines(hits, bar_bot, bar_top, color=rug_col, linewidth=0.50, alpha=0.88, zorder=2)

    title = str(style.get("title", "") or "").strip()
    if not title and srow is not None:
        raw_desc = srow.get("Description") or srow.get("ID") or ""
        title = _clean_pathway_title(raw_desc)
    elif not title and "Description" in sub.columns:
        title = _clean_pathway_title(sub["Description"].iloc[0])
    if title:
        ax.set_title(title, fontsize=7.6, pad=5, color="#111111")

    if srow is not None:
        nes_v = float(srow["NES"])
        p_mode = str(style.get("p_label_mode", "fdr")).lower()
        pv = float(srow.get("p.adjust") if ("p.adjust" in srow.index and p_mode == "fdr") else srow.get("pvalue", srow.get("p.adjust", 1.0)))
        if p_mode == "pvalue":
            p_str = "P < 0.001" if pv < 0.001 else f"P = {pv:.3f}"
        else:
            p_str = "FDR < 0.001" if pv < 0.001 else f"FDR = {pv:.2f}"
        stat_txt = f"{p_str}\nNES = {nes_v:.2f}"
        va_pos = "top" if es[peak_idx] >= 0 else "bottom"
        y_pos = 0.94 if es[peak_idx] >= 0 else 0.14
        ax.text(0.96, y_pos, stat_txt, transform=ax.transAxes, ha="right", va=va_pos, fontsize=6.4, color="#222222")

    ax.set_ylim(bar_bot - 0.04 * span, ymax_cur + 0.12 * span)
    ax.set_xlim(0, float(x.max()))
    ax.set_xlabel("Position in the ranked list of genes", fontsize=6.8, labelpad=3)
    ax.set_ylabel("Enrichment score", fontsize=7.0, labelpad=3)
    ax.tick_params(labelsize=5.8, length=2.5, pad=2)
    for sp in ax.spines.values():
        sp.set_linewidth(0.75)
        sp.set_color("#222222")
    return [ax]
