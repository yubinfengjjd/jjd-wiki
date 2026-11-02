# PATCHES — native bar replication

Upstream: SCP v0.5.6, `R/SCP-plot.R`, commit `b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0`, GPL (>= 3).
Functions: `CellStatPlot` (4463–4490) → `StatPlot` (4564–5624). The bar branch is
`StatPlot` lines 4821–4831.

`code/scp_bar_native.R` contains the counting half (`scp_stat_table()`) and the
plot half (`plot_scp_stat()`). The bar construction itself is copied line for
line. The differences below are the only ones in the bar path. "Proof" refers
to byte-identical PNG output from the unmodified upstream function and the
split core, rendered on the same device (8 × 6 in, 150 dpi, white background),
recorded in `../source/variants/compare.csv` and `output/run-summary.txt`.

## 1. Single-combination hoisting

- Upstream (4787–4819, 4821–4831): the position/scale selection, `bg_layer`
  construction and the ggplot call are evaluated inside
  `lapply(rownames(comb), ...)` once per `stat.by × group.by × split.by`
  combination.
- Replacement: the template fixes one `stat.by`, one `group.by` and the
  implicit single split (`All.groups`), so the same expressions are evaluated
  once before the type branch. Expression text and operand order are unchanged.
- Reason: `CellStatPlot` with one `stat.by` and no `split.by` produces exactly
  one combination (`plist` has length 1 and `combine = TRUE` returns it).
- Proof: `stack_count_label`, `dodge_count_label`, `stack_percent`,
  `dodge_percent_label`, `stack_count_nolabel`, `stack_count_flip` are each
  byte-identical to the upstream output.

## 2. `value` → `.data[[value.by]]`

- Upstream (4822, 4916–4917): `aes(x = .data[[g]], y = value, group =
  .data[[stat.by]])` and the label aesthetic `y = value`. `value` is the bare
  symbol of the column created by the counting step.
- Replacement: `y = .data[[value.by]]` with `value.by = "value"` by default.
  The same core also serves the explicit table entry (`scp_stat_values()`),
  where the value column name is caller-supplied.
- Reason: parameterised value column; no change to the evaluated data.
- Proof: all six variants byte-identical. `scp_stat_table()` returns the same
  column `value`.

## 3. `title <- title %||% sp` → `title <- title %||% ""`

- Upstream (4937): the default title is the split level name `sp`.
- Replacement: the core has no `split.by`; the only split level in
  `CellStatPlot` calls with `split.by = NULL` is `""`, so the default is `""`.
- Reason: equivalent for every call this template can express.
- Proof: both outputs have no title panel; PNG byte-identical.

## 4. `xlab` default

- Upstream (4697): `xlab <- xlab %||% group.by`.
- Replacement (core): `xlab <- xlab %||% if (group.by == "All.groups" &&
  all(levels(dat[[group.by]]) == "")) "" else group.by`.
- Reason: reproduces upstream's `xlab <- ""` assignment that `StatPlot` makes
  when `group.by = NULL`. With `group.by = "CellType"` both give `"CellType"`.
- Proof: PNG byte-identical; axis title rendered as `CellType` in both.

## 5. Colour vector construction

- Upstream (4706, 4741): `colors <- palette_scp(dat_all[[stat.by]], ...)` on
  the full metadata column, then `colors_use <- colors[names(colors) %in%
  dat_split[[...]][[stat.by]]]`.
- Replacement: `stat_factor <- factor(stat_values, levels = stat_levels,
  exclude = NULL)`; `colors <- palette_scp(stat_factor, ...)`; `colors_use <-
  colors[names(colors) %in% unique(as.character(dat[[stat.by]]))]`.
- Reason: the cell-level column is not retained after counting; the factor is
  rebuilt from the declared levels. When `stat_levels` equals the metadata
  factor levels, `palette_scp()` returns the same named colour vector.
- Proof: byte-identical PNG, including legend swatches and their order.

## 6. `bg_layer` data source (dodge only)

- Upstream (4808–4818): `bg_data <- na.omit(unique(dat[, g, drop = FALSE]))`,
  `x = as.numeric(bg_data[[g]])`, fill via `bg_color[bg_map[[g]][...]]` where
  `bg_color` uses `palcolor %||% rep(c("transparent", "grey85"), nlevels)`.
- Replacement (core): `bg_data` is built from `group_levels` with the same
  `xmin/xmax` rules and fill from
  `palette_scp(factor(group_levels), palcolor = rep(c("transparent",
  "grey85"), ...))`.
- Reason: no cell-level data remains after the counting step; `group_levels`
  is the same ordered set as `unique(dat[[g]])` for these calls.
- Proof: `dodge_count_label` and `dodge_percent_label` are byte-identical,
  including the alternating background rectangles.

## 7. Namespace

- Upstream: SCP package `Imports` (ggplot2, dplyr, ggrepel, scales, rlang)
  are attached at package load.
- Replacement: `code/core.R` attaches the same packages with `library()`;
  function bodies keep the upstream unqualified calls. No statistical or
  geometric change.
- Proof: PNG byte-identical.

## Non-patches (carried over, not exercised)

`scp_bar_native.R` keeps the shared CellStat core's pie/rose/trend/area/dot
branches from `scripts/scp_stat_native.R` so the provenance of the shared file
stays traceable. This template calls only `type = "bar"`; the other branches
are never reached. The pie/rose `merge_polar_endpoints` merge is off for bar.
