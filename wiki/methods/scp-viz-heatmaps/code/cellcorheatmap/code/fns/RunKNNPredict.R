# SCP 0.5.6 commit b9b0eb7a | source R/SCP-cell_annotation.R:98-493
# sha256(func-block)=d3cb7cb0c497addca599a32921d6d9d7891218e34069375ba4e534b1d0c0d238
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
RunKNNPredict <- function(srt_query, srt_ref = NULL, bulk_ref = NULL,
                          query_group = NULL, ref_group = NULL,
                          query_assay = NULL, ref_assay = NULL,
                          query_reduction = NULL, ref_reduction = NULL,
                          query_dims = 1:30, ref_dims = 1:30,
                          query_collapsing = !is.null(query_group), ref_collapsing = TRUE,
                          return_full_distance_matrix = FALSE,
                          features = NULL, features_type = c("HVF", "DE"), feature_source = "both", nfeatures = 2000,
                          DEtest_param = list(max.cells.per.ident = 200, test.use = "wilcox"),
                          DE_threshold = "p_val_adj < 0.05",
                          nn_method = NULL, distance_metric = "cosine", k = 30,
                          filter_lowfreq = 0, prefix = "KNNPredict") {
  query_assay <- query_assay %||% DefaultAssay(srt_query)
  features_type <- match.arg(features_type, choices = c("HVF", "DE"))
  if (is.null(query_reduction) + is.null(ref_reduction) == 1) {
    stop("query_reduction and ref_reduction must be both provided")
  }
  if (is.null(query_reduction) + is.null(ref_reduction) == 2) {
    use_reduction <- FALSE
  } else {
    use_reduction <- TRUE
  }
  if (!isTRUE(use_reduction)) {
    if (length(features) == 0) {
      if (features_type == "HVF" && feature_source %in% c("both", "query")) {
        if (length(VariableFeatures(srt_query, assay = query_assay)) == 0) {
          srt_query <- FindVariableFeatures(srt_query, nfeatures = nfeatures, assay = query_assay)
        }
        features_query <- VariableFeatures(srt_query, assay = query_assay)
      } else if (features_type == "DE" && feature_source %in% c("both", "query")) {
        if (is.null(query_group)) {
          stop("'query_group' must be provided when 'features_type' is 'DE' and 'feature_source' is 'both' or 'query'")
        } else {
          slot <- paste0("DEtest_", query_group)
          DEtest_param[["force"]] <- TRUE
          if (!slot %in% names(srt_query@tools) || length(grep(pattern = "AllMarkers", names(srt_query@tools[[slot]]))) == 0) {
            srt_query <- do.call(RunDEtest, c(list(srt = srt_query, group_by = query_group), DEtest_param))
          }
          if ("test.use" %in% names(DEtest_param)) {
            test.use <- DEtest_param[["test.use"]]
          } else {
            test.use <- "wilcox"
          }
          index <- grep(pattern = paste0("AllMarkers_", test.use), names(srt_query@tools[[slot]]))[1]
          de <- names(srt_query@tools[[slot]])[index]
          message("Use the DE features from ", de, " to calculate distance metric.")
          de_df <- srt_query@tools[[slot]][[de]]
          de_df <- de_df[with(de_df, eval(rlang::parse_expr(DE_threshold))), , drop = FALSE]
          rownames(de_df) <- seq_len(nrow(de_df))
          de_df <- de_df[order(de_df[["avg_log2FC"]], decreasing = TRUE), , drop = FALSE]
          de_top <- de_df[!duplicated(de_df[["gene"]]), , drop = FALSE]
          stat <- sort(table(de_top$group1))
          stat <- stat[stat > 0]
          mat <- matrix(FALSE, nrow = max(stat), ncol = length(stat))
          colnames(mat) <- names(stat)
          for (g in names(stat)) {
            mat[1:stat[g], g] <- TRUE
          }
          nfeatures <- sum(cumsum(rowSums(mat)) <= nfeatures)
          if (test.use == "roc") {
            features_query <- unlist(by(de_top, list(de_top[["group1"]]), function(x) {
              x <- x[order(x[["power"]], decreasing = TRUE), , drop = FALSE]
              head(x[["gene"]], nfeatures)
            }))
          } else {
            features_query <- unlist(by(de_top, list(de_top[["group1"]]), function(x) {
              x <- x[order(x[["p_val"]], decreasing = FALSE), , drop = FALSE]
              head(x[["gene"]], nfeatures)
            }))
          }
          message("DE features number of the query data: ", length(features_query))
        }
      } else {
        features_query <- rownames(srt_query[[query_assay]])
      }
    }
  }

  if (!is.null(bulk_ref)) {
    if (length(features) == 0) {
      features <- features_query
    }
    features_common <- intersect(features, rownames(bulk_ref))
    message("Use ", length(features_common), " features to calculate distance.")
    ref <- t(bulk_ref[features_common, , drop = FALSE])
  } else if (!is.null(srt_ref)) {
    ref_assay <- ref_assay %||% DefaultAssay(srt_ref)
    if (!is.null(ref_group)) {
      if (length(ref_group) == ncol(srt_ref)) {
        srt_ref[["ref_group"]] <- ref_group
      } else if (length(ref_group) == 1) {
        if (!ref_group %in% colnames(srt_ref@meta.data)) {
          stop("ref_group must be one of the column names in the meta.data")
        } else {
          srt_ref[["ref_group"]] <- srt_ref[[ref_group]]
        }
      } else {
        stop("Length of ref_group must be one or length of srt_ref.")
      }
    } else {
      stop("ref_group must be provided.")
    }
    drop_cell <- colnames(srt_ref)[is.na(srt_ref[["ref_group", drop = TRUE]])]
    if (length(drop_cell) > 0) {
      message("Drop ", length(drop_cell), " cells with NA in the ref_group")
      srt_ref <- srt_ref[, setdiff(colnames(srt_ref), drop_cell)]
    }
    if (isTRUE(use_reduction)) {
      message("Use the reduction to calculate distance metric.")
      if (!is.null(query_dims) && !is.null(ref_dims) && length(query_dims) == length(ref_dims)) {
        query <- Embeddings(srt_query, reduction = query_reduction)[, query_dims]
        ref <- Embeddings(srt_ref, reduction = ref_reduction)[, ref_dims]
      } else {
        stop("query_dims and ref_dims must be provided with the same length.")
      }
    } else {
      if (length(features) == 0) {
        if (features_type == "HVF" && feature_source %in% c("both", "ref")) {
          message("Use the HVF to calculate distance metric.")
          if (length(VariableFeatures(srt_ref, assay = ref_assay)) == 0) {
            srt_ref <- FindVariableFeatures(srt_ref, nfeatures = nfeatures, assay = ref_assay)
          }
          features_ref <- VariableFeatures(srt_ref, assay = ref_assay)
        } else if (features_type == "DE" && feature_source %in% c("both", "ref")) {
          slot <- paste0("DEtest_", ref_group)
          DEtest_param[["force"]] <- TRUE
          if (!slot %in% names(srt_ref@tools) || length(grep(pattern = "AllMarkers", names(srt_ref@tools[[slot]]))) == 0) {
            srt_ref <- do.call(RunDEtest, c(list(srt = srt_ref, group_by = ref_group), DEtest_param))
          }
          if ("test.use" %in% names(DEtest_param)) {
            test.use <- DEtest_param[["test.use"]]
          } else {
            test.use <- "wilcox"
          }
          index <- grep(pattern = paste0("AllMarkers_", test.use), names(srt_ref@tools[[slot]]))[1]
          de <- names(srt_ref@tools[[slot]])[index]
          message("Use the DE features from ", de, " to calculate distance metric.")
          de_df <- srt_ref@tools[[slot]][[de]]
          de_df <- de_df[with(de_df, eval(rlang::parse_expr(DE_threshold))), , drop = FALSE]
          rownames(de_df) <- seq_len(nrow(de_df))
          de_df <- de_df[order(de_df[["avg_log2FC"]], decreasing = TRUE), , drop = FALSE]
          de_top <- de_df[!duplicated(de_df[["gene"]]), , drop = FALSE]
          stat <- sort(table(de_top$group1))
          stat <- stat[stat > 0]
          mat <- matrix(FALSE, nrow = max(stat), ncol = length(stat))
          colnames(mat) <- names(stat)
          for (g in names(stat)) {
            mat[1:stat[g], g] <- TRUE
          }
          nfeatures <- sum(cumsum(rowSums(mat)) <= nfeatures)
          if (test.use == "roc") {
            features_ref <- unlist(by(de_top, list(de_top[["group1"]]), function(x) {
              x <- x[order(x[["power"]], decreasing = TRUE), , drop = FALSE]
              head(x[["gene"]], nfeatures)
            }))
          } else {
            features_ref <- unlist(by(de_top, list(de_top[["group1"]]), function(x) {
              x <- x[order(x[["p_val"]], decreasing = FALSE), , drop = FALSE]
              head(x[["gene"]], nfeatures)
            }))
          }
          message("DE features number of the ref data: ", length(features_ref))
        } else {
          features_ref <- rownames(srt_ref[[ref_assay]])
        }
        features <- intersect(features_ref, features_query)
      }
      features_common <- Reduce(intersect, list(features, rownames(srt_query[[query_assay]]), rownames(srt_ref[[ref_assay]])))
      message("Use ", length(features_common), " features to calculate distance.")
      if (isTRUE(ref_collapsing)) {
        ref <- AverageExpression(object = srt_ref, features = features_common, slot = "data", assays = ref_assay, group.by = "ref_group", verbose = FALSE)[[1]]
        ref <- t(log1p(ref))
      } else {
        ref <- t(GetAssayData(srt_ref, slot = "data", assay = ref_assay)[features_common, ])
      }
    }
  } else {
    stop("srt_ref or bulk_ref must be provided at least one.")
  }

  if (!inherits(ref, "matrix")) {
    ref <- as_matrix(ref)
  }
  k <- min(c(k, nrow(ref)))

  if (!is.null(query_group)) {
    if (length(query_group) == ncol(srt_query)) {
      srt_query[["query_group"]] <- query_group
    } else if (length(query_group) == 1) {
      if (!query_group %in% colnames(srt_query@meta.data)) {
        stop("query_group must be one of the column names in the meta.data")
      } else {
        srt_query[["query_group"]] <- srt_query[[query_group]]
      }
    } else {
      stop("Length of query_group must be one or length of srt_query.")
    }
  }
  if (!isTRUE(use_reduction)) {
    query_assay <- query_assay %||% DefaultAssay(srt_query)
    if (isTRUE(query_collapsing)) {
      if (is.null(query_group)) {
        stop("query_group must be provided when query_collapsing is TRUE.")
      }
      query <- AverageExpression(object = srt_query, features = colnames(ref), slot = "data", assays = query_assay, group.by = "query_group", verbose = FALSE)[[1]]
      query <- t(log1p(query))
    } else {
      query <- t(GetAssayData(srt_query, slot = "data", assay = query_assay)[colnames(ref), , drop = FALSE])
    }
  }

  if (!isTRUE(use_reduction)) {
    status_dat <- check_DataType(data = query)
    message("Detected query data type: ", status_dat)
    status_ref <- check_DataType(data = ref)
    message("Detected reference data type: ", status_ref)
    if (status_ref != status_dat || any(status_dat == "unknown", status_ref == "unknown")) {
      warning("Data type is unknown or different between query and reference.", immediate. = TRUE)
    }
  }

  message("Calculate similarity...")
  # tst.expr <- matrix(data = 0, nrow = nrow(ref), ncol = dim(query)[2])
  # rownames(tst.expr) <- rownames(ref)
  # colnames(tst.expr) <- colnames(query)
  # features_common <- intersect(rownames(query), rownames(ref.expr))
  # tst.expr[features_common, ] <- as_matrix(query[features_common, ])
  #
  # library(RcppArmadillo)
  # library(RcppXPtrUtils)
  # library(parallelDist)
  #   query <- cbind(ref.expr, tst.expr)
  #   query <- apply(query, 2, function(x) x - mean(x))
  #   CosineCPP <- cppXPtr(
  #     "double customDist(const arma::mat &A, const arma::mat &B) {
  #   double similarity = arma::as_scalar(arma::dot(A, B))/(arma::as_scalar(arma::norm(A))*arma::as_scalar(arma::norm(B))) ;
  #   return(similarity);
  # }",
  #     depends = c("RcppArmadillo")
  #   )
  #   cors <- as_matrix(parDist(t(query), method = "custom", func = CosineCPP))
  #   cors <- cors[colnames(ref.expr), colnames(tst.expr)]
  #

  if (is.null(nn_method)) {
    if (as.numeric(nrow(query)) * as.numeric(nrow(ref)) >= 1e8) {
      nn_method <- "annoy"
    } else {
      nn_method <- "raw"
    }
  }
  message("Use '", nn_method, "' method to find neighbors.")
  if (!nn_method %in% c("raw", "annoy", "rann")) {
    stop("nn_method must be one of raw, rann and annoy")
  }
  if (nn_method == "annoy" && !distance_metric %in% c("euclidean", "cosine", "manhattan", "hamming")) {
    stop("distance_metric must be one of euclidean, cosine, manhattan, and hamming when nn_method='annoy'")
  }
  if (isTRUE(return_full_distance_matrix) && nn_method != "raw") {
    warning("Distance matrix will not be returned besause nn_method is not 'raw'", immediate. = TRUE)
    return_full_distance_matrix <- FALSE
  }
  simil_method <- c(
    "cosine", "pearson", "spearman", "correlation", "jaccard", "ejaccard", "dice", "edice",
    "hamman", "simple matching", "faith"
  )
  dist_method <- c(
    "euclidean", "chisquared", "kullback", "manhattan", "maximum", "canberra",
    "minkowski", "hamming"
  )
  if (!distance_metric %in% c(simil_method, dist_method)) {
    stop(distance_metric, " method is invalid.")
  }

  if (nn_method %in% c("annoy", "rann")) {
    query.neighbor <- FindNeighbors(
      query = query, object = ref,
      k.param = k, nn.method = nn_method, annoy.metric = distance_metric,
      return.neighbor = TRUE
    )
    match_k <- query.neighbor@nn.idx
    rownames(match_k) <- rownames(query)
    match_k_cell <- apply(match_k, c(1, 2), function(x) rownames(ref)[x])
    match_k_distance <- query.neighbor@nn.dist
    rownames(match_k_distance) <- rownames(query)
  } else {
    if (requireNamespace("RcppParallel", quietly = TRUE)) {
      RcppParallel::setThreadOptions()
    }
    if (distance_metric %in% c(simil_method, "pearson", "spearman")) {
      if (distance_metric %in% c("pearson", "spearman")) {
        if (distance_metric == "spearman") {
          ref <- t(apply(ref, 1, rank))
          query <- t(apply(query, 1, rank))
        }
        distance_metric <- "correlation"
      }
      d <- 1 - simil(
        x = as.sparse(ref),
        y = as.sparse(query),
        method = distance_metric,
        use_nan = TRUE
      )
    } else if (distance_metric %in% dist_method) {
      d <- dist(
        x = as.sparse(ref),
        y = as.sparse(query),
        method = distance_metric,
        use_nan = TRUE
      )
    }
    if (k == 1) {
      match_k_cell <- as_matrix(apply(d, 2, function(x) names(x)[order(x, decreasing = FALSE)[1]]))
      match_k_distance <- as_matrix(apply(d, 2, function(x) x[order(x, decreasing = FALSE)[1]]))
    } else {
      match_k_cell <- t(as_matrix(apply(d, 2, function(x) names(x)[order(x, decreasing = FALSE)[1:k]])))
      match_k_distance <- t(as_matrix(apply(d, 2, function(x) x[order(x, decreasing = FALSE)[1:k]])))
    }
  }

  message("Predict cell type...")
  match_prob <- NULL
  if (!is.null(srt_ref) && (isFALSE(ref_collapsing) || isTRUE(use_reduction))) {
    level <- as.character(unique(srt_ref[["ref_group", drop = TRUE]]))
    if (k == 1) {
      match_best <- srt_ref[["ref_group", drop = TRUE]][match_k_cell[, 1]]
      names(match_best) <- names(match_k_cell[, 1])
    } else {
      rn <- rownames(match_k_cell)
      match_k_cell <- matrix(srt_ref[["ref_group", drop = TRUE]][match_k_cell],
        nrow = nrow(match_k_cell), ncol = ncol(match_k_cell)
      )
      rownames(match_k_cell) <- rn
      match_freq <- apply(match_k_cell, 1, table)
      if (!inherits(match_freq, "list")) {
        match_freq <- as.list(setNames(object = rep(k, nrow(match_k_cell)), rn))
        match_freq <- lapply(setNames(names(match_freq), names(match_freq)), function(x) setNames(k, match_k_cell[x, 1]))
      }
      match_prob <- do.call(rbind, lapply(match_freq, function(x) {
        x[level[!level %in% names(x)]] <- 0
        x <- x / sum(x)
        return(x)
      }))
      match_prob <- as_matrix(match_prob)
      rownames(match_prob) <- names(match_freq)
      match_best <- apply(match_prob, 1, function(x) names(x)[order(x, decreasing = TRUE)][1])
    }
  } else {
    match_best <- match_k_cell[, 1]
  }

  result <- list(
    features = features, nn_method = nn_method, distance_metric = distance_metric, k = k,
    other_params = list(
      query_group = query_group, query_reduction = query_reduction, query_assay = query_assay, query_dims = query_dims, query_collapsing = query_collapsing,
      ref_group = ref_group, ref_reduction = ref_reduction, ref_assay = ref_assay, ref_dims = ref_dims, ref_collapsing = ref_collapsing
    )
  )
  result[["match_best"]] <- match_best
  if (!is.null(match_prob)) {
    result[["match_prob"]] <- match_prob
  }
  result[["match_k_cell"]] <- match_k_cell
  result[["match_k_distance"]] <- match_k_distance
  if (isTRUE(return_full_distance_matrix)) {
    result[["distance_matrix"]] <- d[seq_len(nrow(d)), , drop = FALSE]
  }

  srt_query@tools[[paste0(prefix, "_classification")]] <- result

  if (isTRUE(query_collapsing)) {
    query_index <- as.character(srt_query[["query_group", drop = TRUE]])
  } else {
    query_index <- colnames(srt_query)
  }
  srt_query[[paste0(prefix, "_classification")]] <- match_best[query_index]
  if (!is.null(match_prob)) {
    srt_query[[paste0(prefix, "_prob")]] <- apply(match_prob, 1, max)[query_index]
  } else {
    distance <- match_k_distance[, 1]
    # srt_query[[paste0(prefix, "_score")]] <- ((max(distance) - distance) / diff(range(distance)))[query_index]
    if (distance_metric %in% c(simil_method, "pearson", "spearman")) {
      srt_query[[paste0(prefix, "_simil")]] <- (1 - distance)[query_index]
    } else {
      srt_query[[paste0(prefix, "_dist")]] <- distance[query_index]
    }
  }

  if (is.numeric(filter_lowfreq) && filter_lowfreq > 0) {
    drop <- table(srt_query[[paste0(prefix, "_classification"), drop = TRUE]])
    drop <- names(drop)[drop <= filter_lowfreq]
    srt_query[[paste0(prefix, "_classification"), drop = TRUE]][srt_query[[paste0(prefix, "_classification"), drop = TRUE]] %in% drop] <- "unreliable"
  }

  return(srt_query)
}
