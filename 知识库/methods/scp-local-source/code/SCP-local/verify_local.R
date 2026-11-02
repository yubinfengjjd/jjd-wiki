# verify_local.R
# Static and dependency-free runtime checks for the source-only SCP bundle.
# Run with:
#   Rscript verify_local.R
# It does not need Seurat or SCP. Seurat-dependent functions are only checked
# for existence; they are not executed.

args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args, value = TRUE)
root <- if (length(file_arg)) dirname(normalizePath(sub("^--file=", "", file_arg[1]))) else getwd()
source(file.path(root, "load_scp_local.R"))

failures <- character()
check <- function(ok, label) {
  if (isTRUE(ok)) {
    cat("PASS:", label, "\n")
  } else {
    cat("FAIL:", label, "\n")
    failures <<- c(failures, label)
  }
}

# 1. Expected core functions are defined.
expected <- c(
  "RunCellQC", "RunDoubletCalling", "db_scDblFinder", "db_Scrublet",
  "Standard_SCP", "Integration_SCP", "RunDimReduction",
  "RunDEtest", "RunEnrichment", "RunGSEA", "RunDynamicFeatures",
  "RunDynamicEnrichment", "CellScoring", "FindExpressedMarkers",
  "RunSingleR", "RunKNNPredict", "RunScmap", "RunKNNMap",
  "RunSeuratMap", "RunSymphonyMap", "RunPCAMap", "RunCSSMap",
  "RunMonocle2", "RunMonocle3", "RunSlingshot", "RunPAGA",
  "RunSCVELO", "RunWOT", "RunPalantir",
  "CellDimPlot", "FeatureDimPlot", "CellStatPlot", "FeatureStatPlot",
  "GroupHeatmap", "FeatureHeatmap", "CellCorHeatmap", "CellDensityPlot",
  "EnrichmentPlot", "GSEAPlot", "DynamicPlot", "DynamicHeatmap",
  "LineagePlot", "PAGAPlot", "ProjectionPlot", "VelocityPlot",
  "VolcanoPlot", "StatPlot", "GraphPlot"
)
for (nm in expected) {
  check(exists(nm, envir = SCP_local, inherits = FALSE) &&
          is.function(get(nm, envir = SCP_local, inherits = FALSE)), paste("defined:", nm))
}

# 2. Expected exclusions and data objects.
for (nm in c("CreateDataFile", "CreateMetaFile", "FetchH5", "PrepareSCExplorer", "RunSCExplorer")) {
  check(!exists(nm, envir = SCP_local, inherits = FALSE), paste("app-only function excluded:", nm))
}
check(exists("palette_list", envir = SCP_local, inherits = FALSE), "palette_list loaded")
check(exists("words_excluded", envir = SCP_local, inherits = FALSE), "words_excluded loaded")

# 3. Dependency-free functions execute.
check(identical(SCP_local$isOutlier(c(1, 2, 3, 4, 5, 100)), 6L), "isOutlier executes")
check(identical(SCP_local$capitalize("abc"), "Abc"), "capitalize executes")

if (requireNamespace("Matrix", quietly = TRUE)) {
  m <- Matrix::Matrix(matrix(c(1, 0, 2, 0, 3, 0), nrow = 3), sparse = TRUE)
  out <- SCP_local$as_matrix(m)
  check(is.matrix(out) && identical(dim(out), dim(m)) &&
          isTRUE(all.equal(unname(out), unname(as.matrix(m)))), "as_matrix executes on dgCMatrix")
} else {
  cat("SKIP: Matrix not installed; as_matrix runtime check skipped\n")
}

# 4. Pure-R asMatrix translation (0-based row, 1-based column as in the C++).
m2 <- SCP_local$asMatrix(rp = c(0, 2), cp = c(1, 3), z = c(5, 7), nrows = 3, ncols = 3)
check(m2[1, 1] == 5 && m2[3, 3] == 7, "asMatrix pure-R translation")

# 5. No remaining package-qualified or compiled references in localized R code.
r_files <- list.files(file.path(root, "R"), pattern = "[.]R$", full.names = TRUE)
bad <- character()
for (f in r_files) {
  lines <- readLines(f, warn = FALSE)
  code <- sub("#.*$", "", lines)
  if (any(grepl("SCP::", code, fixed = TRUE))) bad <- c(bad, paste(basename(f), "SCP::"))
  if (any(grepl('system.file', code, fixed = TRUE) & grepl('package\\s*=\\s*"SCP"', code))) {
    bad <- c(bad, paste(basename(f), "system.file(package=SCP)"))
  }
  if (any(grepl(".Call", code, fixed = TRUE))) bad <- c(bad, paste(basename(f), ".Call"))
}
check(length(bad) == 0, paste("no package-qualified/compiled references", if (length(bad)) paste(bad, collapse = "; ")))

# 6. NAMESPACE exports present in the local environment (except documented exclusions).
index <- utils::read.csv(file.path(root, "FUNCTIONS.csv"), stringsAsFactors = FALSE, comment.char = "")
exports <- index[index$namespace_kind == "export" & nzchar(index$name), ]
missing <- exports$name[exports$localized == "yes" &
                          !vapply(exports$name, exists, logical(1), envir = SCP_local, inherits = FALSE)]
check(length(missing) == 0, paste("all localized exports defined", if (length(missing)) paste(missing, collapse = ", ")))

cat("\n", length(failures), "failure(s)\n", sep = "")
if (length(failures)) quit(status = 1)
