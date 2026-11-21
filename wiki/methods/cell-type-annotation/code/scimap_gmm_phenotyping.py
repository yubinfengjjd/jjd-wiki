"""Per-image GMM gating (0-1 piecewise rescaling) and hierarchical rule-based CyCIF phenotyping.

Adapted from MIT-licensed scimap (preprocessing/rescale.py, tools/phenotype_cells.py) as used in
Nirmal et al., Cancer Discovery 2022 (PMC9167783).
"""
from __future__ import annotations

import numpy as np
import pandas as pd
from sklearn.mixture import GaussianMixture
from sklearn.preprocessing import MinMaxScaler


def run_scimap_gmm_phenotyping(
    expr_df: pd.DataFrame,
    rules_df: pd.DataFrame,
    *,
    cell_id_col: str = "cell_uid",
    image_col: str = "imageid",
    gate: float = 0.5,
    gmm_components: int = 2,
    random_state: int = 42,
) -> dict[str, pd.DataFrame]:
    """Fit per-image GMM gates, piecewise scale markers to [0, 1], and assign hierarchical phenotypes."""
    if image_col not in expr_df.columns:
        raise ValueError(f"Missing image_col: {image_col}")

    df = expr_df.reset_index(drop=True).copy()
    if cell_id_col not in df.columns:
        df[cell_id_col] = [f"cell_{i}" for i in range(len(df))]

    rule_markers = [c for c in rules_df.columns[2:] if c in df.columns]
    if not rule_markers:
        raise ValueError("No overlapping marker columns between expr_df and rules_df")

    images = df[image_col].astype(str).unique().tolist()
    gates_table = pd.DataFrame(index=rule_markers, columns=images, dtype=float)
    scaled_parts = []

    for img in images:
        idx = df.index[df[image_col].astype(str) == img]
        sub_raw = np.log1p(np.clip(df.loc[idx, rule_markers].to_numpy(dtype=float), 0.0, None))
        sub = pd.DataFrame(sub_raw, index=idx, columns=rule_markers)
        scaled_sub = pd.DataFrame(index=idx, columns=rule_markers, dtype=float)

        for mk in rule_markers:
            s = sub[mk]
            lo, hi = np.percentile(s, 0.01), np.percentile(s, 99.99)
            clipped = s.clip(lower=lo, upper=hi).to_numpy().reshape(-1, 1)
            if np.std(clipped) < 1e-9:
                g_val = float(s.max())
            else:
                gmm = GaussianMixture(
                    n_components=max(2, int(gmm_components)),
                    random_state=int(random_state),
                ).fit(clipped)
                means = np.sort(gmm.means_.flatten())
                g_val = float(np.mean([means[-2], means[-1]]))
            gates_table.loc[mk, img] = round(g_val, 5)

            s_sorted = s.sort_values()
            if (s_sorted == 0).all():
                scaled_sub[mk] = 0.0
                continue
            closest_pos = int(np.abs(s.to_numpy() - g_val).argmin())
            closest_val = s.to_numpy()[closest_pos]
            gate_cell = s_sorted.index[s_sorted == closest_val][0]

            low = s_sorted.loc[:gate_cell]
            high = s_sorted.loc[gate_cell:]
            l_sc = pd.Series(
                MinMaxScaler(feature_range=(0.0, 0.5)).fit_transform(low.to_numpy().reshape(-1, 1)).ravel(),
                index=low.index,
            )
            h_sc = pd.Series(
                MinMaxScaler(feature_range=(0.5, 1.0)).fit_transform(high.to_numpy().reshape(-1, 1)).ravel(),
                index=high.index,
            )
            comb = pd.concat([l_sc, h_sc])
            comb = comb.loc[~comb.index.duplicated(keep="first")].reindex(idx)
            scaled_sub[mk] = comb.values

        scaled_parts.append(scaled_sub)

    scaled_df = pd.concat(scaled_parts, axis=0).reindex(df.index)
    marker_set = set(scaled_df.columns)

    def _run_group(sub_data: pd.DataFrame, group_name: str) -> pd.Series:
        rules = rules_df[rules_df.iloc[:, 0] == group_name]
        parsed = {}
        for _, row in rules.iterrows():
            cell_name = str(row.iloc[1]).strip()
            spec = {"pos": [], "neg": [], "anypos": [], "anyneg": [], "allpos": [], "allneg": []}
            for col in rules.columns[2:]:
                if col not in marker_set:
                    continue
                val = row[col]
                if isinstance(val, str):
                    vnorm = val.strip().lower()
                    if vnorm in spec:
                        spec[vnorm].append(col)
            parsed[cell_name] = spec

        scores = {}
        pos_fails = {}
        neg_fails = {}
        for cell_name, p in parsed.items():
            n_non_empty = 0
            total = np.zeros(len(sub_data), dtype=float)
            if p["pos"]:
                total += sub_data[p["pos"]].mean(axis=1).to_numpy()
                n_non_empty += 1
                if len(p["pos"]) > 1:
                    pos_fails[cell_name] = (sub_data[p["pos"]] < gate).any(axis=1).to_numpy()
            if p["neg"]:
                total += (1.0 - sub_data[p["neg"]]).mean(axis=1).to_numpy()
                n_non_empty += 1
                if len(p["neg"]) > 1:
                    neg_fails[cell_name] = (sub_data[p["neg"]] > gate).any(axis=1).to_numpy()
            if p["anypos"]:
                total += sub_data[p["anypos"]].max(axis=1).to_numpy()
                n_non_empty += 1
            if p["anyneg"]:
                total += (1.0 - sub_data[p["anyneg"]]).max(axis=1).to_numpy()
                n_non_empty += 1
            if p["allpos"]:
                ap = sub_data[p["allpos"]].copy()
                sc = ap.max(axis=1).to_numpy()
                sc[(ap < gate).any(axis=1).to_numpy()] = 0.0
                total += sc + 0.01
                n_non_empty += 1
            if p["allneg"]:
                an = 1.0 - sub_data[p["allneg"]]
                sc = an.max(axis=1).to_numpy()
                sc[(an < gate).any(axis=1).to_numpy()] = 0.0
                total += sc + 0.01
                n_non_empty += 1
            scores[cell_name] = total / max(n_non_empty, 1)

        score_df = pd.DataFrame(scores, index=sub_data.index)
        rest_name = f"{group_name}-rest"
        score_df[rest_name] = (score_df < gate).all(axis=1).astype(float)
        labels = score_df.idxmax(axis=1)
        for cell_name, fail_arr in pos_fails.items():
            labels.loc[(labels == cell_name) & fail_arr] = f"likely-{cell_name}"
        for cell_name, fail_arr in neg_fails.items():
            labels.loc[(labels == cell_name) & fail_arr] = f"likely-{cell_name}"
        return labels

    pheno_table = pd.DataFrame(index=scaled_df.index)
    for grp in rules_df.iloc[:, 0].dropna().unique():
        grp_name = str(grp).strip()
        if pheno_table.empty:
            pheno_table[grp_name] = _run_group(scaled_df, grp_name)
        else:
            match_cols = [c for c in pheno_table.columns if pheno_table[c].eq(grp_name).any()]
            if not match_cols:
                pheno_table[grp_name] = np.nan
            else:
                mask = pheno_table[match_cols].eq(grp_name).any(axis=1)
                sub = scaled_df.loc[mask]
                if len(sub) > 0:
                    pheno_table.loc[sub.index, grp_name] = _run_group(sub, grp_name)

    pheno_table = pheno_table.replace(r".*-rest$", np.nan, regex=True)
    consolidated = pd.Series("Unknown", index=pheno_table.index, dtype=object)
    for col in pheno_table.columns:
        valid = pheno_table[col].notna()
        consolidated.loc[valid] = pheno_table.loc[valid, col]

    phenotyped = pd.DataFrame({
        cell_id_col: df[cell_id_col].values,
        image_col: df[image_col].astype(str).values,
        "phenotype": consolidated.astype(str).values,
    })
    counts_df = (
        phenotyped["phenotype"]
        .value_counts()
        .rename_axis("phenotype")
        .reset_index(name="n_cells")
    )
    gates_out = gates_table.reset_index().rename(columns={"index": "marker"})
    scaled_out = scaled_df.round(5).copy()
    scaled_out.insert(0, cell_id_col, df[cell_id_col].values)

    return {
        "phenotyped": phenotyped,
        "phenotype_counts": counts_df,
        "gates": gates_out,
        "scaled_markers": scaled_out,
    }
