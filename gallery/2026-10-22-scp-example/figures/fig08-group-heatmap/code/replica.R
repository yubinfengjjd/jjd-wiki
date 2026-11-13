# Standard gallery entry point; native core is in code/scp_group_heatmap_native.R.
entry_dir <- dirname(normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)[1])))
source(file.path(entry_dir, "render.R"))
