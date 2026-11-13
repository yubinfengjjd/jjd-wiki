args <- commandArgs(trailingOnly = TRUE)
root <- normalizePath(args[[1]])
style <- jsonlite::fromJSON(args[[2]], simplifyVector = TRUE)
values <- read.csv(args[[3]], check.names = FALSE)
source(file.path(root, 'code/core.R'))
source(file.path(root, 'code/panel.R'))
plot <- plot_panel(list(density = values), style)
build <- ggplot2::ggplot_build(plot)
layer <- build$data[[1]]
limits <- build$layout$panel_params[[1]]$y.range
cols <- intersect(c('y', 'ymin', 'ymax', 'height', 'iscale', 'scale'), colnames(layer))
report <- list(groups = length(unique(layer$group)), y_range = limits,
               computed_ranges = lapply(layer[cols], range, na.rm = TRUE),
               rendered_density_points = nrow(layer),
               all_input_rows = nrow(values),
               scope = 'Inspect plot transformation and possible clipping, not biological inference')
if (all(c('y', 'height', 'iscale', 'scale') %in% colnames(layer))) {
    peak <- as.numeric(layer$y) + layer$height * layer$iscale * layer$scale
    report$computed_ridge_top <- max(peak, na.rm = TRUE)
    report$above_panel <- sum(peak > max(limits), na.rm = TRUE)
}
cat(jsonlite::toJSON(report, auto_unbox = TRUE, pretty = TRUE), '\n')
