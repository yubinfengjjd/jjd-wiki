# Render the SCP v0.5.6 native ring panel from the saved proportion table.
# Run from this entry directory:
#   Rscript code/render.R
# SCP_LIB or SCP_LOCAL_ROOT may point at another local source copy.
file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
entry_dir <- if (length(file_arg)) dirname(dirname(normalizePath(sub("^--file=", "", file_arg[1])))) else normalizePath(getwd(), mustWork = TRUE)
scp_root <- Sys.getenv("SCP_LOCAL_ROOT", unset = "E:/research-wiki/知识库/methods/scp-local-source/code/SCP-local")
if (!file.exists(file.path(scp_root, "load_scp_local.R"))) {
  stop("SCP local source not found; set SCP_LOCAL_ROOT", call. = FALSE)
}
options(SCP.local.root = normalizePath(scp_root, mustWork = TRUE))
source(file.path(scp_root, "load_scp_local.R"))
source(file.path(entry_dir, "code", "scp_ring_native.R"))
tab <- read.csv(file.path(entry_dir, "data", "ring_phase_by_celltype.csv"),
                stringsAsFactors = FALSE, check.names = FALSE)
stopifnot(all(c("CellType", "Phase", "count", "proportion") %in% names(tab)))
stopifnot(all(abs(tapply(tab$proportion, tab$CellType, sum) - 1) < 1e-8))
p <- scp_ring_proportions(
  tab,
  group_col = "CellType", stat_col = "Phase", value_col = "proportion",
  stat_type = "percent",
  group_levels = c("Ductal", "Ngn3 low EP", "Ngn3 high EP", "Pre-endocrine", "Endocrine"),
  stat_levels = c("G1", "S", "G2M"),
  palette = "Paired", label = TRUE,
  scp = SCP_local
)
dir.create(file.path(entry_dir, "output"), showWarnings = FALSE)
ggsave(file.path(entry_dir, "output", "replica.png"), p,
       width = 8, height = 6, dpi = 150, bg = "white")
ggsave(file.path(entry_dir, "output", "replica.pdf"), p,
       width = 8, height = 6, device = grDevices::cairo_pdf, bg = "white")
if (requireNamespace("svglite", quietly = TRUE)) {
  ggsave(file.path(entry_dir, "output", "replica.svg"), p,
         width = 8, height = 6, device = svglite::svglite, bg = "white")
} else {
  grDevices::svg(file.path(entry_dir, "output", "replica.svg"), width = 8, height = 6)
  print(p); dev.off()
}
writeLines(capture.output(sessionInfo()), file.path(entry_dir, "output", "sessionInfo.txt"))
writeLines(c(
  paste("command:", paste(commandArgs(), collapse = " ")),
  paste("SCP local root:", scp_root),
  paste("source commit: b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0"),
  paste("input:", "data/ring_phase_by_celltype.csv"),
  paste("rows:", nrow(tab)),
  paste("groups:", paste(names(table(tab$CellType)), as.integer(table(tab$CellType)), collapse = "; ")),
  paste("output:", "output/replica.png"),
  paste("exit: 0")
), file.path(entry_dir, "output", "run-summary.txt"))
cat("OK\n")
