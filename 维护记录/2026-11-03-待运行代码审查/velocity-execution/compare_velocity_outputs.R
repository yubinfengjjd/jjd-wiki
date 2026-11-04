# Compare real Seurat outputs without rerunning or changing velocity calculations.
args <- commandArgs(TRUE)
if (length(args) != 3L) stop("usage: compare_velocity_outputs.R <reference.rds> <actual.rds> <report.json>")
suppressPackageStartupMessages(library(SeuratObject))
suppressPackageStartupMessages(library(Matrix))
reference <- readRDS(args[[1]])
actual <- readRDS(args[[2]])
stopifnot(inherits(reference, "Seurat"), inherits(actual, "Seurat"))

compare <- function(left, right) {
  equality <- all.equal(left, right, tolerance = 0, check.attributes = TRUE)
  report <- list(identical_object = identical(left, right), equal_zero_tolerance = isTRUE(equality),
                 differences = if (isTRUE(equality)) list() else as.list(equality),
                 reference_class = class(left), actual_class = class(right),
                 dimensions_identical = identical(dim(left), dim(right)),
                 dimnames_identical = identical(dimnames(left), dimnames(right)))
  if ((is.numeric(left) || inherits(left, "Matrix")) &&
      (is.numeric(right) || inherits(right, "Matrix")) && identical(dim(left), dim(right))) {
    a <- as.numeric(as.matrix(left))
    b <- as.numeric(as.matrix(right))
    if (length(a) == length(b)) {
      finite <- is.finite(a) & is.finite(b)
      report$numeric_values_identical <- identical(a, b)
      report$nonfinite_positions_identical <- identical(is.finite(a), is.finite(b)) && identical(is.na(a), is.na(b))
      report$max_absolute_difference_finite <- if (any(finite)) max(abs(a[finite] - b[finite])) else NULL
      report$unequal_finite_values <- sum(a[finite] != b[finite])
      report$finite_values_compared <- sum(finite)
    }
  }
  report
}

report <- list(scope = "Conversion-boundary repeatability against the old converter on the same computed public case; not an independent whole-SCP algorithm comparison.",
               reference_cells = ncol(reference), actual_cells = ncol(actual),
               cell_identifiers_order_identical = identical(colnames(reference), colnames(actual)),
               reference_assays = names(reference@assays), actual_assays = names(actual@assays),
               assay_names_identical = identical(names(reference@assays), names(actual@assays)),
               metadata = compare(reference@meta.data, actual@meta.data), assays = list(), reductions = list(), graphs = list())
report$assay_names_same_set <- setequal(names(reference@assays), names(actual@assays))
report$metadata_column_names_same_set <- setequal(colnames(reference@meta.data), colnames(actual@meta.data))
report$metadata_columns <- lapply(intersect(colnames(reference@meta.data), colnames(actual@meta.data)), function(name) {
  compare(reference@meta.data[[name]], actual@meta.data[[name]])
})
names(report$metadata_columns) <- intersect(colnames(reference@meta.data), colnames(actual@meta.data))
for (assay in intersect(names(reference@assays), names(actual@assays))) {
  left <- reference[[assay]]
  right <- actual[[assay]]
  common <- intersect(SeuratObject::Layers(left), SeuratObject::Layers(right))
  layers <- lapply(common, function(layer) compare(SeuratObject::LayerData(left, layer = layer),
                                                  SeuratObject::LayerData(right, layer = layer)))
  names(layers) <- common
  report$assays[[assay]] <- list(reference_layers = SeuratObject::Layers(left), actual_layers = SeuratObject::Layers(right),
                                layer_names_identical = identical(SeuratObject::Layers(left), SeuratObject::Layers(right)), layers = layers)
}
report$reduction_names_identical <- identical(names(reference@reductions), names(actual@reductions))
for (name in intersect(names(reference@reductions), names(actual@reductions))) {
  report$reductions[[name]] <- list(embeddings = compare(Embeddings(reference[[name]]), Embeddings(actual[[name]])),
                                   loadings = compare(Loadings(reference[[name]]), Loadings(actual[[name]])),
                                   stdev = compare(Stdev(reference[[name]]), Stdev(actual[[name]])))
}
report$graph_names_identical <- identical(names(reference@graphs), names(actual@graphs))
report$graph_names_same_set <- setequal(names(reference@graphs), names(actual@graphs))
for (name in intersect(names(reference@graphs), names(actual@graphs))) {
  report$graphs[[name]] <- compare(reference@graphs[[name]], actual@graphs[[name]])
}
report$misc <- compare(reference@misc, actual@misc)
report$misc_names_same_set <- setequal(names(reference@misc), names(actual@misc))
report$misc_by_name <- lapply(intersect(names(reference@misc), names(actual@misc)), function(name) {
  compare(reference@misc[[name]], actual@misc[[name]])
})
names(report$misc_by_name) <- intersect(names(reference@misc), names(actual@misc))
report$tools <- compare(reference@tools, actual@tools)
jsonlite::write_json(report, args[[3]], auto_unbox = TRUE, pretty = TRUE, digits = NA, null = "null")
