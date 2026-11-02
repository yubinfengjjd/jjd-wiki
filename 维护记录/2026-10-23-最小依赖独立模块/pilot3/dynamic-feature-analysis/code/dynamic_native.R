# Minimal runtime module extracted verbatim from SCP-local 0.5.6 (GPL (>= 3)).
# Source: https://github.com/zhanghao-njmu/SCP commit b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0
# Roots: RunDynamicFeatures
# Functions: RunDynamicFeatures, check_DataType, check_R, as_matrix
# Function bodies are copied from the pinned source without algorithm changes.
# Automatic installation is disabled by the caller. Local resources are loaded only by the caller.

# ---- SCP-analysis.R:4948-5171 : RunDynamicFeatures ----
RunDynamicFeatures <- function(srt, lineages, features = NULL, suffix = lineages,
                               n_candidates = 1000, minfreq = 5,
                               family = NULL,
                               slot = "counts", assay = NULL, libsize = NULL,
                               BPPARAM = BiocParallel::bpparam(), seed = 11) {
  set.seed(seed)
  bpprogressbar(BPPARAM) <- TRUE
  bpRNGseed(BPPARAM) <- seed
  assay <- assay %||% DefaultAssay(srt)

  time_start <- Sys.time()
  message(paste0("[", time_start, "] ", "Start RunDynamicFeatures"))
  message("Workers: ", bpworkers(BPPARAM))

  check_R("mgcv")
  meta <- c()
  gene <- c()
  if (!is.null(features)) {
    gene <- features[features %in% rownames(srt[[assay]])]
    meta <- features[features %in% colnames(srt@meta.data)]
    isnum <- sapply(srt@meta.data[, meta, drop = FALSE], is.numeric)
    if (!all(isnum)) {
      warning(paste0(meta[!isnum], collapse = ","), " is not numeric and will be dropped.", immediate. = TRUE)
      meta <- meta[isnum]
    }
    features <- c(gene, meta)
    if (length(features) == 0) {
      stop("No feature found in the srt object.")
    }
  }

  Y <- GetAssayData(srt, slot = slot, assay = assay)
  if (is.null(libsize)) {
    status <- check_DataType(srt, assay = assay, slot = "counts")
    if (status != "raw_counts") {
      Y_libsize <- setNames(rep(1, ncol(srt)), colnames(srt))
    } else {
      Y_libsize <- colSums(GetAssayData(srt, slot = "counts", assay = assay))
    }
  } else {
    if (length(libsize) == 1) {
      Y_libsize <- setNames(rep(libsize, ncol(srt)), colnames(srt))
    } else if (length(libsize) == ncol(srt)) {
      Y_libsize <- setNames(libsize, colnames(srt))
    } else {
      stop("libsize must be length of 1 or the number of cells.")
    }
  }

  if (length(meta) > 0) {
    Y <- rbind(Y, t(srt@meta.data[, meta, drop = FALSE]))
  }

  features_list <- c()
  srt_sub_list <- list()
  for (l in lineages) {
    srt_sub <- subset(srt, cell = rownames(srt@meta.data)[is.finite(srt@meta.data[[l]])])
    if (is.null(features)) {
      if (is.null(n_candidates)) {
        stop("'features' or 'n_candidates' must provided at least one.")
      }
      HVF <- VariableFeatures(FindVariableFeatures(srt_sub, nfeatures = n_candidates, assay = assay), assay = assay)
      HVF_counts <- srt_sub[[assay]]@counts[HVF, , drop = FALSE]
      HVF <- HVF[apply(HVF_counts, 1, function(x) {
        length(unique(x))
      }) >= minfreq]
      features_list[[l]] <- HVF
    } else {
      features_list[[l]] <- features
    }
    srt_sub_list[[l]] <- srt_sub
  }
  features <- unique(unlist(features_list))
  gene <- features[features %in% rownames(srt[[assay]])]
  meta <- features[features %in% colnames(srt@meta.data)]
  message("Number of candidate features(union): ", length(features))

  if (slot == "counts") {
    gene_status <- status
  }
  gene_status <- status <- check_DataType(srt, assay = assay, slot = slot)
  meta_status <- sapply(meta, function(x) {
    check_DataType(data = srt[[x]])
  })
  if (is.null(family)) {
    family <- rep("gaussian", length(features))
    names(family) <- features
    family[names(meta_status)[meta_status == "raw_counts"]] <- "nb"
    if (gene_status == "raw_counts") {
      family[gene] <- "nb"
    }
  } else {
    if (length(family) == 1) {
      family <- rep(family, length(features))
      names(family) <- features
    }
    if (length(family) != length(features)) {
      stop("'family' must be one character or a vector of the same length as features.")
    }
  }

  for (i in seq_along(lineages)) {
    l <- lineages[i]
    srt_sub <- srt_sub_list[[l]]
    t <- srt_sub[[l, drop = TRUE]]
    t <- t[is.finite(t)]
    t_ordered <- t[order(t)]
    Y_ordered <- as_matrix(Y[features, names(t_ordered), drop = FALSE])
    l_libsize <- Y_libsize[names(t_ordered)]
    raw_matrix <- as_matrix(cbind(data.frame(pseudotime = t_ordered), t(Y_ordered)))

    # df <- data.frame(x = rowMeans(Y_ordered), y = MatrixGenerics::rowVars(Y_ordered))
    # p <- ggplot(df, aes(x = .data[["x"]], y = .data[["y"]])) +
    #   geom_point() +
    #   geom_abline(slope = 1, intercept = 0, color = "red") +
    #   labs(title = l, subtitle = "Var VS Mean") +
    #   theme_scp()
    # print(p)

    message("Calculate dynamic features for ", l, "...")
    system.time({
      gam_out <- bplapply(seq_len(nrow(Y_ordered)), function(n, Y_ordered, t_ordered, l_libsize, family) {
        feature_nm <- rownames(Y_ordered)[n]
        family_current <- family[feature_nm]
        if (min(Y_ordered[feature_nm, ]) < 0 && family_current %in% c("nb", "poisson", "binomial")) {
          warning("Negative values detected. Replace family with 'gaussian' for the feature: ", feature_nm, immediate. = TRUE)
          family_use <- "gaussian"
        } else {
          family_use <- family_current
        }
        if (slot == "counts" && family_use != "gaussian" && !feature_nm %in% meta) {
          l_libsize <- l_libsize
        } else {
          l_libsize <- rep(median(Y_libsize), ncol(Y_ordered))
        }
        sizefactror <- median(Y_libsize) / l_libsize
        mod <- mgcv::gam(y ~ s(x, bs = "cs") + offset(log(l_libsize)),
          family = family_use,
          data = data.frame(y = Y_ordered[feature_nm, ], x = t_ordered, l_libsize = l_libsize)
        )
        pre <- predict(mod, type = "link", se.fit = TRUE)
        upr <- pre$fit + (2 * pre$se.fit)
        lwr <- pre$fit - (2 * pre$se.fit)
        upr <- mod$family$linkinv(upr)
        lwr <- mod$family$linkinv(lwr)
        res <- summary(mod)
        fitted <- fitted(mod)
        pvalue <- res$s.table[[4]]
        dev.expl <- res$dev.expl
        r.sq <- res$r.sq
        fitted.values <- fitted * sizefactror
        upr.values <- upr * sizefactror
        lwr.values <- lwr * sizefactror
        exp_ncells <- sum(Y_ordered[feature_nm, ] > min(Y_ordered[feature_nm, ]), na.rm = TRUE)
        peaktime <- median(t_ordered[fitted.values > quantile(fitted.values, 0.99, na.rm = TRUE)])
        valleytime <- median(t_ordered[fitted.values < quantile(fitted.values, 0.01, na.rm = TRUE)])

        # ggplot(data = data.frame(
        #   x = t_ordered,
        #   raw = FetchData(srt_sub, vars = feature_nm, slot = "counts")[names(t_ordered), feature_nm, drop = TRUE],
        #   fitted = fitted.values,
        #   upr.values = upr.values,
        #   lwr.values = lwr.values,
        #   l_libsize = l_libsize
        # )) +
        #   geom_point(aes(x = x, y = raw), color = "black", size = 0.5) +
        #   geom_point(aes(x = x, y = fitted), color = "red", size = 0.5) +
        #   geom_path(aes(x = x, y = upr.values), color = "blue") +
        #   geom_path(aes(x = x, y = lwr.values), color = "green")

        # a <- data.frame(x = t_ordered, y = Y_ordered[feature_nm, ])
        # qplot(a$x, a$y)
        # length(unique(a$y) > 5)
        # a <- a[a$y > 0, ]
        # qplot(a$x, a$y)

        return(list(
          features = feature_nm, exp_ncells = exp_ncells,
          r.sq = r.sq, dev.expl = dev.expl,
          peaktime = peaktime, valleytime = valleytime,
          pvalue = pvalue, fitted.values = fitted.values,
          upr.values = upr.values, lwr.values = lwr.values
        ))
      }, BPPARAM = BPPARAM, Y_ordered = Y_ordered, t_ordered = t_ordered, l_libsize = l_libsize, family = family)
    })
    fitted_matrix <- do.call(cbind, lapply(gam_out, function(x) x[["fitted.values"]]))
    colnames(fitted_matrix) <- rownames(Y_ordered)
    fitted_matrix <- cbind(pseudotime = t_ordered, fitted_matrix)

    upr_matrix <- do.call(cbind, lapply(gam_out, function(x) x[["upr.values"]]))
    colnames(upr_matrix) <- rownames(Y_ordered)
    upr_matrix <- cbind(pseudotime = t_ordered, upr_matrix)

    lwr_matrix <- do.call(cbind, lapply(gam_out, function(x) x[["lwr.values"]]))
    colnames(lwr_matrix) <- rownames(Y_ordered)
    lwr_matrix <- cbind(pseudotime = t_ordered, lwr_matrix)

    DynamicFeatures <- as.data.frame(do.call(rbind.data.frame, lapply(gam_out, function(x) x[!names(x) %in% c("fitted.values", "upr.values", "lwr.values")])))
    char_var <- c("features")
    numb_var <- colnames(DynamicFeatures)[!colnames(DynamicFeatures) %in% char_var]
    DynamicFeatures[, char_var] <- lapply(DynamicFeatures[, char_var, drop = FALSE], as.character)
    DynamicFeatures[, numb_var] <- lapply(DynamicFeatures[, numb_var, drop = FALSE], as.numeric)
    rownames(DynamicFeatures) <- DynamicFeatures[["features"]]
    DynamicFeatures[, "padjust"] <- p.adjust(DynamicFeatures[, "pvalue", drop = TRUE])

    res <- list(
      DynamicFeatures = DynamicFeatures,
      raw_matrix = raw_matrix,
      fitted_matrix = fitted_matrix,
      upr_matrix = upr_matrix,
      lwr_matrix = lwr_matrix,
      libsize = l_libsize,
      lineages = l,
      family = family
    )
    srt@tools[[paste0("DynamicFeatures_", suffix[i])]] <- res
  }

  time_end <- Sys.time()
  message(paste0("[", time_end, "] ", "RunDynamicFeatures done"))
  message("Elapsed time:", format(round(difftime(time_end, time_start), 2), format = "%Y-%m-%d %H:%M:%S"))

  return(srt)
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

