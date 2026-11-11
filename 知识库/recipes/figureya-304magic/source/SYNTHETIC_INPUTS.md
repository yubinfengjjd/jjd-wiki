# Synthetic input notice

`SCLC_epithelial_cells.h5ad` in this `source/` directory is a **synthetic AnnData file generated for execution validation only** (repair batch `ingest/figureya-repair`).

- The original input is a ~9 GB cellxgene dataset
  (`https://datasets.cellxgene.cziscience.com/79f80e59-97e7-4f95-b1e9-9767a24b85b0.h5ad`),
  too large to store in the knowledge base and impractical to download per run.
- The synthetic file reproduces the required structure only: `var_names` are the
  25,090 Ensembl gene IDs expected by `data/gene.info.rds` (same order, so that
  `all(results$ensembl_gene_id == rownames(seu))` holds and the
  `uniq.name` rename works); `X` is a Poisson count matrix of 1,500 cells in
  which ~69% of genes are expressed in >500 cells so the
  `expr.in.cells > 500` filter retains genes.
- The `download.file` call in the Rmd is guarded so the bundled file is used.

Any run receipt against this input proves only that the recipe executes end to
end in the recorded environment. It is **not** a real analysis result and says
nothing about the biology of the SCLC epithelial dataset.
