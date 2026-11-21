"""Spearman gene co-expression network construction, hub 1-hop neighborhood extraction, and module scoring.

Adapted from Nirmal et al., Cancer Discovery 2022 (07_s100b_network_tcga_survival.R).
"""
from __future__ import annotations

import numpy as np
import pandas as pd
from scipy import stats


def run_spearman_coexpr_hub(
    expr_df: pd.DataFrame,
    *,
    gene_col: str = "gene_symbol",
    hub_gene: str = "S100B",
    r_threshold: float = 0.6,
    use_abs: bool = True,
) -> dict[str, pd.DataFrame]:
    """Build Spearman co-expression network (|r| >= r_threshold), extract hub 1-hop neighborhood, and score module."""
    if gene_col not in expr_df.columns:
        raise ValueError(f"Missing gene_col: {gene_col}")

    mat_df = expr_df.set_index(gene_col).apply(pd.to_numeric, errors="coerce")
    # Drop zero-variance rows
    stds = mat_df.std(axis=1, ddof=1)
    mat_df = mat_df.loc[stds > 1e-12].copy()
    if hub_gene not in mat_df.index:
        raise ValueError(f"hub_gene '{hub_gene}' not found in expressed gene matrix")

    genes = mat_df.index.astype(str).tolist()
    samples = mat_df.columns.astype(str).tolist()
    vals = mat_df.to_numpy(dtype=float)

    # Exact Spearman rank correlation matrix via row-wise average ranks + Pearson on ranks
    ranks = np.apply_along_axis(stats.rankdata, 1, vals)
    ranks_centered = ranks - ranks.mean(axis=1, keepdims=True)
    norms = np.linalg.norm(ranks_centered, axis=1, keepdims=True)
    norms = np.where(norms > 0, norms, 1.0)
    z_ranks = ranks_centered / norms
    corr_mat = np.clip(z_ranks @ z_ranks.T, -1.0, 1.0)
    np.fill_diagonal(corr_mat, 0.0)

    # Extract undirected edges meeting threshold
    metric = np.abs(corr_mat) if use_abs else corr_mat
    i_idx, j_idx = np.where(np.triu(metric >= float(r_threshold), k=1))
    edges_df = pd.DataFrame({
        "from": [genes[i] for i in i_idx],
        "to": [genes[j] for j in j_idx],
        "spearman_r": np.round(corr_mat[i_idx, j_idx], 5),
        "abs_r": np.round(np.abs(corr_mat[i_idx, j_idx]), 5),
    }).sort_values("abs_r", ascending=False).reset_index(drop=True)

    # Node degree and hub 1-hop neighborhood
    degree_arr = (metric >= float(r_threshold)).sum(axis=1).astype(int)
    hub_pos = genes.index(hub_gene)
    hub_corrs = corr_mat[hub_pos]
    hub_mask = (np.abs(hub_corrs) >= float(r_threshold)) if use_abs else (hub_corrs >= float(r_threshold))
    hub_mask[hub_pos] = True

    nodes_df = pd.DataFrame({
        "gene_symbol": genes,
        "degree": degree_arr,
        "spearman_r_hub": np.round(hub_corrs, 5),
        "in_hub_1hop": hub_mask,
    }).sort_values(["in_hub_1hop", "spearman_r_hub", "degree"], ascending=[False, False, False]).reset_index(drop=True)

    hub_neighbors_df = nodes_df[nodes_df["in_hub_1hop"]].copy().reset_index(drop=True)
    module_genes = hub_neighbors_df["gene_symbol"].tolist()

    # Per-sample module mean expression & mean Z-score
    mod_vals = mat_df.loc[module_genes].to_numpy(dtype=float)
    mod_mean = mod_vals.mean(axis=0)
    row_mu = mod_vals.mean(axis=1, keepdims=True)
    row_sd = mod_vals.std(axis=1, ddof=1, keepdims=True)
    row_sd = np.where(row_sd > 0, row_sd, 1.0)
    mod_z = ((mod_vals - row_mu) / row_sd).mean(axis=0)

    module_scores_df = pd.DataFrame({
        "sample_id": samples,
        "module_size": len(module_genes),
        "module_mean_expr": np.round(mod_mean, 5),
        "module_mean_zscore": np.round(mod_z, 5),
        "hub_expr": np.round(mat_df.loc[hub_gene].to_numpy(dtype=float), 5),
    }).sort_values("module_mean_expr", ascending=True).reset_index(drop=True)
    module_scores_df["rank_order"] = np.arange(1, len(module_scores_df) + 1)

    return {
        "edges": edges_df,
        "nodes": nodes_df,
        "hub_neighbors": hub_neighbors_df,
        "module_scores": module_scores_df,
    }
