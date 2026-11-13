# Compatibility loader for the native SCP GroupHeatmap add_dot core.
#
# Loads every module file into a PRIVATE environment and exposes ONLY the
# public entry functions in the caller's environment. Sourcing this file
# (source(), source(local=e), or nested inside another driver) therefore:
#   - leaks no helper/engine names into the caller or global env;
#   - never overwrites another module's exported entries;
#   - resolves module files relative to THIS file (deepest ofile), not to the
#     caller's working directory.
# Public entries assigned into the caller env:
#   ghdot_build_matrices(df, style)
#   ghdot_plot_panel(tables, style, scp)
#   plot_scp_group_heatmap_dot(matrices, percent, features, style, scp)
suppressPackageStartupMessages({
  library(ComplexHeatmap)
  library(circlize)
  library(patchwork)
  library(gtable)
  library(grid)
})
local({
  caller <- parent.env(environment())
  ofile <- NULL
  for (frame in rev(sys.frames())) {
    if (!is.null(frame$ofile)) {
      ofile <- frame$ofile
      break
    }
  }
  if (is.null(ofile)) {
    file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
    if (length(file_arg)) ofile <- sub("^--file=", "", file_arg[1])
  }
  core_dir <- if (!is.null(ofile) && nzchar(ofile)) {
    dirname(normalizePath(ofile, mustWork = TRUE))
  } else {
    normalizePath(getwd(), mustWork = TRUE)
  }
  mod <- new.env(parent = .GlobalEnv)
  mod$.GH_DOT_CODE_DIR <- core_dir
  for (name in c("scp_helpers.R", "scp_group_heatmap_dot_native.R", "panel.R")) {
    sys.source(file.path(core_dir, name), envir = mod)
  }
  for (export in c("ghdot_build_matrices", "ghdot_plot_panel",
                   "plot_scp_group_heatmap_dot")) {
    assign(export, get(export, envir = mod), envir = caller)
  }
})
