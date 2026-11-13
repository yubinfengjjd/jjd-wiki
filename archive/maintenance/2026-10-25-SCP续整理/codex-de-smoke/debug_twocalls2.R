args <- commandArgs(trailingOnly = TRUE)
code_dir <- args[1]; data_rda <- args[2]
load(data_rda)
env <- new.env()
source(file.path(code_dir, "analysis.R"), local = env)
p <- list(group_by = "CellType", group1 = "Ductal", group2 = "Endocrine",
          test.use = "wilcox", only.pos = FALSE, fc.threshold = 1, min.pct = 0.1,
          p.adjust.method = "bonferroni", slot = "data", assay = "RNA",
          verbose = FALSE, BPPARAM = BiocParallel::SerialParam(), seed = 11)
r1 <- env$run_differential_expression(pancreas_sub, parameters = p)
cat("call1 rows:", nrow(r1$result@tools$DEtest_custom$AllMarkers_wilcox), "\n")
cat("=== call 2 with stack\n")
r2 <- tryCatch(
  withCallingHandlers(
    env$run_differential_expression(pancreas_sub, parameters = p),
    error = function(e) {
      cat("ERROR:", conditionMessage(e), "\nCALLS (innermost last):\n")
      cs <- sys.calls()
      for (i in seq_along(cs)) cat(i, ": ", paste(deparse(cs[[i]], nlines = 1), collapse = " "), "\n", sep = "")
    }),
  error = function(e) e)
