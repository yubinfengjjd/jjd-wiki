# Render the gallery replica from the saved cell-level membership table.
# Run from this entry directory: Rscript code/render.R
# The native core is in code/scp_venn_native.R; no SCP package or Wiki path is
# required at run time.
file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
entry_dir <- if (length(file_arg)) dirname(dirname(normalizePath(sub("^--file=", "", file_arg[1])))) else normalizePath(getwd(), mustWork = TRUE)

source(file.path(entry_dir, "code", "core.R"))
spec <- jsonlite::fromJSON(file.path(entry_dir, "data", "figure_spec.json"), simplifyVector = TRUE)
params <- spec$params
membership <- read.csv(file.path(entry_dir, "data", "render-cell-membership.csv"),
                       stringsAsFactors = FALSE, check.names = FALSE)
cell_col <- params$cell_col %||% "cell"
stopifnot(cell_col %in% names(membership))
stopifnot(!anyDuplicated(membership[[cell_col]]))
rownames(membership) <- as.character(membership[[cell_col]])
set_cols <- unlist(params$set_cols, use.names = FALSE)
stopifnot(all(set_cols %in% names(membership)))

tab <- scp_venn_table(
  meta.data = membership[, set_cols, drop = FALSE],
  stat.by = set_cols,
  stat_level = params$set_level %||% "TRUE",
  palette = params$palette %||% "Paired",
  palcolor = params$palcolor,
  seed = params$seed %||% 11,
  scp = SCP_helpers
)
p <- plot_scp_venn(
  tab,
  alpha = params$alpha %||% 1,
  label.size = params$label_size %||% 3.5,
  label.fg = params$label_fg %||% "black",
  label.bg = params$label_bg %||% "white",
  label.bg.r = params$label_bg_r %||% 0.1,
  title = params$title,
  subtitle = params$subtitle,
  seed = params$seed %||% 11
)

width_in <- params$width_in %||% 8
height_in <- params$height_in %||% 6
dpi <- params$dpi %||% 150
dir.create(file.path(entry_dir, "output"), showWarnings = FALSE)
ggsave(file.path(entry_dir, "output", "replica.png"), p,
       width = width_in, height = height_in, dpi = dpi, bg = "white")
ggsave(file.path(entry_dir, "output", "replica.pdf"), p,
       width = width_in, height = height_in, device = grDevices::cairo_pdf, bg = "white")
if (requireNamespace("svglite", quietly = TRUE)) {
  ggsave(file.path(entry_dir, "output", "replica.svg"), p,
         width = width_in, height = height_in, device = svglite::svglite, bg = "white")
} else {
  grDevices::svg(file.path(entry_dir, "output", "replica.svg"), width = width_in, height = height_in)
  print(p)
  dev.off()
}
writeLines(capture.output(sessionInfo()), file.path(entry_dir, "output", "sessionInfo.txt"))
writeLines(c(
  paste("plot_type:", params$plot_type),
  paste("stat_type:", params$stat_type),
  paste("sets:", paste(set_cols, collapse = ",")),
  paste("set_level:", params$set_level),
  paste("size_in:", paste(width_in, height_in, sep = "x")),
  paste("dpi:", dpi),
  paste("png_md5:", unname(tools::md5sum(file.path(entry_dir, "output", "replica.png"))))
), file.path(entry_dir, "output", "run-summary.txt"))
cat("Wrote", file.path(entry_dir, "output", "replica.png"), "\n")
