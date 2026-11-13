# Compatibility patches — native `CellStatPlot(plot_type = "chord")`

Upstream: SCP v0.5.6, commit `b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0`, `R/SCP-plot.R`
(`CellStatPlot` 4463–4563, `StatPlot` 4564–5678; chord branch 5115–5138).
License: GPL (>= 3).

The upstream call returns a `recordedplot`. Every patch below is mechanical:
namespace qualification, moving the same code into a function, or replacing the
palette lookup with a template-local copy. None changes the contingency matrix,
sector order, colors, link geometry, labels or device parameters. Proof for all
rows: the extracted core replayed on the same device produces a PNG that is
byte-identical to the unmodified upstream function output
(SHA256 `6674db75622654c4da8e7a96250d264fb0be29720f380889c2ee78e9dcd36de6`,
1200×900, pixel mad = 0, RMS = 0).

| # | Upstream lines | Exact upstream code | Reason | Replacement | Proof geometry/data unchanged |
|---|---|---|---|---|---|
| 1 | 5117–5119 | `M <- table(dat_use[[stat.by[1]]], dat_use[[stat.by[2]]], useNA = "ifany"); m <- matrix(M, ncol = ncol(M), dimnames = dimnames(M)); colnames(m)[is.na(colnames(m))] <- "NA"` | Separate the table half from the plot half | `scp_chord_table()` executes the same three lines; only `dat_use` becomes the prepared `md` data frame (same factor levels) | `identical(upstream_m, scp_chord_table(...))` is `TRUE`; the matrix captured from the upstream `chordDiagram()` argument equals the matrix rebuilt from upstream lines (`work/upstream_m.rds` vs `work/upstream_m_reference.rds`) |
| 2 | 5116 | `colors <- palette_scp(c(unique(unlist(lapply(dat_all[, stat.by, drop = FALSE], levels))), NA), palette = palette, palcolor = palcolor, NA_keep = TRUE, NA_color = NA_color)` | No installed SCP package / `SCP::palette_list` in the template | `scp_chord_colors()` executes the same line; `palette_scp()` is copied verbatim into `code/scp_helpers.R` and reads `palette_list` from `code/data/palette_list.rda` | Captured `grid.col` and `scp_chord_colors()` output are `identical()` (`TRUE`); colors `#A6CEE3`, `#1F78B4`, `#B2DF8A`, `#33A02C`, `#FDBF6F`, `#FF7F00`, `#FB9A99`, `#E31A1C`, `grey` |
| 3 | 4962–4978 | `temp <- tempfile(fileext = "png"); png(temp); dev.control("enable"); nlev <- nlevels(dat_all[[split.by]]); if (is.null(nrow) && is.null(ncol)) {...}; par(mfrow = c(nrow, ncol))` | Plot half must be callable standalone; `nlev` for a single panel is 1 | `plot_scp_chord()` keeps the same sequence with `grDevices::png`, `grDevices::dev.control`, `graphics::par`; `nlev` is an argument defaulting to 1 (single split level) | The recorded display list replays to the same PNG; 1×1 `mfrow` matches the single `All.groups` split |
| 4 | 5120–5126 | `chordDiagram(m, grid.col = colors, transparency = 0.2, link.lwd = 1, link.lty = 1, link.border = 1)` | Namespace and explicit style keys | `circlize::chordDiagram(m, grid.col = colors, transparency = transparency, link.lwd = link_lwd, link.lty = link_lty, link.border = link_border)` with defaults `0.2, 1, 1, 1` | Defaults equal the upstream constants; PNG byte-identical |
| 5 | 5127 | `circos.clear()` | Namespace qualification | `circlize::circos.clear()` | Same call, same effect; PNG byte-identical |
| 6 | 5128 and 5143–5147 | `p <- recordPlot()` … `plot <- recordPlot(); dev.off(); unlink(temp); return(plot)` | Return the same `recordedplot` object | `grDevices::recordPlot()` twice, `invisible(grDevices::dev.off())`, `unlink(temp)`, return the outer plot | Object class `recordedplot`; replay PNG byte-identical |
| 7 | 4575 | `set.seed(seed)` | Reproducibility must survive the function boundary | `plot_scp_chord()` calls `set.seed(seed)` (default 11) before recording | No RNG-dependent drawing difference; source/replica PNG identical |
| 8 | device layer (no upstream line) | upstream returns a `recordedplot`; `ggsave` is not applicable | Need PNG/PDF/SVG files | Source and replica both call `grDevices::png(1200, 900, res = 150, bg = "white")`, `grDevices::cairo_pdf(8, 6, bg = "white")`, `svglite::svglite(8, 6, bg = "white")`, each followed by `grDevices::replayPlot(p)` | Identical device calls on both sides; PNG SHA256 equal |

## Preserved, not patched

- `stat_type` is forcibly set to `count` for chord (upstream lines 4679–4682); the
  upstream warning is kept and recorded in `work/source-summary.json`.
- `group.by` is ignored by upstream for chord (4676–4678); the native call passes
  no `group.by`.
- The `NA` column rename to `"NA"` (line 5119) is preserved.
- `theme_scp()`, `capitalize()` and ggplot2 are not copied: the chord branch uses
  none of them.

## Non-upstream code (interface adapter only)

`scp_chord_linkage_wide()`, `scp_chord_long_meta()` and `scp_chord_linkage_summary()`
reshape the `render-cell-linkage` long CSV into the wide per-cell metadata and
report sector/label counts. They perform no drawing and no statistics beyond the
upstream `table()` step. The drawing path remains `scp_chord_table()` →
`scp_chord_colors()` → `plot_scp_chord()`.

## Reproduction

```powershell
# source (upstream, unmodified): work/source/fig11.png
Rscript --vanilla src/generate_source.R
# replica (native core from the long CSV): gallery/output/replica.png
cd gallery; Rscript --vanilla code/replica.R
```

Recorded plot capture: `generate_source.R` temporarily assigns a forwarding
wrapper for `chordDiagram` into the `SCP_local` environment, records the matrix
and `grid.col`, then removes it. The wrapper forwards every argument unchanged;
the resulting PNG is byte-identical to the unwrapped upstream run
(probe `work/probe_upstream1.png` = `6674db…`).
