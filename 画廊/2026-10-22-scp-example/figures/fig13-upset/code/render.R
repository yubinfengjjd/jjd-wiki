# Render the gallery replica from the saved cell-level membership table.
# Run from this entry directory: Rscript code/replica.R
# The native ggplot construction is in code/scp_upset_native.R; no SCP package
# or Wiki path is required at run time.
file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
entry_dir <- if (length(file_arg)) {
  dirname(dirname(normalizePath(sub("^--file=", "", file_arg[1]))))
} else {
  normalizePath(getwd(), mustWork = TRUE)
}

source(file.path(entry_dir, "code", "core.R"))
spec <- jsonlite::fromJSON(file.path(entry_dir, "data", "figure_spec.json"), simplifyVector = TRUE)
params <- spec$params
membership <- read.csv(file.path(entry_dir, "data", "render-cell-membership.csv"),
                       stringsAsFactors = FALSE, check.names = FALSE)
stopifnot(all(c("cell", "set", "member") %in% names(membership)))
sets <- as.character(params$set_levels)
stopifnot(length(sets) >= 2L, !anyDuplicated(sets))

wide <- scp_upset_membership(
  membership,
  cell_col = "cell", set_col = "set", member_col = "member",
  set_levels = sets
)
dat <- scp_upset_table(wide, stat.by = sets,
                       stat_level = params$stat_level %||% "TRUE")
p <- scp_upset_meta(
  wide,
  stat.by = sets,
  stat_level = params$stat_level %||% "TRUE",
  label.size = params$label_size %||% 3.5,
  label.fg = params$label_fg %||% "black",
  label.bg = params$label_bg %||% "white",
  label.bg.r = params$label_bg_r %||% 0.1,
  alpha = params$alpha %||% 1,
  show.legend = isTRUE(params$legend),
  xlab = params$xlab %||% "",
  fill_palette = params$fill_palette %||% "material-indigo",
  seed = params$seed %||% 11,
  scp = SCP_helpers
)

width_in <- params$width_in %||% 8
height_in <- params$height_in %||% 6
dpi <- params$dpi %||% 150
dir.create(file.path(entry_dir, "output"), showWarnings = FALSE)
ggsave(file.path(entry_dir, "output", "replica.png"), p,
       width = width_in, height = height_in, dpi = dpi, bg = "white")
ggsave(file.path(entry_dir, "output", "replica.pdf"), p,
       width = width_in, height = height_in, device = grDevices::cairo_pdf, bg = "white")
svg_device <- "svglite"
if (requireNamespace("svglite", quietly = TRUE)) {
  ggsave(file.path(entry_dir, "output", "replica.svg"), p,
         width = width_in, height = height_in, device = svglite::svglite, bg = "white")
} else {
  svg_device <- "grDevices::svg (text may be outlined)"
  grDevices::svg(file.path(entry_dir, "output", "replica.svg"), width = width_in, height = height_in)
  print(p)
  grDevices::dev.off()
}
sha256 <- function(path) digest::digest(file = path, algo = "sha256")
counts <- scp_upset_counts(dat)
writeLines(capture.output(sessionInfo()), file.path(entry_dir, "output", "sessionInfo.txt"))
writeLines(c(
  paste("plot_type:", params$plot_type),
  paste("sets:", paste(sets, collapse = ", ")),
  paste("cells:", nrow(wide)),
  paste("intersections:", nrow(counts)),
  paste("intersection_counts:", paste(sprintf("%s=%d", counts$intersection, counts$count), collapse = "; ")),
  paste("size_in:", paste(width_in, height_in, sep = "x")),
  paste("dpi:", dpi),
  paste("svg_device:", svg_device),
  paste("replica_png_sha256:", sha256(file.path(entry_dir, "output", "replica.png")))
), file.path(entry_dir, "output", "run-summary.txt"))
cat("Wrote", file.path(entry_dir, "output", "replica.png"), "\n")
