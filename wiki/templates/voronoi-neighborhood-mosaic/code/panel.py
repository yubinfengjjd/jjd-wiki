"""High-density Voronoi cellular spatial neighborhood mosaic with two zoomed insets."""
import matplotlib.patches as mpatches
from matplotlib.collections import PolyCollection
from matplotlib.gridspec import GridSpecFromSubplotSpec
import numpy as np
from scipy.spatial import Voronoi
from shapely.geometry import Polygon, box


RCN_COLORS = {
    "RCN1": "#EBB39A", "RCN2": "#2D9A93", "RCN3": "#52B87A", "RCN4": "#C3DEC0",
    "RCN5": "#EFE738", "RCN6": "#4FC4EA", "RCN7": "#5692BC", "RCN8": "#F29954",
    "RCN9": "#EB2629", "RCN10": "#C7C7C7",
}
FALLBACK_PAL = [
    "#EBB39A", "#2D9A93", "#52B87A", "#C3DEC0", "#EFE738",
    "#4FC4EA", "#5692BC", "#F29954", "#EB2629", "#C7C7C7",
]


def _voronoi_finite_polygons_2d(vor, radius=None):
    new_regions = []
    new_vertices = vor.vertices.tolist()
    center = vor.points.mean(axis=0)
    if radius is None:
        radius = np.ptp(vor.points, axis=0).max() * 2.0
    all_ridges = {}
    for (p1, p2), (v1, v2) in zip(vor.ridge_points, vor.ridge_vertices):
        all_ridges.setdefault(p1, []).append((p2, v1, v2))
        all_ridges.setdefault(p2, []).append((p1, v1, v2))
    for p1, region in enumerate(vor.point_region):
        vertices = vor.regions[region]
        if all(v >= 0 for v in vertices):
            new_regions.append(vertices)
            continue
        ridges = all_ridges[p1]
        new_region = [v for v in vertices if v >= 0]
        for p2, v1, v2 in ridges:
            if v2 < 0:
                v1, v2 = v2, v1
            if v1 >= 0:
                continue
            t = vor.points[p2] - vor.points[p1]
            t /= np.linalg.norm(t)
            n = np.array([-t[1], t[0]])
            midpoint = vor.points[[p1, p2]].mean(axis=0)
            direction = np.sign(np.dot(midpoint - center, n)) * n
            far_point = vor.vertices[v2] + direction * radius
            new_region.append(len(new_vertices))
            new_vertices.append(far_point.tolist())
        vs = np.asarray([new_vertices[v] for v in new_region])
        c = vs.mean(axis=0)
        angles = np.arctan2(vs[:, 1] - c[1], vs[:, 0] - c[0])
        new_region = np.array(new_region)[np.argsort(angles)]
        new_regions.append(new_region.tolist())
    return new_regions, np.asarray(new_vertices)


def _compute_clipped_voronoi(xs, ys):
    pts = np.column_stack([xs, ys])
    vor = Voronoi(pts)
    regions, verts = _voronoi_finite_polygons_2d(vor)
    bbox = box(xs.min(), ys.min(), xs.max(), ys.max())
    polys = []
    for reg in regions:
        poly = Polygon(verts[reg]).buffer(0).intersection(bbox)
        if poly.is_empty:
            polys.append(np.empty((0, 2)))
        elif poly.geom_type == "Polygon":
            polys.append(np.asarray(poly.exterior.coords))
        else:
            largest = max(poly.geoms, key=lambda g: g.area)
            polys.append(np.asarray(largest.exterior.coords))
    return polys


def draw(fig, rect, tables, style):
    df = tables["cells"].copy()
    fov_sel = style.get("fov_id", None)
    if fov_sel and "fov_id" in df.columns and fov_sel in df["fov_id"].values:
        df = df[df["fov_id"] == fov_sel].copy()
    elif "fov_id" in df.columns:
        # Pick largest FOV by cell count
        top_fov = df["fov_id"].value_counts().index[0]
        df = df[df["fov_id"] == top_fov].copy()

    xs = df["x"].to_numpy(float)
    ys = df["y"].to_numpy(float)
    if style.get("flip_y", True):
        ys = ys.max() - ys + ys.min()

    polys = _compute_clipped_voronoi(xs, ys)
    cats_raw = df["neighborhood"].astype(str).tolist()
    uniq_cats = sorted(
        set(cats_raw),
        key=lambda s: (int(s.replace("RCN", "")) if s.startswith("RCN") and s[3:].isdigit() else 999, s),
    )
    pal = {
        c: RCN_COLORS.get(c, FALLBACK_PAL[i % len(FALLBACK_PAL)])
        for i, c in enumerate(uniq_cats)
    }
    cols = [pal[c] for c in cats_raw]

    x0, x1 = float(xs.min()), float(xs.max())
    y0, y1 = float(ys.min()), float(ys.max())
    xr, yr = x1 - x0, y1 - y0
    red_box = style.get("zoom_box_1", [x0 + 0.34 * xr, y0 + 0.24 * yr, 0.24 * xr, 0.42 * yr])
    blue_box = style.get("zoom_box_2", [x0 + 0.62 * xr, y0 + 0.12 * yr, 0.24 * xr, 0.42 * yr])

    gs_outer = fig.add_gridspec(1, 1, left=rect[0], bottom=rect[1], right=rect[0] + rect[2], top=rect[1] + rect[3])
    sub_gs = GridSpecFromSubplotSpec(3, 2, subplot_spec=gs_outer[0, 0], height_ratios=[1.65, 1.15, 0.40], hspace=0.08, wspace=0.08)

    ax_top = fig.add_subplot(sub_gs[0, :])
    ax_z1 = fig.add_subplot(sub_gs[1, 0])
    ax_z2 = fig.add_subplot(sub_gs[1, 1])
    ax_leg = fig.add_subplot(sub_gs[2, :])

    valid_idx = [i for i, p in enumerate(polys) if len(p) >= 3]
    pc_top = PolyCollection([polys[i] for i in valid_idx], facecolors=[cols[i] for i in valid_idx],
                            edgecolors="#777777", linewidths=float(style.get("overview_lw", 0.14)))
    ax_top.add_collection(pc_top)
    ax_top.set_xlim(x0, x1)
    ax_top.set_ylim(y0, y1)
    ax_top.set_aspect("equal")
    lbl_fov = str(df["fov_id"].iloc[0]) if "fov_id" in df.columns else "Spatial FOV"
    ax_top.text(0.02, 0.94, lbl_fov, transform=ax_top.transAxes, fontsize=8.0, ha="left", va="top",
                color="#111111", bbox=dict(boxstyle="square,pad=0.18", facecolor="white", edgecolor="none", alpha=0.80))

    for (bx, by, bw, bh), ec in [(red_box, "#E31A1C"), (blue_box, "#1F78B4")]:
        ax_top.add_patch(mpatches.Rectangle((bx, by), bw, bh, facecolor="none", edgecolor=ec, lw=1.4, zorder=5))
    ax_top.set_xticks([])
    ax_top.set_yticks([])
    for sp in ax_top.spines.values():
        sp.set_linewidth(0.75)
        sp.set_color("#222222")

    for ax_z, (bx, by, bw, bh), ec in [(ax_z1, red_box, "#E31A1C"), (ax_z2, blue_box, "#1F78B4")]:
        sub_i = [i for i in valid_idx if (bx - 0.15 * bw <= xs[i] <= bx + 1.15 * bw) and (by - 0.15 * bh <= ys[i] <= by + 1.15 * bh)]
        pc_z = PolyCollection([polys[i] for i in sub_i], facecolors=[cols[i] for i in sub_i],
                              edgecolors="#555555", linewidths=float(style.get("zoom_lw", 0.35)))
        ax_z.add_collection(pc_z)
        ax_z.set_xlim(bx, bx + bw)
        ax_z.set_ylim(by, by + bh)
        ax_z.set_aspect("equal")
        ax_z.set_xticks([])
        ax_z.set_yticks([])
        for sp in ax_z.spines.values():
            sp.set_linewidth(1.5)
            sp.set_color(ec)

    ax_leg.axis("off")
    handles = [mpatches.Patch(facecolor=pal[c], label=c) for c in uniq_cats]
    ax_leg.legend(handles=handles, loc="center", ncol=min(5, len(handles)), frameon=False,
                  fontsize=7.2, handlelength=1.2, handleheight=0.8, columnspacing=1.0, labelspacing=0.35)
