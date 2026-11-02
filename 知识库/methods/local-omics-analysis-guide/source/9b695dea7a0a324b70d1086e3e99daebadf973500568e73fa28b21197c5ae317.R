required_pkgs <- function(pkgs) {
  missing <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing) > 0) {
    stop(
      paste0(
        "Missing required packages: ",
        paste(missing, collapse = ", "),
        "\nPlease install manually, e.g.: install.packages(c('",
        paste(missing, collapse = "','"),
        "')) or use renv."
      ),
      call. = FALSE
    )
  }
}

find_project_root <- function(start = getwd()) {
  start <- normalizePath(start, winslash = "/", mustWork = FALSE)
  cur <- start
  repeat {
    has_cfg <- file.exists(file.path(cur, "config.yml"))
    has_scripts <- dir.exists(file.path(cur, "scripts"))
    if (has_cfg && has_scripts) {
      return(cur)
    }
    parent <- dirname(cur)
    if (identical(parent, cur)) break
    cur <- parent
  }
  env_root <- Sys.getenv("UC20_BASE_DIR", unset = "")
  if (nzchar(env_root)) {
    return(normalizePath(env_root, winslash = "/", mustWork = FALSE))
  }
  stop("Cannot infer project root. Set UC20_BASE_DIR or run under project tree.", call. = FALSE)
}

load_config <- function(config_path = NULL) {
  required_pkgs(c("yaml"))
  root <- if (is.null(config_path)) find_project_root() else dirname(config_path)
  cfg_file <- if (is.null(config_path)) file.path(root, "config.yml") else config_path
  if (!file.exists(cfg_file)) stop("config.yml not found: ", cfg_file, call. = FALSE)
  cfg <- yaml::read_yaml(cfg_file)

  override <- Sys.getenv("UC20_BASE_DIR", unset = "")
  base_dir <- cfg$base_dir
  if (nzchar(override)) {
    base_dir <- override
  } else if (is.null(base_dir) || identical(base_dir, "") || is.na(base_dir)) {
    # Prefer the directory that contains config.yml (portable + deterministic).
    base_dir <- root
  }
  cfg$base_dir <- normalizePath(base_dir, winslash = "/", mustWork = FALSE)

  rel_to_abs <- function(p) {
    if (is.null(p) || identical(p, "")) return(p)
    if (grepl("^[A-Za-z]:[/\\\\]|^/", p)) {
      normalizePath(p, winslash = "/", mustWork = FALSE)
    } else {
      normalizePath(file.path(cfg$base_dir, p), winslash = "/", mustWork = FALSE)
    }
  }

  cfg$input_rds$B8 <- rel_to_abs(cfg$input_rds$B8)
  cfg$input_rds$B9 <- rel_to_abs(cfg$input_rds$B9)
  cfg$input_rds$RCTD_list <- rel_to_abs(cfg$input_rds$RCTD_list)
  cfg$input_rds$ptm_gene_sets <- rel_to_abs(cfg$input_rds$ptm_gene_sets)

  cfg$output_dir$results <- rel_to_abs(cfg$output_dir$results)
  if (!is.null(cfg$output_dir$panel_outputs)) cfg$output_dir$panel_outputs <- rel_to_abs(cfg$output_dir$panel_outputs)
  cfg$output_dir$paper_figures <- rel_to_abs(cfg$output_dir$paper_figures)
  cfg$output_dir$supp_figures <- rel_to_abs(cfg$output_dir$supp_figures)
  cfg$output_dir$logs <- rel_to_abs(cfg$output_dir$logs)
  cfg$output_dir$report <- rel_to_abs(cfg$output_dir$report)
  if (!is.null(cfg$output_dir$organized_results)) cfg$output_dir$organized_results <- rel_to_abs(cfg$output_dir$organized_results)

  cfg
}

ensure_output_dirs <- function(cfg) {
  for (d in unlist(cfg$output_dir, use.names = FALSE)) {
    dir.create(d, recursive = TRUE, showWarnings = FALSE)
  }
}

get_expr_matrix <- function(sobj, assay = NULL, prefer = "data") {
  if (is.null(assay)) {
    assay <- if ("Spatial" %in% Seurat::Assays(sobj)) "Spatial" else Seurat::DefaultAssay(sobj)
  }
  mat <- tryCatch(
    suppressWarnings(Seurat::GetAssayData(sobj, assay = assay, layer = prefer)),
    error = function(e) NULL
  )
  if (is.null(mat) || nrow(mat) == 0 || ncol(mat) == 0) {
    mat <- tryCatch(
      suppressWarnings(Seurat::GetAssayData(sobj, assay = assay, slot = prefer)),
      error = function(e) NULL
    )
  }
  if (is.null(mat) || nrow(mat) == 0 || ncol(mat) == 0) {
    mat <- tryCatch(
      suppressWarnings(Seurat::GetAssayData(sobj, assay = assay, layer = "counts")),
      error = function(e) suppressWarnings(Seurat::GetAssayData(sobj, assay = assay, slot = "counts"))
    )
    mat <- log1p(mat)
  }
  mat
}

get_spatial_xy <- function(sobj) {
  coords <- as.data.frame(Seurat::GetTissueCoordinates(sobj))
  cand <- list(
    c("imagerow", "imagecol"),
    c("row", "col")
  )
  for (nm in cand) {
    if (all(nm %in% colnames(coords))) {
      xy <- coords[, nm, drop = FALSE]
      colnames(xy) <- c("x", "y")
      rownames(xy) <- rownames(coords)
      return(xy)
    }
  }
  num_cols <- names(coords)[vapply(coords, is.numeric, logical(1))]
  if (length(num_cols) < 2) {
    stop("No valid 2D spatial coordinates found (need imagerow/imagecol or row/col).", call. = FALSE)
  }
  xy <- coords[, num_cols[1:2], drop = FALSE]
  colnames(xy) <- c("x", "y")
  rownames(xy) <- rownames(coords)
  xy
}

align_meta_to_expr <- function(sobj, expr_mat) {
  spots <- colnames(expr_mat)
  md <- sobj@meta.data
  if (!all(spots %in% rownames(md))) {
    missing <- sum(!spots %in% rownames(md))
    stop("Metadata alignment failure: ", missing, " spots missing in meta.data.", call. = FALSE)
  }
  md[spots, , drop = FALSE]
}

safe_md5 <- function(path) {
  if (!file.exists(path)) return(NA_character_)
  as.character(tools::md5sum(path))
}

start_phase_log <- function(cfg, phase_id, input_files = character(0), extra = list()) {
  ensure_output_dirs(cfg)
  log_file <- file.path(cfg$output_dir$logs, paste0(phase_id, ".log"))
  seed <- as.integer(cfg$seeds$global)
  set.seed(seed)

  lines <- c(
    paste0("phase=", phase_id),
    paste0("timestamp=", format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")),
    paste0("seed=", seed),
    paste0("R.version=", R.version.string),
    paste0("Seurat.version=", as.character(utils::packageVersion("Seurat")))
  )

  if (length(input_files) > 0) {
    lines <- c(lines, "input_md5:")
    for (p in input_files) {
      lines <- c(lines, paste0("- ", p, "\t", safe_md5(p)))
    }
  }
  if (length(extra) > 0) {
    lines <- c(lines, "extra:")
    for (nm in names(extra)) {
      lines <- c(lines, paste0("- ", nm, "=", as.character(extra[[nm]])))
    }
  }

  writeLines(lines, con = log_file)
  capture.output(sessionInfo(), file = log_file, append = TRUE)
  log_file
}

write_csv_safe <- function(df, path) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  utils::write.csv(df, path, row.names = FALSE)
}

renv_hint <- function(cfg) {
  out <- file.path(cfg$output_dir$report, "renv_setup.md")
  txt <- c(
    "# Reproducibility Environment Setup",
    "",
    "Use renv to lock dependency versions:",
    "",
    "```r",
    "install.packages('renv')",
    "renv::init()",
    "# run scripts",
    "renv::snapshot()",
    "```",
    "",
    "No script in this project performs automatic package installation."
  )
  writeLines(txt, out)
  out
}
