# SCP CellStatPlot ring — single panel

Source implementation: SCP v0.5.6 `CellStatPlot(plot_type = "ring")` / `StatPlot()` in `R/SCP-plot.R` (GPL >= 3), commit `b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0`, <https://github.com/zhanghao-njmu/scp>. The exact function excerpts are archived in `original_code/ring.R` with SHA-256 in `original_code/provenance.json`.

## Figure scope

One logical panel: concentric rings for each `CellType` (5 rings), sectors for `Phase` (G1/S/G2M), sector angle proportional to the within-CellType Phase fraction. The SCP function can combine multiple plot types; this entry keeps only the ring panel so it satisfies the Wiki single-panel rule.

- group: `CellType` (ring order, outer to inner: Endocrine, Pre-endocrine, Ngn3 high EP, Ngn3 low EP, Ductal in the example).
- celltype/sector: `Phase` (G1, S, G2M).
- angle: `proportion` within each `CellType`, summing to 1.
- reference circle: dashed circle with 0/25/50/75/100% labels; group labels at left with tick marks.

## Data provenance

- `pancreas_sub` example metadata (1000 cells), from the SCP package. Not a published figure and not a real cohort.
- `data/estimated_data.csv` is the group × Phase proportion table computed from the example metadata. The gallery's legacy filename says “estimated”, but the values are exact proportions of the example cells, not estimated from a picture.
- Code provenance: `adapted` — the SCP ring plotting code is reimplemented as a table-consuming ggplot2/ggforce core; the SCP source excerpts are archived unchanged.
- The source image `source/fig02.png` was rendered by the unmodified SCP `CellStatPlot(plot_type = "ring")` on the example data, so it is a code-generated reference, not a published article figure.

## Code

- `code/core.R`: `plot_ring(df, ...)` — validates `group/celltype/proportion`, computes cumulative angles and ring radii, draws with `ggforce::geom_arc_bar`, adds reference circle, percentage labels, group labels and tick marks. No Seurat, no counting, no file I/O.
- `code/replica.R`: reads `data/estimated_data.csv` and `data/figure_spec.json`, calls `plot_ring()`, writes PNG/PDF/SVG and device/session records.
- `data/figure_spec.json`: group/celltype/proportion column names, palette, gap, label sizes, reference/axis flags, canvas size.
- `output/`: replica; `compare/`: side-by-side and overlay; `qa_report.md`: mechanical checks plus the agent visual checklist.

Run from any directory with:

```powershell
$env:R_LIBS_USER = 'E:/research-wiki-env/R-lib-scp/4.5'
D:\R-4.5.0\bin\Rscript.exe --vanilla E:\research-wiki\画廊\2026-10-22-scp-example\figures\fig02-ring\code\replica.R
```

## Limitations and assumptions

- The replica is visually close but not pixel-identical: ring/sector outline thickness, label placement, rotation direction and the `CellType` axis title position differ slightly.
- Small sectors (<5%) can have overlapping percentage labels; the template exposes `min_label_prop` and canvas size, but the example keeps labels for all sectors >=3%.
- The ring order is categorical, not temporal; do not read it as a trajectory.
- `pancreas_sub` is an example dataset; the figure is a style/coverage reference, not a biological result.
- Human visual QA and author approval are pending; `meta.status` is `review`.
