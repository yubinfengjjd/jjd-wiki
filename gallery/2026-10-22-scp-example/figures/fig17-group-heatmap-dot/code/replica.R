# Gallery entry driver: reproduces source/fig17.png from the archived long
# table with the module code in this directory. Run:
#   Rscript code/replica.R
entry_dir <- dirname(normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)[1])))
root <- dirname(entry_dir)
source(file.path(entry_dir, "core.R"))

# Identity columns explicitly character (digit-like labels like "001"
# survive); numeric cells stay numeric; literal "NA" in an identity column
# stays the string "NA", empty identity cells -> "" (rejected downstream).
key_col_classes <- c(matrix = "character", feature = "character",
                     group = "character")
df <- utils::read.csv(file.path(root, "data", "render-group-heatmap.csv"),
                      stringsAsFactors = FALSE, check.names = FALSE,
                      na.strings = character(0), colClasses = key_col_classes)
tables <- list(heatmap = df)
style <- list(add_dot = TRUE)
set.seed(11)
p <- ghdot_plot_panel(tables, style)

dir.create(file.path(root, "output"), showWarnings = FALSE)
ggplot2::ggsave(file.path(root, "output", "replica.png"), p$plot,
                width = 8, height = 6, dpi = 150, bg = "white")
ggplot2::ggsave(file.path(root, "output", "replica.pdf"), p$plot,
                width = 8, height = 6, device = grDevices::cairo_pdf, bg = "white")
ggplot2::ggsave(file.path(root, "output", "replica.svg"), p$plot,
                width = 8, height = 6, device = svglite::svglite, bg = "white")
cat("wrote", file.path(root, "output"), "\n")
