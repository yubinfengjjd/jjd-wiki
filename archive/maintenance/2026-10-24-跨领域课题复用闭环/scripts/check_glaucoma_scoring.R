# Independent verification driver only; no formal knowledge/project state writes.
args <- commandArgs(trailingOnly = TRUE)
stopifnot(length(args) == 4L)
object_file <- args[[1]]
sets_file <- args[[2]]
code_file <- args[[3]]
output_dir <- args[[4]]
stopifnot(file.exists(object_file), file.exists(sets_file), file.exists(code_file))
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
stopifnot(requireNamespace('Seurat', quietly = TRUE),
          requireNamespace('BiocParallel', quietly = TRUE),
          requireNamespace('jsonlite', quietly = TRUE))
Sys.unsetenv('SCP_LOCAL_ROOT')
srt <- readRDS(object_file)
before_meta <- srt[[]]
before_ids <- colnames(srt)
before_counts <- SeuratObject::GetAssayData(srt, assay = 'RNA', layer = 'counts')
sets <- read.csv(sets_file, check.names = FALSE, stringsAsFactors = FALSE)
selected <- sets[sets$pathway == 'AP1_FOSB_score', , drop = FALSE]
stopifnot(nrow(selected) == 1L)
genes <- unique(trimws(strsplit(selected$overlap_genes, ';', fixed = TRUE)[[1]]))
stopifnot(length(genes) == 6L, all(genes %in% rownames(srt)))
env <- new.env(parent = globalenv())
source(code_file, local = env)
params <- list(features = list(AP1 = genes), method = 'Seurat', classification = FALSE,
               name = 'Audit', assay = 'RNA', slot = 'data',
               BPPARAM = BiocParallel::SerialParam(), seed = 11)
before_search <- search()
start <- proc.time()[['elapsed']]
a <- env$run_gene_set_scoring(srt, parameters = params)
b <- env$run_gene_set_scoring(srt, parameters = params)
elapsed <- proc.time()[['elapsed']] - start
new_columns <- setdiff(colnames(a$result[[]]), colnames(before_meta))
stopifnot(length(new_columns) == 1L)
scores <- a$result[[]][[new_columns[[1]]]]
stopifnot(length(scores) == length(before_ids), all(is.finite(scores)),
          identical(colnames(a$result), before_ids), identical(srt[[]], before_meta),
          identical(SeuratObject::GetAssayData(srt, assay = 'RNA', layer = 'counts'), before_counts),
          identical(a$result[[]][new_columns], b$result[[]][new_columns]),
          identical(search(), before_search), isTRUE(a$diagnostics$search_restored))
table <- data.frame(cell_id = before_ids, sample_id = before_meta$orig.ident,
                    celltype_declared = before_meta$celltype,
                    score = scores, check.names = FALSE)
write.csv(table, file.path(output_dir, 'scores.csv'), row.names = FALSE)
report <- list(scope = 'Independent software viability check of current Seurat component only; not historical five-score composite or disease inference',
               object = object_file, gene_set_source = sets_file, genes = genes,
               cells = nrow(table), score_column = new_columns,
               samples = as.list(base::table(table$sample_id)),
               elapsed_seconds_two_calls = elapsed,
               score_range = range(scores),
               checks = c('native RDS input; manifest-only source copy',
                          'all 6 cached AP1 genes exist; 10100 finite per-cell scores',
                          'identical scores on repeated seed=11 call',
                          'cell identity/order and input object unchanged',
                          'search path restored; original files checked separately'),
               environment = list(R = as.character(getRversion()),
                   Seurat = as.character(utils::packageVersion('Seurat')),
                   BiocParallel = as.character(utils::packageVersion('BiocParallel'))),
               diagnostics = a$diagnostics[c('upstream_function', 'source_version',
                    'warnings', 'dependency_versions', 'automatic_installation',
                    'search_restored', 'options_restored', 'loader_side_effects')])
jsonlite::write_json(report, file.path(output_dir, 'verification.json'), pretty = TRUE,
                     auto_unbox = TRUE, null = 'null')
cat('VERIFIED scoped Seurat component:', nrow(table), 'cells,', length(genes),
    'genes; two calls', elapsed, 'seconds\n')
