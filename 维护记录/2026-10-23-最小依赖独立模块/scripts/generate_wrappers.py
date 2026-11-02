"""Generate standalone analysis.R wrappers for the extracted SCP modules.

Run from the maintenance directory with the general Python interpreter:
  D:/anaconda/python.exe -X utf8 scripts/generate_wrappers.py pilot
"""

import sys
from pathlib import Path

OUT = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("pilot")

HEADER = """# Standalone minimal module: {title}.
# GPL (>= 3). Extracted from SCP-local v0.5.6. Algorithm logic is copied
# verbatim; see runtime.json for the source map and verified scope.
#
# Copy this code/ directory only. No SCP-local bundle is required or read.
# Source-time side effects: function definitions only. Runtime packages are
# checked and attached per call, then detached if this call attached them.
# Automatic installation is disabled. The deprecated `bundle` argument is
# accepted for compatibility and is never read.

.scp_impl <- new.env(parent = globalenv())
.scp_impl_dir <- local({{
  file <- NULL
  for (i in seq_len(sys.nframe())) {{
    candidate <- tryCatch(sys.frame(i)$ofile, error = function(e) NULL)
    if (!is.null(candidate) && nzchar(candidate)) {{
      file <- candidate
      break
    }}
  }}
  if (!is.null(file)) dirname(normalizePath(file, mustWork = TRUE)) else normalizePath(getwd(), mustWork = TRUE)
}})
sys.source(file.path(.scp_impl_dir, "{native}"), envir = .scp_impl)

# Compatibility shim: SeuratObject >= 5 makes the `slot` argument of
# GetAssayData defunct. SCP 0.5.6 calls GetAssayData(slot = ...); map the same
# layer name explicitly. No value or default changes.
.scp_impl$GetAssayData <- function(object, assay = NULL, slot = NULL, layer = NULL, ...) {{
  if (is.null(layer) && !is.null(slot)) layer <- slot
  SeuratObject::GetAssayData(object = object, assay = assay, layer = layer, ...)
}}

# Compatibility shim: SeuratObject >= 5 makes Assays(object, <assay name>)
# defunct. SCP 0.5.6 uses it to fetch one Assay object. Restore the old
# behavior without changing the object or defaults.
.scp_impl$Assays <- function(object, slot = NULL, ...) {{
  if (!is.null(slot)) return(methods::slot(object = object, name = 'assays')[[slot]])
  SeuratObject::Assays(object = object, ...)
}}
"""

RUN_HELPERS = """
# Fail-only replacements for the upstream installation helpers.
.scp_impl$check_R <- function(packages, ...) {
  for (spec in packages) {
    parts <- strsplit(spec, '@|==')[[1]]
    package <- sub('^.*/', '', parts[1])
    if (!requireNamespace(package, quietly = TRUE)) {
      stop('Missing R dependency: ', package, '; automatic installation is disabled', call. = FALSE)
    }
    if (length(parts) > 1 && utils::packageVersion(package) < package_version(parts[2])) {
      stop('R dependency too old: ', package, '; requires >= ', parts[2], call. = FALSE)
    }
  }
  invisible(NULL)
}
.scp_impl$check_Python <- function(packages, ...) {
  if (!nzchar(Sys.getenv('RETICULATE_PYTHON'))) {
    stop('Set RETICULATE_PYTHON to an existing project interpreter; installation disabled', call. = FALSE)
  }
  for (package in packages) {
    module <- sub('[-].*', '', sub('==.*', '', package))
    if (!reticulate::py_module_available(module)) {
      stop('Missing Python dependency: ', package, '; automatic installation is disabled', call. = FALSE)
    }
  }
  invisible(NULL)
}
.scp_impl$PrepareEnv <- function(...) {
  stop('Automatic environment creation disabled', call. = FALSE)
}
.scp_impl$conda_install <- function(...) {
  stop('Automatic environment installation disabled', call. = FALSE)
}

.scp_check_packages <- function(packages) {
  for (package in unique(packages)) {
    if (!requireNamespace(package, quietly = TRUE)) {
      stop('Missing R dependency: ', package, '; automatic installation is disabled', call. = FALSE)
    }
  }
}
.scp_attach <- function(packages) {
  packages <- unique(packages)
  attached <- vapply(packages, function(p) paste0('package:', p) %in% search(), logical(1))
  new <- packages[!attached]
  for (package in new) {
    suppressPackageStartupMessages(library(package, character.only = TRUE, quietly = TRUE))
  }
  new
}
.scp_detach <- function(packages) {
  for (package in rev(packages)) {
    try(detach(paste0('package:', package), character.only = TRUE, unload = FALSE), silent = TRUE)
  }
}
.scp_load_plot_data <- function() {
  file <- file.path(.scp_impl_dir, 'data', 'palette_list.rda')
  if (file.exists(file)) load(file, envir = .scp_impl)
  invisible(NULL)
}

.scp_run <- function(name, arguments, required, optional = list(), features = character()) {
  use <- required
  for (feature in features) {
    add <- optional[[feature]]
    if (!is.null(add)) use <- c(use, add)
  }
  .scp_check_packages(use)
  newly <- .scp_attach(use)
  old_options <- options()
  on.exit(.scp_detach(newly), add = TRUE)
  on.exit(options(old_options), add = TRUE)
  if ('plot' %in% features) .scp_load_plot_data()
  warnings <- character()
  result <- withCallingHandlers(
    do.call(.scp_impl[[name]], arguments),
    warning = function(w) warnings <<- c(warnings, conditionMessage(w))
  )
  packages <- loadedNamespaces()
  versions <- setNames(lapply(packages, function(x) as.character(utils::packageVersion(x))), packages)
  list(
    result = result,
    diagnostics = list(
      upstream_function = name,
      source_version = 'SCP-local 0.5.6; minimal call closure',
      parameters = arguments[setdiff(names(arguments), c('srt', 'srtMerge', 'srt_query', 'srt_ref'))],
      warnings = unique(warnings),
      dependency_versions = versions,
      automatic_installation = FALSE,
      loader_side_effects = 'none; only packages needed by this call are attached, and detached if newly attached',
      rng = 'upstream function may set/change global RNG state'
    )
  )
}
"""

SIMPLE_ENTRY = """
# Source mapping: SCP-local/{source}; no algorithm rewritten.
{fn} <- function({sig}, bundle = NULL, parameters = list()) {{
  if (!is.null(bundle)) {{
    warning('`bundle` is deprecated and ignored; this module uses only its local call closure', call. = FALSE)
  }}
  if (!is.list(parameters) || (length(parameters) &&
      (is.null(names(parameters)) || any(!nzchar(names(parameters))) || anyDuplicated(names(parameters))))) {{
    stop('parameters must be a uniquely named list')
  }}
  .scp_run(
    '{upstream}',
    c({args}, parameters),
    required = c({required}),
    optional = list({optional}),
    features = .scp_features(parameters)
  )
}}
"""

CONFIGS = {
    "cell-quality-control": dict(
        title="SCP RunCellQC (cell quality control)",
        native="cellqc_native.R",
        source="R/SCP-cellqc.R:RunCellQC (+ doublet helpers)",
        fn="run_cell_quality_control",
        sig="srt",
        upstream="RunCellQC",
        args="list(srt = srt)",
        required=["Seurat", "SeuratObject", "Matrix", "rlang"],
        optional=[("doublet:scDblFinder", ["scDblFinder"]), ("doublet:scds_cxds", ["scds"]),
                  ("doublet:scds_bcds", ["scds"]), ("doublet:scds_hybrid", ["scds"]),
                  ("doublet:Scrublet", ["reticulate"]), ("doublet:DoubletDetection", ["reticulate"])],
        features="""{
  metrics <- parameters$qc_metrics
  if (is.null(metrics)) metrics <- c('doublets', 'outlier', 'umi', 'gene', 'mito', 'ribo', 'ribo_mito_ratio', 'species')
  features <- character()
  if ('doublets' %in% metrics) {
    methods <- parameters$db_method
    if (is.null(methods)) methods <- 'scDblFinder'
    features <- c(features, paste0('doublet:', methods))
  }
  features
}""",
        post="""  metrics <- parameters$qc_metrics
  if (is.null(metrics)) metrics <- c('doublets', 'outlier', 'umi', 'gene', 'mito', 'ribo', 'ribo_mito_ratio', 'species')
  if ('doublets' %in% metrics) {
    classes <- grep('^db\\\\..*_class$', colnames(out$result[[]]), value = TRUE)
    if (!length(classes)) {
      stop('Upstream doublet-calling produced no db.<method>_class column; ',
           'the upstream tryCatch may have suppressed the real error', call. = FALSE)
    }
  }
  out""",
    ),
    "doublet-detection": dict(
        title="SCP RunDoubletCalling",
        native="doublet_native.R",
        source="R/SCP-cellqc.R:RunDoubletCalling (+ db_* helpers)",
        fn="run_doublet_detection",
        sig="srt",
        upstream="RunDoubletCalling",
        args="list(srt = srt)",
        required=["Seurat", "SeuratObject", "Matrix", "rlang"],
        optional=[("doublet:scDblFinder", ["scDblFinder"]), ("doublet:scds_cxds", ["scds"]),
                  ("doublet:scds_bcds", ["scds"]), ("doublet:scds_hybrid", ["scds"]),
                  ("doublet:Scrublet", ["reticulate"]), ("doublet:DoubletDetection", ["reticulate"])],
        features="""{
  methods <- parameters$db_method
  if (is.null(methods)) methods <- 'scDblFinder'
  paste0('doublet:', methods)
}""",
        post="""  methods <- parameters$db_method
  if (is.null(methods)) methods <- 'scDblFinder'
  for (method in methods) {
    column <- paste0('db.', method, '_class')
    if (!column %in% colnames(out$result[[]])) {
      stop('Upstream doublet-calling produced no ', column, ' column; ',
           'the upstream tryCatch may have suppressed the real error', call. = FALSE)
    }
  }
  out""",
    ),
    "dimensionality-reduction": dict(
        title="SCP RunDimReduction",
        native="dimreduction_native.R",
        source="R/SCP-workflow.R:RunDimReduction (+ RunUMAP2/RunNMF/... drivers)",
        fn="run_dimensionality_reduction",
        sig="srt",
        upstream="RunDimReduction",
        args="list(srt = srt)",
        required=["Seurat", "SeuratObject", "Matrix", "rlang", "data.table", "uwot", "intrinsicDimension"],
        optional=[("linear:nmf", ["NMF"]), ("linear:glmpca", ["glmpca"]),
                  ("nonlinear:dm", ["destiny"]), ("nonlinear:phate", ["reticulate"]),
                  ("nonlinear:pacmap", ["reticulate"]), ("nonlinear:trimap", ["reticulate"]),
                  ("nonlinear:largevis", ["reticulate"])],
        features="""{
  features <- character()
  if (!is.null(parameters$linear_reduction)) {
    features <- c(features, paste0('linear:', parameters$linear_reduction))
  }
  if (!is.null(parameters$nonlinear_reduction)) {
    features <- c(features, paste0('nonlinear:', parameters$nonlinear_reduction))
  }
  features
}""",
    ),
    "batch-integration": dict(
        title="SCP Harmony_integrate / Seurat_integrate",
        native="integration_native.R",
        source="R/SCP-workflow.R:Harmony_integrate and Seurat_integrate",
        fn=None,
        required=["Seurat", "SeuratObject", "Matrix", "rlang", "data.table", "uwot",
                  "intrinsicDimension", "proxyC", "dplyr", "future", "future.apply"],
        optional=[("harmony", ["harmony"]), ("tfidf", ["Signac"]), ("python:leidenalg", ["reticulate"])],
        features="""{
  features <- character()
  if (identical(parameters$normalization_method, 'TFIDF')) features <- c(features, 'tfidf')
  if (identical(parameters$cluster_algorithm, 'leiden')) features <- c(features, 'python:leidenalg')
  features
}""",
        entries=[
            ("run_batch_integration", "srt", "Harmony_integrate", "list(srtMerge = srt)", "harmony"),
            ("run_seurat_integration", "srt, batch", "Seurat_integrate", "list(srtMerge = srt, batch = batch)", "seurat"),
        ],
    ),
    "cell-type-annotation": dict(
        title="SCP RunSingleR",
        native="annotation_native.R",
        source="R/SCP-cell_annotation.R:RunSingleR",
        fn="run_cell_type_annotation",
        sig="srt_query, srt_ref",
        upstream="RunSingleR",
        args="list(srt_query = srt_query, srt_ref = srt_ref)",
        required=["Seurat", "SeuratObject", "Matrix", "rlang", "SingleR",
                  "SingleCellExperiment", "SummarizedExperiment"],
        optional=[],
    ),
    "differential-expression": dict(
        title="SCP RunDEtest",
        native="de_native.R",
        source="R/SCP-analysis.R:RunDEtest",
        fn="run_differential_expression",
        sig="srt",
        upstream="RunDEtest",
        args="list(srt = srt)",
        required=["Seurat", "SeuratObject", "Matrix", "BiocParallel", "rlang"],
        optional=[("test:limma", ["limma"]), ("test:edgeR", ["edgeR"]), ("test:DESeq2", ["DESeq2"]),
                  ("conserved", ["BiocParallel"])],
        features="""{
  features <- character()
  method <- parameters$test.use
  if (!is.null(method) && method %in% c('limma', 'limma-trend', 'limma-voom')) features <- c(features, 'test:limma')
  if (!is.null(method) && grepl('^edgeR', method)) features <- c(features, 'test:edgeR')
  if (!is.null(method) && grepl('^DESeq2', method)) features <- c(features, 'test:DESeq2')
  features
}""",
    ),
    "gene-set-enrichment": dict(
        title="SCP RunEnrichment",
        native="enrichment_native.R",
        source="R/SCP-analysis.R:RunEnrichment (+ PrepareDB/GeneConvert)",
        fn="run_gene_set_enrichment",
        sig="gene_ids",
        upstream="RunEnrichment",
        args="list(geneID = gene_ids)",
        required=["clusterProfiler", "BiocParallel", "rlang"],
        optional=[("database", ["org.Hs.eg.db", "org.Mm.eg.db", "GO.db", "msigdbr", "gson",
                                "AnnotationDbi", "biomaRt", "R.cache", "reshape2", "data.table"]),
                  ("idconvert", ["biomaRt", "AnnotationDbi", "R.cache", "reshape2", "data.table"])],
        features="""{
  features <- character()
  if (is.null(parameters$TERM2GENE)) features <- c(features, 'database')
  idtype <- parameters$IDtype
  result_idtype <- parameters$result_IDtype
  if (is.null(idtype)) idtype <- 'symbol'
  if (is.null(result_idtype)) result_idtype <- 'symbol'
  if (!identical(idtype, result_idtype)) features <- c(features, 'idconvert')
  features
}""",
    ),
    "gene-set-scoring": dict(
        title="SCP CellScoring",
        native="scoring_native.R",
        source="R/SCP-analysis.R:CellScoring (+ AddModuleScore2)",
        fn="run_gene_set_scoring",
        sig="srt",
        upstream="CellScoring",
        args="list(srt = srt)",
        required=["Seurat", "SeuratObject", "Matrix", "BiocParallel", "rlang", "ggplot2"],
        optional=[("method:AUCell", ["AUCell"]), ("method:UCell", ["UCell"]),
                  ("database", ["clusterProfiler", "biomaRt", "R.cache", "AnnotationDbi", "reshape2"])],
        features="""{
  features <- character()
  method <- parameters$method
  if (!is.null(method) && method %in% c('AUCell', 'UCell')) features <- c(features, paste0('method:', method))
  if (is.null(parameters$features)) features <- c(features, 'database')
  features
}""",
    ),
    "trajectory-inference": dict(
        title="SCP RunSlingshot",
        native="slingshot_native.R",
        source="R/SCP-analysis.R:RunSlingshot",
        fn="run_trajectory_inference",
        sig="srt",
        upstream="RunSlingshot",
        args="list(srt = srt)",
        required=["slingshot", "Seurat", "SeuratObject", "Matrix", "rlang"],
        optional=[("plot", ["ggplot2", "patchwork", "ggrepel", "ggnewscale", "circlize",
                            "gtable", "plotly", "dplyr", "reshape2", "scales", "BiocParallel", "grid"])],
        features="""{
  features <- character()
  show <- parameters$show_plot
  if (is.null(show) || isTRUE(show)) features <- c(features, 'plot')
  features
}""",
    ),
    "dynamic-feature-analysis": dict(
        title="SCP RunDynamicFeatures",
        native="dynamic_native.R",
        source="R/SCP-analysis.R:RunDynamicFeatures",
        fn="run_dynamic_feature_analysis",
        sig="srt",
        upstream="RunDynamicFeatures",
        args="list(srt = srt)",
        required=["Seurat", "SeuratObject", "Matrix", "BiocParallel", "mgcv", "rlang"],
        optional=[],
    ),
    "reference-mapping": dict(
        title="SCP RunSeuratMap projection branch",
        native="reference_native.R",
        source="R/SCP-projection.R:RunSeuratMap (+ RunKNNMap/Standard_SCP)",
        fn="run_reference_mapping",
        sig="srt_query, srt_ref",
        upstream="RunSeuratMap",
        args="list(srt_query = srt_query, srt_ref = srt_ref)",
        required=["Seurat", "SeuratObject", "Matrix", "rlang", "data.table", "uwot",
                  "intrinsicDimension", "dplyr", "proxyC"],
        optional=[("tfidf", ["Signac"]), ("python:leidenalg", ["reticulate"])],
        features="""{
  features <- character()
  if (identical(parameters$normalization_method, 'TFIDF')) features <- c(features, 'tfidf')
  if (identical(parameters$cluster_algorithm, 'leiden')) features <- c(features, 'python:leidenalg')
  features
}""",
    ),
    "rna-velocity": dict(
        title="SCP RunSCVELO",
        native="velocity_native.R",
        source="R/SCP-analysis.R:RunSCVELO",
        fn="run_rna_velocity",
        sig="srt",
        upstream="RunSCVELO",
        args="list(srt = srt)",
        required=["reticulate", "Seurat", "SeuratObject", "Matrix", "rlang"],
        optional=[("magic", ["reticulate"]), ("plot", ["ggplot2", "patchwork", "ggrepel",
                  "ggnewscale", "circlize", "gtable", "plotly", "dplyr", "reshape2", "scales", "BiocParallel", "grid"])],
        features="""{
  features <- character()
  if (isTRUE(parameters$magic_impute)) features <- c(features, 'magic')
  show <- parameters$show_plot
  if (is.null(show) || isTRUE(show)) features <- c(features, 'plot')
  features
}""",
    ),
}

MONOCLE = {
    "monocle2": dict(
        title="SCP RunMonocle2 (trajectory branch)",
        native="monocle2_native.R",
        source="R/SCP-analysis.R:RunMonocle2 (+ orderCells helpers)",
        fn="run_trajectory_monocle2",
        sig="srt",
        upstream="RunMonocle2",
        args="list(srt = srt)",
        required=["monocle", "DDRTree", "VGAM", "BiocGenerics", "Biobase", "Seurat",
                  "SeuratObject", "Matrix", "igraph", "ggplot2", "rlang"],
        optional=[],
        features="character()",
    ),
    "monocle3": dict(
        title="SCP RunMonocle3 (trajectory branch)",
        native="monocle3_native.R",
        source="R/SCP-analysis.R:RunMonocle3",
        fn="run_trajectory_monocle3",
        sig="srt",
        upstream="RunMonocle3",
        args="list(srt = srt)",
        required=["monocle3", "SingleCellExperiment", "SummarizedExperiment", "igraph",
                  "Seurat", "SeuratObject", "Matrix", "rlang"],
        optional=[],
        features="character()",
    ),
}


def rvec(values):
    return ", ".join("'" + v + "'" for v in values)


def optional_map(pairs):
    return ", ".join("'" + k + "' = c(" + rvec(v) + ")" for k, v in pairs)


def build(cfg, extra_entries=None):
    text = HEADER.format(title=cfg["title"], native=cfg["native"])
    text += RUN_HELPERS
    if "features" in cfg:
        text += "\n.scp_features <- function(parameters) " + cfg["features"] + "\n"
    else:
        text += "\n.scp_features <- function(parameters) character()\n"
    entries = cfg.get("entries") or [(cfg["fn"], cfg["sig"], cfg["upstream"], cfg["args"], None)]
    for fn, sig, upstream, args, feature in entries:
        req = cfg["required"]
        pkg = "c(" + rvec(req) + ")"
        feats = cfg.get("features_expr", ".scp_features(parameters)")
        call = SIMPLE_ENTRY.format(
            fn=fn, sig=sig, upstream=upstream, args=args,
            source=cfg["source"], required=rvec(req),
            optional=optional_map(cfg["optional"]),
        )
        call = call.replace("required = c(", "required = c(")
        if fn == "run_seurat_integration":
            text += "\n\n# Source mapping: SCP-local/" + cfg["source"] + "; no algorithm rewritten.\n" + call.replace(
                "features = .scp_features(parameters)", "features = .scp_features(parameters)")
        else:
            text += call
        if fn == "run_batch_integration":
            # Harmony branch always requires the harmony package.
            text = text.replace(
                ".scp_run(\n    'Harmony_integrate',",
                ".scp_run(\n    'Harmony_integrate',")
    if "post" in cfg:
        # Wrap the upstream call, then insert post-processing before the final close.
        text = text.replace(
            "  .scp_run(\n    '" + cfg["upstream"] + "',",
            "  out <- .scp_run(\n    '" + cfg["upstream"] + "',")
        last = text.rfind("}\n")
        text = text[:last] + cfg["post"] + "\n}\n"
    return text


def main():
    for method, cfg in CONFIGS.items():
        target = OUT / method / "code"
        target.mkdir(parents=True, exist_ok=True)
        native_src = Path("extracted") / cfg["native"]
        (target / cfg["native"]).write_text(native_src.read_text(encoding="utf-8"), encoding="utf-8")
        if cfg.get("entries"):
            text = HEADER.format(title=cfg["title"], native=cfg["native"]) + RUN_HELPERS
            text += "\n.scp_features <- function(parameters) " + cfg["features"] + "\n"
            for fn, sig, upstream, args, feature in cfg["entries"]:
                extra = ""
                if feature == "harmony":
                    extra = "  features <- c(.scp_features(parameters), 'harmony')\n"
                else:
                    extra = "  features <- .scp_features(parameters)\n"
                text += SIMPLE_ENTRY.format(
                    fn=fn, sig=sig, upstream=upstream, args=args,
                    source=cfg["source"], required=rvec(cfg["required"]),
                    optional=optional_map(cfg["optional"]),
                ).replace("features = .scp_features(parameters)", "features = features").replace(
                    "  .scp_run(", extra + "  .scp_run(")
            (target / "analysis.R").write_text(text, encoding="utf-8")
        elif method == "reference-mapping":
            text = HEADER.format(title=cfg["title"], native=cfg["native"]) + RUN_HELPERS
            text += "\n.scp_features <- function(parameters) " + cfg["features"] + "\n"
            text += SIMPLE_ENTRY.format(
                fn=cfg["fn"], sig=cfg["sig"], upstream=cfg["upstream"], args=cfg["args"],
                source=cfg["source"], required=rvec(cfg["required"]),
                optional=optional_map(cfg["optional"]),
            )
            (target / "analysis.R").write_text(text, encoding="utf-8")
            # keep the existing standalone label-transfer branch
            transfer = Path("E:/research-wiki/知识库/methods/reference-mapping/code/transfer.R")
            (target / "transfer.R").write_text(transfer.read_text(encoding="utf-8"), encoding="utf-8")
        else:
            text = build(cfg)
            (target / "analysis.R").write_text(text, encoding="utf-8")

    for name, cfg in MONOCLE.items():
        target = OUT / "trajectory-inference" / "code"
        target.mkdir(parents=True, exist_ok=True)
        native_src = Path("extracted") / cfg["native"]
        (target / cfg["native"]).write_text(native_src.read_text(encoding="utf-8"), encoding="utf-8")
        text = HEADER.format(title=cfg["title"], native=cfg["native"]) + RUN_HELPERS
        text += "\n.scp_features <- function(parameters) character()\n"
        text += SIMPLE_ENTRY.format(
            fn=cfg["fn"], sig=cfg["sig"], upstream=cfg["upstream"], args=cfg["args"],
            source=cfg["source"], required=rvec(cfg["required"]),
            optional=optional_map(cfg["optional"]),
        )
        (target / (name + ".R")).write_text(text, encoding="utf-8")


if __name__ == "__main__":
    main()
