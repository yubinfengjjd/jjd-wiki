"""Preranked Gene Set Enrichment Analysis (GSEA): Running ES, NES, and empirical permutation p-values.

Implements Subramanian et al. (PNAS 2005) weighted preranked GSEA for bulk/mrSEQ ranked gene lists
as used in Nirmal et al., Cancer Discovery 2022 (06_mrseq_deseq2_pca_gsea.R).
"""
from __future__ import annotations

import numpy as np
import pandas as pd


def _bh_adjust(pvals: np.ndarray) -> np.ndarray:
    m = len(pvals)
    if m == 0:
        return np.array([], dtype=float)
    order = np.argsort(pvals)
    ranked = pvals[order]
    adj = ranked * m / np.arange(1, m + 1, dtype=float)
    adj = np.minimum.accumulate(adj[::-1])[::-1]
    adj = np.clip(adj, 0.0, 1.0)
    out = np.empty(m, dtype=float)
    out[order] = adj
    return out


def _running_es(stats_arr: np.ndarray, hit_mask: np.ndarray, weight: float) -> tuple[np.ndarray, float, int]:
    n_total = len(stats_arr)
    n_hit = int(hit_mask.sum())
    n_miss = n_total - n_hit
    if n_hit == 0 or n_miss == 0:
        return np.zeros(n_total, dtype=float), 0.0, 0

    weights = np.where(hit_mask, np.abs(stats_arr) ** weight, 0.0)
    nr = float(weights.sum())
    if nr <= 0:
        weights = hit_mask.astype(float)
        nr = float(n_hit)

    p_hit = np.cumsum(weights) / nr
    p_miss = np.cumsum((~hit_mask).astype(float)) / float(n_miss)
    running = p_hit - p_miss

    max_idx = int(np.argmax(running))
    min_idx = int(np.argmin(running))
    if abs(running[max_idx]) >= abs(running[min_idx]):
        return running, float(running[max_idx]), max_idx
    return running, float(running[min_idx]), min_idx


def run_preranked_gsea(
    ranked_df: pd.DataFrame,
    gene_sets: dict[str, list[str]],
    *,
    gene_col: str = "gene_symbol",
    stat_col: str = "stat",
    weight: float = 1.0,
    n_perm: int = 500,
    min_size: int = 5,
    max_size: int = 500,
    seed: int = 42,
) -> dict[str, pd.DataFrame]:
    """Compute Preranked GSEA Running ES, NES, empirical permutation p-value, and leading-edge genes."""
    for col in (gene_col, stat_col):
        if col not in ranked_df.columns:
            raise ValueError(f"Missing required column: {col}")

    clean = (
        ranked_df[[gene_col, stat_col]]
        .dropna()
        .drop_duplicates(subset=[gene_col])
        .sort_values(stat_col, ascending=False)
        .reset_index(drop=True)
    )
    genes = clean[gene_col].astype(str).to_numpy()
    stats_arr = clean[stat_col].to_numpy(dtype=float)
    abs_w = np.abs(stats_arr) ** float(weight)
    n_total = len(genes)

    rng = np.random.default_rng(int(seed))
    summary_rows = []
    curve_parts = []

    for gs_name, gs_genes in gene_sets.items():
        gs_set = {str(g) for g in gs_genes}
        hit_mask = np.isin(genes, list(gs_set))
        n_hit = int(hit_mask.sum())
        if n_hit < int(min_size) or n_hit > int(max_size) or n_hit >= n_total:
            continue

        running, es, peak_idx = _running_es(stats_arr, hit_mask, float(weight))

        # Vectorized gene-label permutation null for empirical p-value & NES
        null_es = np.empty(int(n_perm), dtype=float)
        n_miss = n_total - n_hit
        miss_step = 1.0 / float(n_miss)
        for b in range(int(n_perm)):
            perm_hits = rng.choice(n_total, size=n_hit, replace=False)
            pmask = np.zeros(n_total, dtype=bool)
            pmask[perm_hits] = True
            w_perm = np.where(pmask, abs_w, 0.0)
            nr = float(w_perm.sum())
            if nr <= 0:
                w_perm = pmask.astype(float)
                nr = float(n_hit)
            step = (w_perm / nr) - np.where(pmask, 0.0, miss_step)
            rc = np.cumsum(step)
            hi = float(rc.max())
            lo = float(rc.min())
            null_es[b] = hi if abs(hi) >= abs(lo) else lo

        if es >= 0:
            pos_null = null_es[null_es >= 0]
            mean_pos = float(pos_null.mean()) if len(pos_null) > 0 and pos_null.mean() > 1e-12 else 1.0
            nes = es / mean_pos
            pval = float((np.sum(pos_null >= es) + 1) / (len(pos_null) + 1))
            lead_mask = hit_mask.copy()
            lead_mask[peak_idx + 1 :] = False
        else:
            neg_null = null_es[null_es < 0]
            mean_neg = float(np.abs(neg_null).mean()) if len(neg_null) > 0 and np.abs(neg_null).mean() > 1e-12 else 1.0
            nes = es / mean_neg
            pval = float((np.sum(neg_null <= es) + 1) / (len(neg_null) + 1))
            lead_mask = hit_mask.copy()
            lead_mask[:peak_idx] = False

        leading_genes = genes[lead_mask].tolist()
        summary_rows.append({
            "pathway": gs_name,
            "set_size": n_hit,
            "ES": round(es, 5),
            "NES": round(nes, 5),
            "pvalue": round(pval, 6),
            "peak_rank": int(peak_idx + 1),
            "n_leading_edge": len(leading_genes),
            "leading_edge": "/".join(leading_genes[:30]),
        })

        curve_parts.append(pd.DataFrame({
            "pathway": gs_name,
            "x": np.arange(1, n_total + 1),
            "gene_symbol": genes,
            "runningScore": np.round(running, 6),
            "position": hit_mask.astype(int),
        }))

    summary_df = pd.DataFrame(summary_rows)
    if len(summary_df) > 0:
        summary_df["p_adjust"] = np.round(_bh_adjust(summary_df["pvalue"].to_numpy(dtype=float)), 6)
        summary_df = summary_df.sort_values(["pvalue", "NES"], ascending=[True, False]).reset_index(drop=True)

    curves_df = pd.concat(curve_parts, ignore_index=True) if curve_parts else pd.DataFrame()
    return {
        "summary": summary_df,
        "running_curves": curves_df,
    }
