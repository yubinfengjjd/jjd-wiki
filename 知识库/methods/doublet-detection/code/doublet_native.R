# Minimal runtime module extracted verbatim from SCP-local 0.5.6 (GPL (>= 3)).
# Source: https://github.com/zhanghao-njmu/SCP commit b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0
# Roots: RunDoubletCalling, db_scDblFinder, db_scds, db_Scrublet, db_DoubletDetection
# Functions: db_scDblFinder, db_scds, db_Scrublet, db_DoubletDetection, RunDoubletCalling, check_DataType, PrepareEnv, Env_requirements, installed_Python_pkgs, exist_Python_pkgs, env_exist, get_envname, find_conda, conda_install, conda_python, run_Python, check_Python, check_R, as_matrix
# Function bodies are copied from the pinned source without algorithm changes.
# Automatic installation is disabled by the caller. Local resources are loaded only by the caller.

# ---- SCP-cellqc.R:17-31 : db_scDblFinder ----
db_scDblFinder <- function(srt, assay = "RNA", db_rate = ncol(srt) / 1000 * 0.01, ...) {
  if (!inherits(srt, "Seurat")) {
    stop("'srt' is not a Seurat object.")
  }
  status <- check_DataType(srt, slot = "counts", assay = assay)
  if (status != "raw_counts") {
    stop("Data type is not raw counts!")
  }
  check_R("scDblFinder")
  sce <- as.SingleCellExperiment(srt, assay = assay)
  sce <- scDblFinder::scDblFinder(sce, dbr = db_rate, verbose = FALSE, ...)
  srt[["db.scDblFinder_score"]] <- sce[["scDblFinder.score"]]
  srt[["db.scDblFinder_class"]] <- sce[["scDblFinder.class"]]
  return(srt)
}

# ---- SCP-cellqc.R:50-70 : db_scds ----
db_scds <- function(srt, assay = "RNA", db_rate = ncol(srt) / 1000 * 0.01, method = c("hybrid", "cxds", "bcds"), ...) {
  if (!inherits(srt, "Seurat")) {
    stop("'srt' is not a Seurat object.")
  }
  status <- check_DataType(srt, slot = "counts", assay = assay)
  if (status != "raw_counts") {
    stop("Data type is not raw counts!")
  }
  check_R("scds")
  method <- match.arg(method)
  sce <- as.SingleCellExperiment(srt, assay = assay)
  sce <- scds::cxds_bcds_hybrid(sce, ...)
  srt[["db.scds_cxds_score"]] <- sce[["cxds_score"]]
  srt[["db.scds_bcds_score"]] <- sce[["bcds_score"]]
  srt[["db.scds_hybrid_score"]] <- sce[["hybrid_score"]]
  ntop <- ceiling(db_rate * ncol(sce))
  db_qc <- names(sort(srt[[paste0("db.scds_", method, "_score"), drop = TRUE]], decreasing = TRUE)[1:ntop])
  srt[[paste0("db.scds_", method, "_class")]] <- "singlet"
  srt[[paste0("db.scds_", method, "_class")]][db_qc, ] <- "doublet"
  return(srt)
}

# ---- SCP-cellqc.R:89-113 : db_Scrublet ----
db_Scrublet <- function(srt, assay = "RNA", db_rate = ncol(srt) / 1000 * 0.01, ...) {
  if (!inherits(srt, "Seurat")) {
    stop("'srt' is not a Seurat object.")
  }
  status <- check_DataType(srt, slot = "counts", assay = assay)
  if (status != "raw_counts") {
    stop("Data type is not raw counts!")
  }
  check_Python("scrublet")
  scr <- import("scrublet")
  raw_counts <- t(as_matrix(GetAssayData(object = srt, assay = assay, slot = "counts")))
  scrub <- scr$Scrublet(raw_counts, expected_doublet_rate = db_rate, ...)
  res <- scrub$scrub_doublets()
  doublet_scores <- res[[1]]
  predicted_doublets <- res[[2]]

  srt[["db.Scrublet_score"]] <- doublet_scores
  srt[["db.Scrublet_class"]] <- sapply(predicted_doublets, function(i) {
    switch(as.character(i),
      "FALSE" = "singlet",
      "TRUE" = "doublet"
    )
  })
  return(srt)
}

# ---- SCP-cellqc.R:132-159 : db_DoubletDetection ----
db_DoubletDetection <- function(srt, assay = "RNA", db_rate = ncol(srt) / 1000 * 0.01, ...) {
  if (!inherits(srt, "Seurat")) {
    stop("'srt' is not a Seurat object.")
  }
  status <- check_DataType(srt, slot = "counts", assay = assay)
  if (status != "raw_counts") {
    stop("Data type is not raw counts!")
  }
  check_Python("doubletdetection")
  doubletdetection <- import("doubletdetection")
  counts <- GetAssayData(object = srt, assay = assay, slot = "counts")
  clf <- doubletdetection$BoostClassifier(
    n_iters = as.integer(5),
    standard_scaling = TRUE,
    ...
  )
  labels <- clf$fit(Matrix::t(counts))$predict()
  scores <- clf$doublet_score()

  srt[["db.DoubletDetection_score"]] <- scores
  srt[["db.DoubletDetection_class"]] <- sapply(labels, function(i) {
    switch(as.character(i),
      "0" = "singlet",
      "1" = "doublet"
    )
  })
  return(srt)
}

# ---- SCP-cellqc.R:180-215 : RunDoubletCalling ----
RunDoubletCalling <- function(srt, assay = "RNA", db_method = "scDblFinder", db_rate = ncol(srt) / 1000 * 0.01, ...) {
  if (!inherits(srt, "Seurat")) {
    stop("'srt' is not a Seurat object.")
  }
  status <- check_DataType(srt, slot = "counts", assay = assay)
  if (status != "raw_counts") {
    stop("Data type is not raw counts!")
  }
  if (db_method %in% c("scDblFinder", "Scrublet", "DoubletDetection", "scds_cxds", "scds_bcds", "scds_hybrid")) {
    methods <- unlist(strsplit(db_method, "_"))
    method1 <- methods[1]
    method2 <- methods[2]
    if (is.na(method2)) {
      args1 <- mget(names(formals()), sys.frame(sys.nframe()))
      args2 <- as.list(match.call())
    } else {
      args1 <- c(mget(names(formals()), sys.frame(sys.nframe())), method = method2)
      args2 <- c(as.list(match.call()), method = method2)
    }
    for (n in names(args2)) {
      args1[[n]] <- args2[[n]]
    }
    args1 <- args1[!names(args1) %in% c("db_method", "...")]
    tryCatch(expr = {
      srt <- do.call(
        what = paste0("db_", method1),
        args = args1
      )
    }, error = function(e) {
      message(e)
    })
    return(srt)
  } else {
    stop(paste(db_method, "is not a suppoted doublet-calling method!"))
  }
}

# ---- SCP-workflow.R:14-47 : check_DataType ----
check_DataType <- function(srt, data = NULL, slot = "data", assay = NULL) {
  if (is.null(data)) {
    assay <- assay %||% DefaultAssay(srt)
    data <- GetAssayData(srt, slot = slot, assay = assay)
  }
  isfinite <- all(is.finite(range(data, na.rm = TRUE)))
  if (inherits(data, "dgCMatrix")) {
    isfloat <- any(data@x %% 1 != 0, na.rm = TRUE)
  } else {
    isfloat <- any(data[, sample(seq_len(ncol(data)), min(ncol(data), 1000))] %% 1 != 0, na.rm = TRUE)
  }
  islog <- is.finite(expm1(x = max(data, na.rm = TRUE)))
  isnegative <- any(data < 0)

  if (!isTRUE(isfinite)) {
    warning("Infinite values detected!", immediate. = TRUE)
    return("unknown")
  } else if (isTRUE(isnegative)) {
    warning("Negative values detected!", immediate. = TRUE)
    return("unknown")
  } else {
    if (!isfloat) {
      return("raw_counts")
    } else if (isfloat && islog) {
      return("log_normalized_counts")
    } else if (isfloat && !islog) {
      if (isFALSE(isnegative)) {
        return("raw_normalized_counts")
      } else {
        return("unknown")
      }
    }
  }
}

# ---- utils.R:13-129 : PrepareEnv ----
PrepareEnv <- function(conda = "auto", miniconda_repo = "https://repo.anaconda.com/miniconda",
                       envname = NULL, version = "3.8-1", force = FALSE, ...) {
  envname <- get_envname(envname)

  requirements <- Env_requirements(version = version)
  python_version <- requirements[["python"]]
  packages <- requirements[["packages"]]

  if (!is.null(conda)) {
    if (identical(conda, "auto")) {
      conda <- find_conda()
    } else {
      options(reticulate.conda_binary = conda)
      conda <- find_conda()
    }
  }

  if (is.null(conda)) {
    env <- FALSE
  } else {
    envs_dir <- reticulate:::conda_info(conda = conda)$envs_dirs[1]
    env <- env_exist(conda = conda, envname = envname, envs_dir = envs_dir)
    if (isTRUE(force) && isTRUE(env)) {
      unlink(paste0(envs_dir, "/", envname), recursive = TRUE)
      env <- FALSE
    }
  }

  if (isTRUE(env)) {
    python_path <- conda_python(conda = conda, envname = envname)
    # installed_python_version <- reticulate:::python_version(python_path)
    # if (installed_python_version < numeric_version("3.7.0") || installed_python_version >= numeric_version("3.10.0")) {
    #   stop("The python version in the installed SCP environment does not match the requirements. You need to recreate the SCP environment.")
    # }
  } else {
    force <- TRUE
    if (is.null(conda)) {
      message("Conda not found. Installing miniconda...")
      options(timeout = 360)
      version <- "3"
      info <- as.list(Sys.info())
      if (info$sysname == "Darwin" && info$machine == "arm64") {
        base <- "https://github.com/conda-forge/miniforge/releases/latest/download"
        name <- "Miniforge3-MacOSX-arm64.sh"
        return(file.path(base, name))
      }
      base <- miniconda_repo
      info <- as.list(Sys.info())
      arch <- reticulate:::miniconda_installer_arch(info)
      version <- as.character(version)
      name <- if (reticulate:::is_windows()) {
        sprintf(
          "Miniconda%s-latest-Windows-%s.exe", version,
          arch
        )
      } else if (reticulate:::is_osx()) {
        sprintf(
          "Miniconda%s-latest-MacOSX-%s.sh", version,
          arch
        )
      } else if (reticulate:::is_linux()) {
        sprintf("Miniconda%s-latest-Linux-%s.sh", version, arch)
      } else {
        stopf("unsupported platform %s", shQuote(Sys.info()[["sysname"]]))
      }
      url <- file.path(base, name)
      options(reticulate.miniconda.url = url)
      if (!is.na(Sys.getenv("USER", unset = NA))) {
        miniconda_path <- gsub(pattern = "\\$USER", replacement = Sys.getenv("USER"), reticulate::miniconda_path())
      } else {
        miniconda_path <- reticulate::miniconda_path()
      }
      unlink(miniconda_path, recursive = TRUE)
      reticulate::install_miniconda(path = miniconda_path, force = TRUE, update = FALSE)
      conda <- reticulate:::miniconda_conda(miniconda_path)
      envs_dir <- reticulate:::conda_info(conda = conda)$envs_dirs[1]
    }
    if (python_version < numeric_version("3.7.0") || python_version >= numeric_version("3.10.0")) {
      stop("SCP currently only support python version 3.7-3.9!")
    }
    python_path <- reticulate::conda_create(conda = conda, envname = envname, python_version = python_version, packages = "pytables")
    env_path <- paste0(envs_dir, "/", envname)
    env <- file.exists(env_path)
    if (isFALSE(env)) {
      print(reticulate:::conda_info(conda = conda))
      print(reticulate::conda_list(conda = conda))
      stop(
        "Unable to find SCP environment under the expected path: ", env_path, "\n",
        "conda: ", conda, "\n",
        "SCP python: ", python_path, "\n"
      )
    }
  }

  check_Python(packages = packages, envname = envname, conda = conda, force = force, ...)

  Sys.unsetenv("RETICULATE_PYTHON")
  python_path <- conda_python(conda = conda, envname = envname)
  reticulate::use_python(python_path, required = TRUE)

  pyinfo <- utils::capture.output(reticulate::py_config())
  pyinfo_mesg <- c(
    "====================== SCP conda environment ======================",
    paste0("conda: ", conda),
    paste0("environment: ", paste0(envs_dir, "/", get_envname())),
    "======================== SCP python config ========================",
    pyinfo,
    "==================================================================="
  )
  invisible(lapply(pyinfo_mesg, packageStartupMessage))
  invisible(run_Python(command = "import matplotlib", envir = .GlobalEnv))
  if (!interactive()) {
    invisible(run_Python(command = "matplotlib.use('pdf')", envir = .GlobalEnv))
  }
  invisible(run_Python(command = "import matplotlib.pyplot as plt", envir = .GlobalEnv))
  invisible(run_Python(command = "import scanpy", envir = .GlobalEnv))
}

# ---- utils.R:144-265 : Env_requirements ----
Env_requirements <- function(version = "3.8-1") {
  version <- match.arg(version, choices = c("3.8-1", "3.8-2", "3.9-1", "3.10-1", "3.11-1"))
  requirements <- switch(version,
    "3.8-1" = list(
      python = "3.8",
      packages = c(
        "leidenalg" = "leidenalg==0.10.1",
        "matplotlib" = "matplotlib==3.6.3",
        "numba" = "numba==0.55.2",
        "numpy" = "numpy==1.21.6",
        "palantir" = "palantir==1.0.1",
        "pandas" = "pandas==1.3.5",
        "python-igraph" = "python-igraph==0.10.2",
        "scanpy" = "scanpy==1.9.5",
        "scikit-learn" = "scikit-learn==1.3.2",
        "scipy" = "scipy==1.10.1",
        "scvelo" = "scvelo==0.2.5",
        "wot" = "wot==1.0.8.post2",
        "trimap" = "trimap==1.1.4",
        "pacmap" = "pacmap==0.7.0",
        "phate" = "phate==1.0.11",
        "bbknn" = "bbknn==1.6.0",
        "scanorama" = "scanorama==1.7.4",
        "scvi-tools" = "scvi-tools==0.20.3"
      )
    ),
    "3.8-2" = list(
      python = "3.8",
      packages = c(
        "leidenalg" = "leidenalg==0.10.1",
        "matplotlib" = "matplotlib==3.7.3",
        "numba" = "numba==0.58.1",
        "numpy" = "numpy==1.24.4",
        "palantir" = "palantir==1.3.0",
        "pandas" = "pandas==1.5.3",
        "python-igraph" = "python-igraph==0.10.8",
        "scanpy" = "scanpy==1.9.5",
        "scikit-learn" = "scikit-learn==1.3.2",
        "scipy" = "scipy==1.10.1",
        "scvelo" = "scvelo==0.2.5",
        "wot" = "wot==1.0.8.post2",
        "trimap" = "trimap==1.1.4",
        "pacmap" = "pacmap==0.7.0",
        "phate" = "phate==1.0.11",
        "bbknn" = "bbknn==1.6.0",
        "scanorama" = "scanorama==1.7.4",
        "scvi-tools" = "scvi-tools==0.20.3"
      )
    ),
    "3.9-1" = list(
      python = "3.9",
      packages = c(
        "leidenalg" = "leidenalg==0.10.1",
        "matplotlib" = "matplotlib==3.8.0",
        "numba" = "numba==0.58.1",
        "numpy" = "numpy==1.25.2",
        "palantir" = "palantir==1.3.0",
        "pandas" = "pandas==1.5.3",
        "python-igraph" = "python-igraph==0.10.8",
        "scanpy" = "scanpy==1.9.5",
        "scikit-learn" = "scikit-learn==1.3.2",
        "scipy" = "scipy==1.11.3",
        "scvelo" = "scvelo==0.2.5",
        "wot" = "wot==1.0.8.post2",
        "trimap" = "trimap==1.1.4",
        "pacmap" = "pacmap==0.7.0",
        "phate" = "phate==1.0.11",
        "bbknn" = "bbknn==1.6.0",
        "scanorama" = "scanorama==1.7.4",
        "scvi-tools" = "scvi-tools==0.20.3"
      )
    ),
    "3.10-1" = list(
      python = "3.10",
      packages = c(
        "leidenalg" = "leidenalg==0.10.1",
        "matplotlib" = "matplotlib==3.8.0",
        "numba" = "numba==0.58.1",
        "numpy" = "numpy==1.25.2",
        "palantir" = "palantir==1.3.0",
        "pandas" = "pandas==1.5.3",
        "python-igraph" = "python-igraph==0.10.8",
        "scanpy" = "scanpy==1.9.5",
        "scikit-learn" = "scikit-learn==1.3.2",
        "scipy" = "scipy==1.11.3",
        "scvelo" = "scvelo==0.2.5",
        "wot" = "wot==1.0.8.post2",
        "trimap" = "trimap==1.1.4",
        "pacmap" = "pacmap==0.7.0",
        "phate" = "phate==1.0.11",
        "bbknn" = "bbknn==1.6.0",
        "scanorama" = "scanorama==1.7.4",
        "scvi-tools" = "scvi-tools==0.20.3"
      )
    ),
    "3.11-1" = list(
      python = "3.10",
      packages = c(
        "leidenalg" = "leidenalg==0.10.1",
        "matplotlib" = "matplotlib==3.8.0",
        "numba" = "numba==0.58.1",
        "numpy" = "numpy==1.25.2",
        "palantir" = "palantir==1.3.0",
        "pandas" = "pandas==1.5.3",
        "python-igraph" = "python-igraph==0.10.8",
        "scanpy" = "scanpy==1.9.5",
        "scikit-learn" = "scikit-learn==1.3.2",
        "scipy" = "scipy==1.11.3",
        "scvelo" = "scvelo==0.2.5",
        "wot" = "wot==1.0.8.post2",
        "trimap" = "trimap==1.1.4",
        "pacmap" = "pacmap==0.7.0",
        "phate" = "phate==1.0.11",
        "bbknn" = "bbknn==1.6.0",
        "scanorama" = "scanorama==1.7.4",
        "scvi-tools" = "scvi-tools==0.20.3"
      )
    )
  )

  return(requirements)
}

# ---- utils.R:271-285 : installed_Python_pkgs ----
installed_Python_pkgs <- function(envname = NULL, conda = "auto") {
  envname <- get_envname(envname)
  if (identical(conda, "auto")) {
    conda <- find_conda()
  } else {
    options(reticulate.conda_binary = conda)
    conda <- find_conda()
  }
  env <- env_exist(conda = conda, envname = envname)
  if (isFALSE(env)) {
    stop("Can not find the conda environment: ", envname)
  }
  all_installed <- reticulate:::conda_list_packages(conda = conda, envname = envname, no_pip = FALSE)
  return(all_installed)
}

# ---- utils.R:291-330 : exist_Python_pkgs ----
exist_Python_pkgs <- function(packages, envname = NULL, conda = "auto") {
  envname <- get_envname(envname)
  if (identical(conda, "auto")) {
    conda <- find_conda()
  } else {
    options(reticulate.conda_binary = conda)
    conda <- find_conda()
  }
  env <- env_exist(conda = conda, envname = envname)
  if (isFALSE(env)) {
    stop("Can not find the conda environment: ", envname)
  }
  all_installed <- installed_Python_pkgs(envname = envname, conda = conda)
  packages_installed <- NULL
  for (i in seq_along(packages)) {
    pkg <- packages[i]
    if (grepl("==", pkg)) {
      pkg_info <- strsplit(pkg, split = "==")[[1]]
      pkg_name <- names(pkg) %||% pkg_info[1]
      pkg_version <- pkg_info[2]
    } else if (grepl("git+", pkg)) {
      pkg_info <- strsplit(pkg, "/")[[1]]
      pkg_name <- names(pkg) %||% pkg_info[length(pkg_info)]
      pkg_version <- NA
    } else {
      pkg_name <- names(pkg) %||% pkg
      pkg_version <- NA
    }
    if (pkg_name %in% all_installed$package) {
      if (!is.na(pkg_version)) {
        packages_installed[pkg] <- all_installed$version[all_installed$package == pkg_name] == pkg_version
      } else {
        packages_installed[pkg] <- TRUE
      }
    } else {
      packages_installed[pkg] <- FALSE
    }
  }
  return(packages_installed)
}

# ---- utils.R:336-353 : env_exist ----
env_exist <- function(conda = "auto", envname = NULL, envs_dir = NULL) {
  envname <- get_envname(envname)
  if (identical(conda, "auto")) {
    conda <- find_conda()
  } else {
    options(reticulate.conda_binary = conda)
    conda <- find_conda()
  }
  if (!is.null(conda)) {
    if (is.null(envs_dir)) {
      envs_dir <- reticulate:::conda_info(conda = conda)$envs_dirs[1]
    }
    exist <- file.exists(paste0(envs_dir, "/", envname))
  } else {
    exist <- FALSE
  }
  return(exist)
}

# ---- utils.R:355-362 : get_envname ----
get_envname <- function(envname = NULL) {
  if (is.character(envname)) {
    envname <- envname
  } else {
    envname <- getOption("SCP_env_name", default = "SCP_env")
  }
  return(envname)
}

# ---- utils.R:367-384 : find_conda ----
find_conda <- function() {
  conda <- tryCatch(reticulate::conda_binary(conda = "auto"), error = identity)
  conda_exist <- !inherits(conda, "error")
  if (isFALSE(conda_exist)) {
    if (!is.na(Sys.getenv("USER", unset = NA))) {
      miniconda_path <- gsub(pattern = "\\$USER", replacement = Sys.getenv("USER"), reticulate::miniconda_path())
    } else {
      miniconda_path <- reticulate::miniconda_path()
    }
    conda_exist <- reticulate:::miniconda_exists(miniconda_path) && reticulate:::miniconda_test(miniconda_path)
    if (isTRUE(conda_exist)) {
      conda <- reticulate:::miniconda_conda(miniconda_path)
    } else {
      conda <- NULL
    }
  }
  return(conda)
}

# ---- utils.R:389-453 : conda_install ----
conda_install <- function(envname = NULL, packages, forge = TRUE, channel = character(),
                          pip = FALSE, pip_options = character(), pip_ignore_installed = FALSE,
                          conda = "auto", python_version = NULL, ...) {
  envname <- get_envname(envname)
  reticulate:::check_forbidden_install("Python packages")
  if (missing(packages)) {
    if (!is.null(envname)) {
      fmt <- paste("argument \"packages\" is missing, with no default",
        "- did you mean 'conda_install(<envname>, %1$s)'?",
        "- use 'py_install(%1$s)' to install into the active Python environment",
        sep = "\n"
      )
      stopf(fmt, deparse1(substitute(envname)), call. = FALSE)
    } else {
      packages
    }
  }
  conda <- reticulate::conda_binary(conda)
  envname <- reticulate:::condaenv_resolve(envname)
  python_package <- if (is.null(python_version)) {
    NULL
  } else if (grepl("[><=]", python_version)) {
    paste0("python", python_version)
  } else {
    sprintf("python=%s", python_version)
  }
  python <- tryCatch(conda_python(envname = envname, conda = conda), error = identity)
  if (inherits(python, "error") || !file.exists(python)) {
    reticulate::conda_create(envname = envname, packages = python_package %||% "python", forge = forge, channel = channel, conda = conda)
    python <- conda_python(envname = envname, conda = conda)
  }
  if (!is.null(python_version)) {
    args <- reticulate:::conda_args("install", envname, python_package)
    status <- reticulate:::system2t(conda, shQuote(args))
    if (status != 0L) {
      fmt <- "installation of '%s' into environment '%s' failed [error code %i]"
      msg <- sprintf(fmt, python_package, envname, status)
      stop(msg, call. = FALSE)
    }
  }
  if (pip) {
    # target_dir <- system2(command = python, args = c("-c \"import site; print(site.getsitepackages()[0])\""), stdout = TRUE)
    # pip_options <- c(pip_options, paste("--target", target_dir))
    result <- reticulate:::pip_install(
      python = python, packages = packages,
      pip_options = pip_options, ignore_installed = pip_ignore_installed,
      conda = conda, envname = envname
    )
    return(result)
  }
  args <- reticulate:::conda_args("install", envname)
  channels <- if (length(channel)) {
    channel
  } else if (forge) {
    "conda-forge"
  }
  for (ch in channels) args <- c(args, "-c", ch)
  args <- c(args, python_package, packages)
  result <- reticulate:::system2t(conda, shQuote(args))
  if (result != 0L) {
    fmt <- "one or more Python packages failed to install [error code %i]"
    stopf(fmt, result)
  }
  invisible(packages)
}

# ---- utils.R:458-478 : conda_python ----
conda_python <- function(envname = NULL, conda = "auto", all = FALSE) {
  envname <- get_envname(envname)
  envname <- reticulate:::condaenv_resolve(envname)
  if (grepl("[/\\\\]", envname)) {
    suffix <- if (reticulate:::is_windows()) "python.exe" else "bin/python"
    path <- file.path(envname, suffix)
    if (file.exists(path)) {
      return(path)
    }
    fmt <- "no conda environment exists at path '%s'"
    stop(sprintf(fmt, envname))
  }
  conda_envs <- reticulate::conda_list(conda = conda)
  conda_envs <- conda_envs[grep(normalizePath(reticulate:::conda_info(conda = conda)$envs_dirs[1], mustWork = FALSE), x = normalizePath(conda_envs$python, mustWork = FALSE), fixed = TRUE), , drop = FALSE]
  env <- conda_envs[conda_envs$name == envname, , drop = FALSE]
  if (nrow(env) == 0) {
    stop("conda environment \"", envname, "\" not found")
  }
  python <- if (all) env$python else env$python[[1L]]
  return(normalizePath(as.character(python), mustWork = FALSE))
}

# ---- utils.R:480-492 : run_Python ----
run_Python <- function(command, envir = .GlobalEnv) {
  tryCatch(expr = {
    eval(
      {
        reticulate::py_run_string(command)
      },
      envir = envir
    )
  }, error = function(error) {
    message(error)
    stop("Failed to run \"", command, "\". Please check manually.")
  })
}

# ---- utils.R:510-546 : check_Python ----
check_Python <- function(packages, envname = NULL, conda = "auto", force = FALSE, pip = TRUE, pip_options = character(), ...) {
  envname <- get_envname(envname)
  if (identical(conda, "auto")) {
    conda <- find_conda()
  } else {
    options(reticulate.conda_binary = conda)
    conda <- find_conda()
  }
  env <- env_exist(conda = conda, envname = envname)
  if (isFALSE(env)) {
    warning(envname, " python environment does not exist. Create it with the PrepareEnv function...", immediate. = TRUE)
    PrepareEnv()
  }
  if (isTRUE(force)) {
    pkg_installed <- setNames(rep(FALSE, length(packages)), packages)
    pip_options <- c(pip_options, "--force-reinstall")
  } else {
    pkg_installed <- exist_Python_pkgs(packages = packages, envname = envname, conda = conda)
  }
  if (sum(!pkg_installed) > 0) {
    pkgs_to_install <- names(pkg_installed)[!pkg_installed]
    message("Try to install ", paste0(pkgs_to_install, collapse = ","), " ...")
    if (isTRUE(pip)) {
      pkgs_to_install <- c("pip", pkgs_to_install)
    }
    tryCatch(expr = {
      conda_install(conda = conda, packages = pkgs_to_install, envname = envname, pip = pip, pip_options = pip_options, ...)
    }, error = identity)
  }

  pkg_installed <- exist_Python_pkgs(packages = packages, envname = envname, conda = conda)
  if (sum(!pkg_installed) > 0) {
    stop("Failed to install the package(s): ", paste0(names(pkg_installed)[!pkg_installed], collapse = ","), " into the environment \"", envname, "\". Please install manually.")
  } else {
    return(invisible(NULL))
  }
}

# ---- utils.R:558-617 : check_R ----
check_R <- function(packages, install_methods = c("BiocManager::install", "install.packages", "devtools::install_github"), lib = .libPaths()[1], force = FALSE) {
  status_list <- list()
  for (pkg in packages) {
    version <- NULL
    if (grepl("/", pkg)) {
      # github package
      pkg_name <- strsplit(pkg, split = "/|@|==", perl = TRUE)[[1]][[2]]
    } else {
      pkg_name <- strsplit(pkg, split = "@|==", perl = TRUE)[[1]][[1]]
      if (length(strsplit(pkg, split = "@|==", perl = TRUE)[[1]]) > 1) {
        version <- strsplit(pkg, split = "@|==", perl = TRUE)[[1]][[2]]
      }
    }
    dest <- gsub("@.*|==.*|>=.*", "", pkg)
    if (is.null(version)) {
      force_update <- isTRUE(force)
    } else {
      force_update <- isTRUE(packageVersion(pkg_name) < package_version(version)) || isTRUE(force)
    }
    if (!suppressPackageStartupMessages(requireNamespace(pkg_name, quietly = TRUE)) || isTRUE(force_update)) {
      message("Install package: \"", pkg_name, "\" ...")
      status_list[[pkg]] <- FALSE
      i <- 1
      while (isFALSE(status_list[[pkg]])) {
        tryCatch(expr = {
          if (grepl("BiocManager", install_methods[i])) {
            if (!requireNamespace("BiocManager", quietly = TRUE)) {
              install.packages("BiocManager", lib = lib)
            }
            eval(str2lang(paste0(install_methods[i], "(\"", dest, "\", lib=\"", lib, "\", update = FALSE, upgrade = \"never\", ask = FALSE, force = TRUE)")))
          } else if (grepl("devtools", install_methods[i])) {
            if (!requireNamespace("devtools", quietly = TRUE)) {
              install.packages("devtools", lib = lib)
            }
            if (!requireNamespace("withr", quietly = TRUE)) {
              install.packages("withr", lib = lib)
            }
            eval(str2lang(paste0("withr::with_libpaths(new = \"", lib, "\", ", install_methods[i], "(\"", dest, "\", upgrade = \"never\", force = TRUE))")))
          } else {
            eval(str2lang(paste0(install_methods[i], "(\"", dest, "\", lib=\"", lib, "\", force = TRUE)")))
          }
        }, error = function(e) {
          status_list[[pkg]] <- FALSE
        })
        status_list[[pkg]] <- requireNamespace(pkg_name, quietly = TRUE)
        i <- i + 1
        if (i > length(install_methods)) {
          break
        }
      }
    } else {
      status_list[[pkg]] <- TRUE
    }
  }
  out <- sapply(status_list, isTRUE)
  out <- out[!out]
  if (length(out) > 0) {
    stop("Failed to install the package(s): ", paste0(names(out), collapse = ","), ". Please install manually.")
  }
}

# ---- utils.R:831-841 : as_matrix ----
as_matrix <- function(x) {
  if (!inherits(matrix, "dgCMatrix")) {
    return(as.matrix(x))
  } else {
    row_pos <- x@i
    col_pos <- findInterval(seq_along(x@x) - 1, x@p[-1])
    out <- asMatrix(rp = row_pos, cp = col_pos, z = x@x, nrows = x@Dim[1], ncols = x@Dim[2])
    attr(out, "dimnames") <- list(x@Dimnames[[1]], x@Dimnames[[2]])
    return(out)
  }
}

