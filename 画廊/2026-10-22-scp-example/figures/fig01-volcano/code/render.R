# Render the SCP v0.5.6 native VolcanoPlot single panel from a saved DE table.
# Run from this entry directory:
#   Rscript code/render.R
# SCP_LOCAL_ROOT may point at another local SCP source copy.
file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
entry_dir <- if (length(file_arg)) dirname(dirname(normalizePath(sub("^--file=", "", file_arg[1])))) else normalizePath(getwd(), mustWork = TRUE)
scp_root <- Sys.getenv("SCP_LOCAL_ROOT", unset = "E:/research-wiki/知识库/methods/scp-local-source/code/SCP-local")
if (!file.exists(file.path(scp_root, "load_scp_local.R"))) {
  stop("SCP local source not found; set SCP_LOCAL_ROOT", call. = FALSE)
}
options(SCP.local.root = normalizePath(scp_root, mustWork = TRUE))
source(file.path(scp_root, "load_scp_local.R"))
source(file.path(entry_dir, "code", "scp_volcano_native.R"))

df <- read.csv(file.path(entry_dir, "data", "de_endocrine_vs_rest.csv"),
               stringsAsFactors = FALSE, check.names = FALSE)
tab <- scp_volcano_table(
  df,
  group.by = "group1",
  DE_threshold = "avg_log2FC > 0 & p_val_adj < 0.05",
  x_metric = "diff_pct"
)
set.seed(1) # upstream source layout; VolcanoPlot() itself does not seed
p <- plot_scp_volcano(
  tab,
  group.by = "group1",
  x_metric = "diff_pct",
  palette = "RdBu",
  pt.size = 1, pt.alpha = 1,
  cols.highlight = "black", sizes.highlight = 1,
  alpha.highlight = 1, stroke.highlight = 0.5,
  nlabel = 8, label.size = 4,
  aspect.ratio = NULL,
  xlab = "diff_pct", ylab = "-log10(p-adjust)",
  theme_use = "theme_scp",
  scp = SCP_local
)

dir.create(file.path(entry_dir, "output"), showWarnings = FALSE)
ggsave(file.path(entry_dir, "output", "replica.png"), p,
       width = 7, height = 6, dpi = 200, bg = "white")
ggsave(file.path(entry_dir, "output", "replica.pdf"), p,
       width = 7, height = 6, device = grDevices::cairo_pdf, bg = "white")
if (requireNamespace("svglite", quietly = TRUE)) {
  ggsave(file.path(entry_dir, "output", "replica.svg"), p,
         width = 7, height = 6, device = svglite::svglite, bg = "white")
} else {
  grDevices::svg(file.path(entry_dir, "output", "replica.svg"), width = 7, height = 6)
  print(p); dev.off()
}
writeLines(capture.output(sessionInfo()), file.path(entry_dir, "output", "sessionInfo.txt"))
writeLines(c(
  paste("command:", paste(commandArgs(), collapse = " ")),
  paste("SCP local root:", scp_root),
  paste("source commit: b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0"),
  paste("input:", "data/de_endocrine_vs_rest.csv"),
  paste("rows:", nrow(tab)),
  paste("DE:", sum(tab$DE), "border:", sum(tab$border)),
  paste("x range:", paste(signif(range(tab$x), 6), collapse = " .. ")),
  paste("y range:", paste(signif(range(tab$y), 6), collapse = " .. ")),
  paste("output:", "output/replica.png"),
  paste("exit: 0")
), file.path(entry_dir, "output", "run-summary.txt"))
cat("OK\n")
