# test_scp_tables.R
# Synthetic, dependency-free checks for the SCP->wiki table adapters.
# Run with: Rscript test_scp_tables.R

args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args, value = TRUE)
root <- if (length(file_arg)) dirname(normalizePath(sub("^--file=", "", file_arg[1]))) else getwd()
source(file.path(root, "scp_tables.R"))

failures <- character()
check <- function(ok, label) {
  if (isTRUE(ok)) {
    cat("PASS:", label, "\n")
  } else {
    cat("FAIL:", label, "\n")
    failures <<- c(failures, label)
  }
}
expect_error <- function(expr, label) {
  ok <- tryCatch({ force(expr); FALSE }, error = function(e) TRUE)
  check(ok, label)
}

coords <- data.frame(
  cell_id = paste0("c", 1:6),
  umap_1 = c(-1, 0, 1, -1, 0, 1),
  umap_2 = c(0, 1, 0, 1, 0, 1),
  stringsAsFactors = FALSE
)
meta <- data.frame(
  cell_id = paste0("c", 1:6),
  group = rep(c("Control", "Glaucoma"), each = 3),
  celltype = rep(c("A", "A", "B"), 2),
  score = c(1, 2, 3, 4, 5, 6),
  stringsAsFactors = FALSE
)
expr_wide <- data.frame(
  cell_id = paste0("c", 1:6),
  G1 = c(0, 1, 2, 0, 1, 2),
  G2 = c(2, 1, 0, 2, 1, 0),
  stringsAsFactors = FALSE
)
avg <- data.frame(
  group = rep(c("Control", "Glaucoma"), each = 2),
  feature = rep(c("G1", "G2"), 2),
  value = c(1.0, 1.5, 2.0, 2.5),
  stringsAsFactors = FALSE
)
pct <- data.frame(
  group = rep(c("Control", "Glaucoma"), each = 2),
  feature = rep(c("G1", "G2"), 2),
  value = c(50, 60, 70, 80),
  stringsAsFactors = FALSE
)
target <- data.frame(feature = c("G1", "G2"), target_group = c("A", "B"))

g <- scp_umap_groups(coords, meta)
check(identical(names(g), c("cell_id", "umap_1", "umap_2", "group")), "umap_groups columns")
check(nrow(g) == 6 && identical(g$group, meta$group), "umap_groups order and values")

fl <- scp_umap_feature_long(coords, expr_wide, meta, features = c("G1", "G2"))
check(identical(names(fl), c("cell_id", "umap_1", "umap_2", "group", "feature", "value")),
      "umap_feature_long columns")
check(nrow(fl) == 12 && setequal(unique(fl$feature), c("G1", "G2")), "umap_feature_long rows")

fl2 <- scp_umap_feature_long(
  coords,
  data.frame(cell_id = rep(paste0("c", 1:6), 2),
             feature = rep(c("G1", "G2"), each = 6),
             value = c(expr_wide$G1, expr_wide$G2)),
  meta, features = c("G1", "G2")
)
check(isTRUE(all.equal(fl, fl2)), "umap_feature_long wide and long inputs agree")

d <- scp_dotplot_long(avg, pct, target_group = target, pct_scale = "percent")
check(identical(names(d), c("group", "feature", "avg_expression", "pct_expressed", "target_group")),
      "dotplot_long columns")
check(nrow(d) == 4 && all(d$pct_expressed >= 0 & d$pct_expressed <= 100), "dotplot_long percent range")
check(identical(d$target_group, c("A", "B", "A", "B")), "dotplot_long target mapping")

d2 <- scp_dotplot_long(avg, transform(pct, value = value / 100), pct_scale = "fraction")
check(isTRUE(all.equal(d$pct_expressed, d2$pct_expressed)), "dotplot_long fraction conversion")

gv <- scp_grouped_values(meta, "score")
check(identical(names(gv), c("celltype", "group", "value")), "grouped_values columns")
check(nrow(gv) == 6 && identical(gv$value, meta$score), "grouped_values values")

prop <- scp_cell_proportions(meta)
check(identical(names(prop), c("group", "celltype", "proportion")), "cell_proportions columns")
check(all(abs(tapply(prop$proportion, prop$group, sum) - 1) < 1e-8), "cell_proportions sum to 1")

cm <- scp_cell_metadata(meta, "group", "celltype")
check(identical(names(cm), c("cell", "group", "stat")), "cell_metadata columns")
check(nrow(cm) == nrow(meta) && !anyDuplicated(cm$cell), "cell_metadata one row per cell")
check(identical(cm$group, meta$group) && identical(cm$stat, meta$celltype), "cell_metadata values mapped")

tmp <- tempfile("scp_tables_")
dir.create(tmp)
p <- scp_write_interface(g, "render-umap-groups", tmp)
check(file.exists(p) && identical(names(utils::read.csv(p)), c("cell_id", "umap_1", "umap_2", "group")),
      "write_interface round trip")
unlink(tmp, recursive = TRUE)

expect_error(scp_umap_groups(rbind(coords, coords[1, ]), meta), "duplicate coords rejected")
expect_error(scp_umap_groups(coords, meta[-1, ]), "missing meta cell rejected")
expect_error(scp_umap_feature_long(coords, expr_wide, meta, features = "G3"), "unknown feature rejected")
expect_error(scp_dotplot_long(avg, transform(pct, value = value / 100)), "fraction without flag rejected")
expect_error(scp_dotplot_long(avg, transform(pct, value = value + 100), pct_scale = "percent"), "percent over 100 rejected")
expect_error(scp_cell_proportions(transform(meta, group = NA)), "NA group rejected")
expect_error(scp_cell_metadata(transform(meta, group = NA), "group", "celltype"), "cell_metadata NA group rejected")
expect_error(scp_cell_metadata(transform(meta, cell_id = "same"), "group", "celltype", cell_col = "cell_id"), "cell_metadata duplicate cells rejected")

cat("\n", length(failures), "failure(s)\n", sep = "")
if (length(failures)) quit(status = 1)
