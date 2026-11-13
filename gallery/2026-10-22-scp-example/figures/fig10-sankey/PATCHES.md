# PATCHES — fig10-sankey

Upstream: SCP v0.5.6, commit `b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0`, GPL (>= 3).
Files: `R/SCP-plot.R` (`CellStatPlot` 4463–4563, `StatPlot` 4564–5678, sankey branch 5072–5114) and `R/ggsankey.R`.

Environment used for both source and replica: R 4.5.0, patchwork 1.3.1, gtable 0.3.6, ggplot2 3.5.2, dplyr 1.1.4, tidyr 1.3.1, purrr 1.0.4, stringr 1.5.1, svglite 2.2.2.

The source PNG and the replica PNG are produced by the **same patched functions**: the gallery source is the upstream `CellStatPlot()` with the in-memory patch applied, and the replica calls `scp_sankey_native.R`, whose sankey branch carries the same three changes. Geometry, `make_long()`, `geom_sankey()`, scales, legend content and theme are upstream text.

## P1 — legend cbind/rbind over gtables

**Upstream lines 5098–5102**

```r
if (legend.direction == "vertical") {
  legend <- do.call(cbind, legend_list)
} else {
  legend <- do.call(rbind, legend_list)
}
```

**Problem.** `legend_list[[l]]` is a guide-box `grob`. `do.call(cbind, legend_list)` builds a 3 × 2 **list matrix**, not a grob or gtable. `add_grob()` then passes that matrix to `gtable::gtable_add_grob()` (gtable 0.3.6), which fails:

```
Error: `grobs` must be a single grob or a list of grobs, not a list matrix.
```

Measured: `class(do.call(cbind, legend_list))` = `matrix, array`, `dim` = `3 2`, `gtable::is.gtable()` = FALSE, `grid::is.grob()` = FALSE. The unpatched `CellStatPlot(pancreas_sub, stat.by = c("CellType","Phase"), plot_type = "sankey")` stops with exactly that error.

**Replacement.**

```r
if (legend.direction == "vertical") {
  legend <- do.call(cbind, lapply(legend_list, as_gtable))
} else {
  legend <- do.call(rbind, lapply(legend_list, as_gtable))
}
```

`as_gtable()` is the upstream SCP helper (`R/SCP-plot.R` 14722–14741); for a guide-box it returns the gtable, so `cbind`/`rbind` dispatch to `gtable_cbind`/`gtable_rbind` and produce one gtable with both legends side by side (vertical direction) or stacked.

**Proof legend content is unchanged.** `as_gtable()` wraps the same guide-box grob; no guide, scale, theme, label or order is touched. The final legend text labels extracted from the combined legend gtable are:

```
Ductal | Ngn3 low EP | Ngn3 high EP | Pre-endocrine | Endocrine | CellType |
G1 | S | G2M | Phase
```

Both legends (CellType and Phase) are visible in `output/replica.png`.

## P2 — wrap_plots over a single gtable

**Upstream line 5113**

```r
p <- wrap_plots(gtable)
```

**Problem.** The argument is a `gtable`, not a ggplot. patchwork 1.3.1 consumes the object as a wrapped patch rather than an explicit single plot. Passing a bare gtable relies on implicit list-matrix handling; the documented minimal fix makes the one-plot intent explicit.

**Replacement.**

```r
p <- wrap_plots(list(gtable))
```

**Proof geometry is unchanged.** In this environment the two forms render identical pixels for the single sankey panel: stage A (P1 + P3, no P2) MD5 `6d0bebe627514317f7d3c2a10ec4a120` = stage C (P1 + P2 + P3) MD5 `6d0bebe627514317f7d3c2a10ec4a120` = `output/replica.png`. The patch changes the patchwork container only.

## P3 — get_legend() must skip zeroGrob guide-box slots

**Upstream lines 14743–14751**

```r
get_legend <- function(plot) {
  plot <- as_gtable(plot)
  grob_names <- plot$layout$name
  grobs <- plot$grobs
  grobIndex <- which(grepl("guide-box", grob_names))
  grobIndex <- grobIndex[1]
  matched_grobs <- grobs[[grobIndex]]
  return(matched_grobs)
}
```

**Problem.** In ggplot2 3.5.2 every plot carries five guide-box slots: `guide-box-right`, `guide-box-left`, `guide-box-bottom`, `guide-box-top`, `guide-box-inside`. All but the used one are `zeroGrob`. `grobIndex[1]` selects the first slot in layout order — `guide-box-right` — which is empty. Measured for the legend construction used by the sankey branch:

```
guide-box-right   zeroGrob
guide-box-left    zeroGrob
guide-box-bottom  gtable      <- the real legend
guide-box-top     zeroGrob
guide-box-inside  zeroGrob
```

`get_legend()` therefore returns a `zeroGrob` for both dimensions. With P1 and P2 applied but P3 omitted, the rendered PNG has no legends (stage B MD5 `16e4e7b8aa2a7b533e667e6f2c1e1482`, compared with `6d0bebe627514317f7d3c2a10ec4a120` with P3).

**Replacement.**

```r
grobIndex <- which(grepl("guide-box", grob_names))
grobIndex <- grobIndex[!vapply(grobs[grobIndex], inherits, logical(1), what = "zeroGrob")]
if (length(grobIndex) == 0) {
  return(NULL)
}
matched_grobs <- grobs[[grobIndex[1]]]
```

The first non-empty guide box is returned. No legend key, label, order, title or theme is changed; only the empty-slot selection is skipped. If a plot genuinely has no legend, the function returns `NULL` and `add_grob()` already handles `NULL` by returning the gtable unchanged.

## Helper adaptations that do not affect geometry

- `as_grob()`, `as_gtable()`, `add_grob()`: copied from `R/SCP-plot.R` 14710–14794 with namespace qualification (`grid::`, `gtable::`, `ggplot2::`). The upstream `as_grob()` branch for `patchwork` objects (which calls patchwork internals `build_patchwork`/`annotate_table`) is omitted because the sankey panel here is a single ggplot; the sankey itself is wrapped by `wrap_plots()` after `add_grob()`.
- `make_long()`, `prepare_params()`, `find_default_space()`, `sigmoid()`, `StatSankeyFlow`, `StatSankeyNode`, `geom_sankey()`: copied verbatim from `R/ggsankey.R` lines 8–34, 36–46, 48–55, 70–108, 214–342, 583–651, 691–744. Only namespace qualification was added.

## Data/geometry invariances measured for the patched source vs replica

| Check | Result |
|---|---|
| `make_long()` linkage table | `identical()` TRUE |
| `dat_use` after factor/NA handling | `identical()` TRUE |
| color vector | `identical()` TRUE |
| per-dimension legend levels | `identical()` TRUE |
| node rectangles (`n_x, node, freq, ymin, ymax, xmin, xmax`) vs `ggplot_build()` | `identical()` TRUE |
| flow geometry (`xmax, xmin_end, flow_start/end_ymin/ymax, smooth`) vs `ggplot_build()` | `identical()` TRUE |
| flow counts vs `table(CellType, Phase)` | 12 non-zero flows, sum 1000 = cells, TRUE |
| source vs replica PNG SHA256 | `7b16c62001e6780ff1c4fd2bee40eb230127704717bc37b4a792afc675fcbf95` (identical) |

All measurements are reproduced by `src/01_generate_source.R` (workspace, not part of the entry).
