# Portability test: copy the module code to an isolated directory, load it with
# source() in a fresh process, and call it without any SCP-local path.
args <- commandArgs(trailingOnly = TRUE)
code_dir <- normalizePath(args[1], mustWork = TRUE)
fixture <- args[2]
stopifnot(!grepl("scp-local", code_dir, ignore.case = TRUE))

load(fixture)
stopifnot(inherits(pancreas_sub, "Seurat"))
srt <- pancreas_sub[, seq_len(80)]
before <- serialize(srt, NULL)

env <- new.env(parent = globalenv())
old_wd <- setwd(code_dir)
on.exit(setwd(old_wd), add = TRUE)
source(file.path(code_dir, "analysis.R"), local = env)

parameters <- list(
  qc_metrics = c("umi", "gene", "mito"),
  UMI_threshold = 0, gene_threshold = 0, mito_threshold = 100,
  return_filtered = FALSE, assay = "RNA", seed = 11
)
out <- env$run_cell_quality_control(srt, parameters = parameters)
res <- out$result
stopifnot(inherits(res, "Seurat"))
stopifnot(identical(before, serialize(srt, NULL)))
stopifnot(identical(colnames(res), colnames(srt)))
stopifnot(all(c("nCount_RNA", "nFeature_RNA", "CellQC") %in% colnames(res[[]])))
stopifnot(nrow(res) == nrow(srt))
stopifnot(!is.null(out$diagnostics$upstream_function))
stopifnot(identical(out$diagnostics$automatic_installation, FALSE))
cat("PORTABILITY_PASS cellqc\n")
cat("cells:", ncol(res), "genes:", nrow(res), "qc_classes:", paste(names(table(res$CellQC)), table(res$CellQC), collapse="; "), "\n")
saveRDS(list(qc = res[[]][, c("nCount_RNA", "nFeature_RNA", "CellQC")], cells = colnames(res)),
        args[3])
