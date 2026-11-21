"""Distance-weighted spatial lag feature matrix and Tumor Cell Community (TCC) clustering.

Adapted from MIT-licensed scimap (spatial_expression, spatial_cluster) as used in
Nirmal et al., Cancer Discovery 2022 (PMC9167783).
"""
from __future__ import annotations

import numpy as np
import pandas as pd
from sklearn.cluster import KMeans
from sklearn.neighbors import BallTree


def run_spatial_lag_tcc(
    cells_df: pd.DataFrame,
    feature_cols: list[str],
    *,
    x_col: str = "X_um",
    y_col: str = "Y_um",
    fov_col: str = "fov_id",
    cell_id_col: str = "cell_uid",
    radius: float = 20.0,
    n_clusters: int = 6,
    random_state: int = 42,
) -> dict[str, pd.DataFrame]:
    """Compute inverse-distance-normalized spatial lag matrix and KMeans TCC communities."""
    required = {x_col, y_col, fov_col} | set(feature_cols)
    missing = required - set(cells_df.columns)
    if missing:
        raise ValueError(f"Missing required columns: {sorted(missing)}")

    df = cells_df.reset_index(drop=True).copy()
    if cell_id_col not in df.columns:
        df[cell_id_col] = [f"cell_{i}" for i in range(len(df))]

    lag_parts = []
    for _, grp in df.groupby(fov_col, sort=False):
        coords = grp[[x_col, y_col]].to_numpy(dtype=float)
        expr = grp[feature_cols].to_numpy(dtype=float)
        n = len(grp)
        tree = BallTree(coords, metric="euclidean")
        ind, dist = tree.query_radius(coords, r=float(radius), return_distance=True)

        weights = np.zeros((n, n), dtype=float)
        for row, (cols, vals) in enumerate(zip(ind, dist)):
            mask = cols != row
            cols = cols[mask]
            vals = vals[mask]
            if len(vals) == 0:
                weights[row, row] = 1.0
            elif len(vals) == 1:
                weights[row, cols[0]] = 1.0
            else:
                span = float(vals.max() - vals.min())
                if span > 1e-9:
                    w = (vals.max() - vals) / span
                else:
                    w = np.ones_like(vals, dtype=float)
                w_sum = float(w.sum())
                w = w / w_sum if w_sum > 0 else np.ones_like(vals, dtype=float) / len(vals)
                weights[row, cols] = w

        lag_mat = weights @ expr
        lag_parts.append(pd.DataFrame(lag_mat, index=grp.index, columns=feature_cols))

    lag_df = pd.concat(lag_parts, axis=0).reindex(df.index)
    n_clust_eff = max(2, min(int(n_clusters), len(df)))
    km = KMeans(n_clusters=n_clust_eff, random_state=int(random_state), n_init=10)
    raw_lbl = km.fit_predict(lag_df.to_numpy(dtype=float))

    order = pd.Series(raw_lbl).value_counts().index.tolist()
    lbl_map = {old: f"TCC{i + 1}" for i, old in enumerate(order)}
    tcc_labels = pd.Series(raw_lbl).map(lbl_map).to_numpy()

    assignments = pd.DataFrame({
        cell_id_col: df[cell_id_col].values,
        fov_col: df[fov_col].values,
        x_col: df[x_col].values,
        y_col: df[y_col].values,
        "TCC": tcc_labels,
    })

    profiles = lag_df.copy()
    profiles["TCC"] = tcc_labels
    tcc_profiles = profiles.groupby("TCC", sort=True)[feature_cols].median().reset_index()

    lag_out = lag_df.copy()
    lag_out.insert(0, cell_id_col, df[cell_id_col].values)

    return {
        "lag_matrix": lag_out,
        "assignments": assignments,
        "tcc_profiles": tcc_profiles,
    }
