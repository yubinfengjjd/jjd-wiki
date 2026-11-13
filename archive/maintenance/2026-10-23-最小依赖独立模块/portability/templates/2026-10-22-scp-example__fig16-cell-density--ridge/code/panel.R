# Panel adapter: one native SCP CellDensityPlot panel from a cell x feature
# table. Every visual parameter comes from spec.style.
get_style <- function(style, name, default) {
  value <- style[[name]]
  if (is.null(value)) default else value
}

plot_panel <- function(tables, style, scp = SCP_helpers) {
  if (!"density" %in% names(tables)) stop("Missing table: density")
  if (!exists("plot_scp_cell_density", mode = "function")) {
    stop("Native CellDensityPlot core not loaded; source code/core.R first", call. = FALSE)
  }
  plot_scp_cell_density(tables$density, style, scp = scp)
}

draw <- function(fig, rect, tables, style) {
  p <- plot_panel(tables, style)
  print(p)
  invisible(p)
}
