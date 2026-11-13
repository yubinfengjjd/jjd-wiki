# Standard gallery entry point; the native sankey core and renderer are
# in code/scp_sankey_native.R and code/render.R.
entry_dir <- dirname(normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)[1])))
source(file.path(entry_dir, "render.R"))
