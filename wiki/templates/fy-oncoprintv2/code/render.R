# Portable FigureYa native template renderer.
# Usage: Rscript code/render.R --data <dir> --out <dir> [--style <json>]
args <- commandArgs(trailingOnly = TRUE)
get_arg <- function(name, default = NULL) {
  i <- match(name, args)
  if (is.na(i) || i >= length(args)) default else args[i + 1]
}
script_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script_path <- sub("^--file=", "", script_arg[1])
root <- dirname(dirname(normalizePath(script_path)))
data_dir <- get_arg("--data")
out_dir <- get_arg("--out")
if (is.null(data_dir) || is.null(out_dir)) {
  stop("Usage: Rscript code/render.R --data <dir> --out <dir> [--style <json>]")
}
if (!dir.exists(data_dir)) stop("Data directory not found: ", data_dir)

spec <- jsonlite::fromJSON(file.path(root, "spec.json"), simplifyVector = FALSE)
style <- if (is.null(spec$style)) list() else spec$style
style_file <- get_arg("--style")
if (!is.null(style_file) && file.exists(style_file)) {
  override <- jsonlite::fromJSON(style_file, simplifyVector = FALSE)
  for (key in names(override)) {
    style[[key]] <- override[[key]]
  }
}

dpi <- if (is.null(style$dpi)) 200 else as.numeric(style$dpi)
w_in <- if (is.null(style$width_in)) 8 else as.numeric(style$width_in)
h_in <- if (is.null(style$height_in)) 6 else as.numeric(style$height_in)
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
out_dir_abs <- normalizePath(out_dir, mustWork = FALSE)

wd <- tempfile("rwiki_fy_")
dir.create(wd, recursive = TRUE, showWarnings = FALSE)
on.exit(unlink(wd, recursive = TRUE, force = TRUE), add = TRUE)

code_dir <- file.path(root, "code")
for (f in list.files(code_dir, full.names = TRUE)) {
  bn <- basename(f)
  if (bn %in% c("render.R", "plot_figureya.R")) next
  if (dir.exists(f)) {
    file.copy(f, wd, recursive = TRUE)
  } else {
    file.copy(f, file.path(wd, bn), overwrite = TRUE)
  }
}

for (f in list.files(data_dir, full.names = TRUE)) {
  if (file.exists(f) && !dir.exists(f)) {
    file.copy(f, file.path(wd, basename(f)), overwrite = TRUE)
  }
}

before_pdfs <- list.files(wd, pattern = "\\.pdf$", ignore.case = TRUE, recursive = TRUE, full.names = TRUE)
before_info <- if (length(before_pdfs)) file.info(before_pdfs)$mtime else as.POSIXct(character(0))

fallback_pdf <- file.path(wd, "__rwiki_fallback__.pdf")
run_env <- new.env(parent = globalenv())
run_env$rwiki_style <- style
run_env$rwiki_title <- if (is.null(style$title)) "" else as.character(style$title)
run_env$rwiki_palette <- if (is.null(style$palette)) "NPG" else as.character(style$palette)
run_env$rwiki_width_in <- w_in
run_env$rwiki_height_in <- h_in

old_wd <- getwd()
setwd(wd)
on.exit(setwd(old_wd), add = TRUE)

grDevices::cairo_pdf(fallback_pdf, width = w_in, height = h_in, bg = "white")
fallback_dev <- grDevices::dev.cur()
script_err <- NULL
tryCatch({
  source(file.path(code_dir, "plot_figureya.R"), local = run_env, chdir = FALSE, print.eval = TRUE)
}, error = function(e) {
  script_err <<- e
})
while (grDevices::dev.cur() > 1L) {
  try(grDevices::dev.off(), silent = TRUE)
}
setwd(old_wd)
if (!is.null(script_err)) stop(script_err)

after_pdfs <- list.files(wd, pattern = "\\.pdf$", ignore.case = TRUE, recursive = TRUE, full.names = TRUE)
generated_pdfs <- setdiff(after_pdfs, c(before_pdfs, normalizePath(fallback_pdf, mustWork = FALSE)))
generated_pdfs <- generated_pdfs[!grepl("(^|[\\/])(__rwiki_fallback__|Rplots)\\.pdf$", generated_pdfs, ignore.case = TRUE)]
generated_pdfs <- generated_pdfs[file.exists(generated_pdfs) & file.info(generated_pdfs)$size > 512]

chosen_pdf <- NULL
if (length(generated_pdfs) > 0) {
  sizes <- file.info(generated_pdfs)$size
  chosen_pdf <- generated_pdfs[which.max(sizes)]
} else if (file.exists(fallback_pdf) && file.info(fallback_pdf)$size > 512) {
  pages <- tryCatch(pdftools::pdf_length(fallback_pdf), error = function(e) 0L)
  if (pages > 0L) chosen_pdf <- fallback_pdf
}
if (is.null(chosen_pdf)) {
  stop("FigureYa script did not produce a non-empty PDF output")
}

target_pdf <- file.path(out_dir_abs, "figure.pdf")
target_png <- file.path(out_dir_abs, "figure.png")
target_svg <- file.path(out_dir_abs, "figure.svg")
file.copy(chosen_pdf, target_pdf, overwrite = TRUE)

psize <- tryCatch(pdftools::pdf_pagesize(target_pdf)[1, ], error = function(e) list(width = w_in * 72, height = h_in * 72))
pw_in <- max(2, min(24, as.numeric(psize$width) / 72))
ph_in <- max(2, min(24, as.numeric(psize$height) / 72))

bmp <- pdftools::pdf_convert(target_pdf, format = "png", pages = 1, dpi = dpi, filenames = target_png, verbose = FALSE)
img <- png::readPNG(target_png)

if (requireNamespace("svglite", quietly = TRUE)) {
  svglite::svglite(target_svg, width = pw_in, height = ph_in, bg = "white")
  svg_dev <- "svglite"
} else {
  grDevices::svg(target_svg, width = pw_in, height = ph_in, bg = "white")
  svg_dev <- "grDevices::svg"
}
grid::grid.newpage()
grid::grid.raster(img, width = grid::unit(1, "npc"), height = grid::unit(1, "npc"))
grDevices::dev.off()

sizing <- list(width_in = round(pw_in, 2), height_in = round(ph_in, 2), dpi = dpi, svg_device = svg_dev)
jsonlite::write_json(sizing, file.path(out_dir_abs, "sizing.json"), auto_unbox = TRUE, pretty = TRUE)
cat("Wrote", target_png, "from", basename(chosen_pdf), "\n")
