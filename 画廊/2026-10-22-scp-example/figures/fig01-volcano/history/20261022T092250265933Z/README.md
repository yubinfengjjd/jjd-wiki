# SCP VolcanoPlot — single panel

Source implementation: SCP v0.5.6 `VolcanoPlot()` in `R/SCP-plot.R` (GPL >= 3), commit `b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0`, <https://github.com/zhanghao-njmu/scp>. The exact function excerpt is archived in `original_code/volcano.R` with its own SHA-256 in `original_code/provenance.json`.

## Figure scope

One logical panel: the `Endocrine` group of the SCP `pancreas_sub` example dataset (1000 cells, 5 CellType groups), compared with the remaining cells. The SCP function facets all `group1` levels; this entry keeps one facet so it satisfies the Wiki single-panel rule. The full multi-facet output is not stored.

- x: `diff_pct = pct.1 - pct.2` (difference in the fraction of expressing cells).
- y: signed `-log10(p_val_adj)`; SCP flips the sign for genes with negative log2FC and labels the axis with absolute values. This unusual signed layout is preserved.
- color: `avg_log2FC`.
- highlighted points: `avg_log2FC > 0 & p_val_adj < 0.05` (SCP default `DE_threshold`).
- labels: top 8 by distance above and below zero.

## Data provenance

- Expression data: SCP `pancreas_sub` example (`data("pancreas_sub")` in the upstream package), a 1000-cell subset of mouse pancreas. Not a published figure and not a real study.
- DE table: computed with `Seurat::FindMarkers(ident.1 = "Endocrine", only.pos = FALSE, logfc.threshold = 0, min.pct = 0.1)` in Seurat 5.6.0. SCP `RunDEtest()` cannot run under SeuratObject 5.6 because it still uses the defunct `slot`/`Assays(object, assay)` APIs; the DE table is therefore a replacement computation, not the output of SCP `RunDEtest`.
- Code provenance: `mixed` — the expression data and SCP plotting implementation are original; the DE computation is a compatible replacement, and the plotting core is an adapted table-consuming version.
- The source image `source/fig01.png` was rendered by the unmodified SCP `VolcanoPlot()` on this DE table (single group), so it is a code-generated reference, not a published article figure.

## Code

- `code/core.R`: `plot_volcano(df, style)` — ggplot2 plotting core consuming the DE table; no Seurat, no DE test, no file I/O. Adapted from SCP `VolcanoPlot`; the SCP-specific threshold string, `SCP::palette_scp`, and multi-facet loop are replaced by explicit style parameters and a single group selector.
- `code/replica.R`: reads `data/estimated_data.csv` and `data/figure_spec.json`, calls `plot_volcano()`, writes PNG/PDF/SVG and device/session records.
- `data/figure_spec.json`: group, thresholds, color limits, palette, sizes.
- `output/`: exported replica; `compare/`: side-by-side and overlay; `qa_report.md`: mechanical checks plus an unfilled human visual checklist.

Run from any directory with:

```powershell
$env:R_LIBS_USER = 'E:/research-wiki-env/R-lib-scp/4.5'
D:\R-4.5.0\bin\Rscript.exe --vanilla E:\research-wiki\画廊\2026-10-22-scp-example\figures\fig01-volcano\code\replica.R
```

## Limitations and assumptions

- The DE table uses a different implementation than SCP `RunDEtest`; p-values and log2FC are not numerically comparable to SCP's `RunDEtest` output.
- The source and replica are visually close but not pixel-identical: colorbar tick density, label placement, point sizes and font metrics differ slightly.
- The signed y-axis is an SCP design choice, not a conventional volcano layout; it is preserved for fidelity.
- The figure is a style/coverage reference for the Wiki; it is not evidence of a biological comparison. `pancreas_sub` is an example dataset with no case/control design.
- Human visual QA and author approval are pending; `meta.status` is `review`.
