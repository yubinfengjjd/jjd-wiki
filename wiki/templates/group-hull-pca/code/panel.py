"""PCA scatter with Chaikin-smoothed translucent convex hulls and in-plot labels (Cancer Discovery style)."""
import matplotlib.patches as mpatches
import numpy as np
from scipy.spatial import ConvexHull

SITE_COLORS = {
    "MIS": "#1E9C78",
    "IR": "#DA805C",
    "bTIL": "#C84B93",
    "IB": "#85A933",
    "IM": "#C69032",
    "EM": "#666666",
}
FALLBACK_COLS = ["#1E9C78", "#DA805C", "#C84B93", "#85A933", "#C69032", "#666666"]


def _draw_soft_hull(ax, pts, facecolor, edgecolor, alpha=0.42, pad_frac=0.18):
    if len(pts) < 3:
        return
    center = pts.mean(axis=0)
    padded = center + (pts - center) * (1.0 + pad_frac)
    hull = ConvexHull(padded)
    poly_pts = padded[hull.vertices]
    for _ in range(3):
        new_pts = []
        n = len(poly_pts)
        for i in range(n):
            p0, p1 = poly_pts[i], poly_pts[(i + 1) % n]
            new_pts.append(0.75 * p0 + 0.25 * p1)
            new_pts.append(0.25 * p0 + 0.75 * p1)
        poly_pts = np.asarray(new_pts)
    patch = mpatches.Polygon(
        poly_pts, closed=True, facecolor=facecolor, edgecolor=edgecolor,
        linestyle="--", linewidth=0.9, alpha=alpha, zorder=1,
    )
    ax.add_patch(patch)


def draw(fig, rect, tables, style):
    pca_df = tables["pca"]
    ax = fig.add_axes(rect)
    n_mroi = len(pca_df)
    ax.set_title(style.get("title", f"PickSeq ({n_mroi} mROIs)"), fontsize=9.5, pad=6)

    hull_groups = [
        (["EM", "IM", "IB"], "#E9E3B5", "#C7BF86"),
        (["MIS"], "#9DC2B5", "#6BA18F"),
        (["bTIL", "IR"], "#F1BFA4", "#DC9470"),
    ]
    alpha_h = float(style.get("hull_alpha", 0.42))
    matched_any = False
    for sites, fc, ec in hull_groups:
        sub = pca_df[pca_df["site"].isin(sites)][["PC1", "PC2"]].to_numpy(float)
        if len(sub) >= 3:
            matched_any = True
            _draw_soft_hull(ax, sub, fc, ec, alpha=alpha_h)

    if not matched_any:
        for i, st in enumerate(pca_df["site"].unique()):
            sub = pca_df[pca_df["site"] == st][["PC1", "PC2"]].to_numpy(float)
            col = FALLBACK_COLS[i % len(FALLBACK_COLS)]
            _draw_soft_hull(ax, sub, col, col, alpha=alpha_h * 0.6)

    pt_size = float(style.get("point_size", 24.0))
    for i, site_name in enumerate(pca_df["site"].unique()):
        sub = pca_df[pca_df["site"] == site_name]
        col = SITE_COLORS.get(site_name, FALLBACK_COLS[i % len(FALLBACK_COLS)])
        ax.scatter(
            sub["PC1"], sub["PC2"], c=col,
            s=pt_size, edgecolors="#222222", linewidths=0.4, alpha=0.92, zorder=3,
        )
        cx, cy = sub["PC1"].median(), sub["PC2"].median()
        ax.text(
            cx, cy + (sub["PC2"].std() * 0.65 if len(sub) > 1 else 1.5),
            str(site_name), fontsize=8.2, fontweight="bold", color=col,
            ha="center", va="bottom", zorder=4,
        )

    pc1_v = float(pca_df["pc1_var_pct"].iloc[0]) if "pc1_var_pct" in pca_df.columns else 15.3
    pc2_v = float(pca_df["pc2_var_pct"].iloc[0]) if "pc2_var_pct" in pca_df.columns else 5.1
    ax.set_xlabel(f"PC1: {pc1_v:.1f}% variance", fontsize=8.5, labelpad=4)
    ax.set_ylabel(f"PC2: {pc2_v:.1f}% variance", fontsize=8.5, labelpad=4)
    ax.set_xticks([])
    ax.set_yticks([])
    for sp in ax.spines.values():
        sp.set_linewidth(0.8)
        sp.set_color("#222222")
    return ax
