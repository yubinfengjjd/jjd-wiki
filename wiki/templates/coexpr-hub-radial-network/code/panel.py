"""Hub-centered co-expression network with burnt-orange 1-step module and radial pill labels."""
from matplotlib.collections import LineCollection
import numpy as np
import pandas as pd


def draw(fig, rect, tables, style):
    nodes_df = tables["nodes"].copy()
    edges_df = tables["edges"].copy()
    hub_gene = str(style.get("hub_gene", "S100B")).strip()
    r_thresh = float(style.get("corr_threshold", style.get("r_threshold", 0.6)))

    gs_outer = fig.add_gridspec(1, 1, left=rect[0], bottom=rect[1], right=rect[0] + rect[2], top=rect[1] + rect[3])
    ax = fig.add_subplot(gs_outer[0, 0])

    nodes_df["gene_symbol"] = nodes_df["gene_symbol"].astype(str).str.strip()
    pos = {str(r["gene_symbol"]): (float(r["x"]), float(r["y"])) for _, r in nodes_df.iterrows()}

    # Filter edges by correlation threshold (weight / r / corr >= r_thresh)
    weight_col = next((c for c in ("weight", "r", "corr", "pearson_r") if c in edges_df.columns), None)
    if weight_col is not None:
        w_vals = pd.to_numeric(edges_df[weight_col], errors="coerce")
        edges_filtered = edges_df[w_vals >= r_thresh].copy()
    else:
        edges_filtered = edges_df.copy()

    segs = []
    deg_counts = {g: 0 for g in pos}
    hub_neighbors = set()
    for _, er in edges_filtered.iterrows():
        u = str(er["from"]).strip()
        v = str(er["to"]).strip()
        if u in pos and v in pos:
            segs.append([pos[u], pos[v]])
            deg_counts[u] = deg_counts.get(u, 0) + 1
            deg_counts[v] = deg_counts.get(v, 0) + 1
            if u == hub_gene:
                hub_neighbors.add(v)
            elif v == hub_gene:
                hub_neighbors.add(u)

    if hub_gene in pos:
        hub_neighbors.add(hub_gene)

    if segs:
        lc = LineCollection(segs, colors="#9E9E9E", linewidths=0.55, alpha=0.55, zorder=1)
        ax.add_collection(lc)

    # Dynamically compute 1-step hub module membership from filtered edges around hub_gene
    nodes_df["dyn_degree"] = nodes_df["gene_symbol"].map(lambda g: deg_counts.get(g, 0))
    if len(hub_neighbors) > 1:
        in_mod = nodes_df["gene_symbol"].isin(hub_neighbors)
    elif "in_hub_1step" in nodes_df.columns:
        in_mod = nodes_df["in_hub_1step"].astype(bool)
    elif hub_gene == "S100B" and "in_s100b_1step" in nodes_df.columns:
        in_mod = nodes_df["in_s100b_1step"].astype(bool)
    else:
        in_mod = nodes_df["gene_symbol"] == hub_gene

    bg = nodes_df[~in_mod]
    fg = nodes_df[in_mod]
    hub_df = nodes_df[nodes_df["gene_symbol"] == hub_gene]

    ax.scatter(bg["x"], bg["y"], s=26, c="#BDBDBD", edgecolors="#666666", linewidths=0.45, zorder=2)
    ax.scatter(fg["x"], fg["y"], s=42, c="#D95F02", edgecolors="#444444", linewidths=0.55, zorder=3)
    if not hub_df.empty:
        ax.scatter(hub_df["x"], hub_df["y"], s=72, c="#C44100", edgecolors="#111111", linewidths=0.80, zorder=4)

    cx = float(fg["x"].median()) if not fg.empty else float(nodes_df["x"].median())
    cy = float(fg["y"].median()) if not fg.empty else float(nodes_df["y"].median())
    half_w = float(style.get("half_w", 11.5))
    half_h = float(style.get("half_h", 10.5))

    # Select radial pill labels dynamically when hub_gene or threshold changes
    use_preset_labels = (
        hub_gene == "S100B"
        and "is_key_label" in nodes_df.columns
        and nodes_df.loc[in_mod, "is_key_label"].astype(bool).any()
    )
    if use_preset_labels:
        lbl_df = nodes_df[nodes_df["is_key_label"].astype(bool) & (in_mod | (nodes_df["gene_symbol"] == hub_gene))].copy()
    else:
        cand = fg if not fg.empty else nodes_df
        lbl_df = cand.sort_values(["dyn_degree", "gene_symbol"], ascending=[False, True]).head(8).copy()
        if not hub_df.empty and hub_gene not in set(lbl_df["gene_symbol"]):
            lbl_df = pd.concat([hub_df, lbl_df.iloc[:-1]], ignore_index=True)

    # Radial non-overlapping label ring sorted by polar angle around module centroid
    lbl_df = lbl_df.copy()
    lbl_df["ang"] = np.arctan2(lbl_df["y"] - cy, lbl_df["x"] - cx)
    lbl_df = lbl_df.sort_values("ang").reset_index(drop=True)
    n_lbl = len(lbl_df)
    rx, ry = half_w * 0.54, half_h * 0.56
    for idx, (_, row) in enumerate(lbl_df.iterrows()):
        g = str(row["gene_symbol"])
        nx, ny = float(row["x"]), float(row["y"])
        theta = 2.0 * np.pi * idx / max(n_lbl, 1) - 0.35
        tx = cx + rx * np.cos(theta)
        ty = cy + ry * np.sin(theta)
        ax.annotate(
            g, xy=(nx, ny), xytext=(tx, ty),
            fontsize=7.2, style="italic",
            fontweight="bold" if g == hub_gene else "normal",
            ha="center", va="center", color="#111111",
            bbox=dict(boxstyle="round,pad=0.22", facecolor="white", edgecolor="#888888", lw=0.55, alpha=0.95),
            arrowprops=dict(arrowstyle="-", color="#555555", lw=0.55, shrinkA=0, shrinkB=2),
            zorder=6,
        )

    ax.text(
        0.04, 0.95,
        f"Total nodes: {len(nodes_df)}\nTotal edges: {len(segs)}\nr ≥ {r_thresh:.2g}",
        transform=ax.transAxes, ha="left", va="top", fontsize=7.5, color="#222222",
    )
    ax.set_xlim(cx - half_w, cx + half_w)
    ax.set_ylim(cy - half_h, cy + half_h)
    ax.set_xticks([])
    ax.set_yticks([])
    for sp in ax.spines.values():
        sp.set_linewidth(0.85)
        sp.set_color("#222222")
    return ax
