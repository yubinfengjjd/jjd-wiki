# Synthetic input notice

`seu.rds` in this `source/` directory is a **synthetic Seurat object generated
for execution validation only** (repair batch `ingest/figureya-repair`).

- The original recipe builds `seu` from GSE159677 single-cell data in an
  `eval=FALSE` preparation chunk; that raw 10X dataset is not redistributed.
- The synthetic object reproduces only the required interface: an `RNA` assay
  `counts` layer whose rownames include the hallmark gene symbols from
  `h.all.v7.5.1.symbols.gmt`, and `meta.data` columns `Celltypes` (5 synthetic
  types) and `Group` (levels `AC`, `PA` matching the `AC-PA` contrast).
- Cell counts (600) and expression values are random Poisson draws with a small
  injected group difference on the first 300 hallmark genes.

Any run receipt against this input proves execution only, not a real analysis.
