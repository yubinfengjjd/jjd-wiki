# Minimal runtime module extracted verbatim from SCP-local 0.5.6 (GPL (>= 3)).
# Source: https://github.com/zhanghao-njmu/SCP commit b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0
# Roots: RunDEtest
# Functions: metap, FindConservedMarkers2, RunDEtest, check_DataType
# Function bodies are copied from the pinned source without algorithm changes.
# Automatic installation is disabled by the caller. Local resources are loaded only by the caller.

# ---- SCP-analysis.R:916-920 : metap ----
metap <- function(p, method = c("maximump", "minimump", "wilkinsonp", "meanp", "sump", "votep"), ...) {
  method <- match.arg(method)
  res <- do.call(method, args = list(p = p, ...))
  return(res)
}

# ---- SCP-analysis.R:1070-1218 : FindConservedMarkers2 ----
FindConservedMarkers2 <- function(object, grouping.var, ident.1, ident.2 = NULL, cells.1 = NULL, cells.2 = NULL, features = NULL,
                                  test.use = "wilcox", logfc.threshold = 0.25, base = 2, pseudocount.use = 1, mean.fxn = NULL,
                                  min.pct = 0.1, min.diff.pct = -Inf, max.cells.per.ident = Inf, latent.vars = NULL, only.pos = FALSE,
                                  assay = NULL, slot = "data", min.cells.group = 3, min.cells.feature = 3,
                                  meta.method = c("maximump", "minimump", "wilkinsonp", "meanp", "sump", "votep"),
                                  norm.method = "LogNormalize", verbose = TRUE, ...) {
  meta.method <- match.arg(meta.method)
  object.var <- FetchData(object = object, vars = grouping.var)
  levels.split <- names(x = sort(x = table(object.var[, 1])))
  num.groups <- length(levels.split)
  assay <- assay %||% DefaultAssay(object)

  cells <- list()
  for (i in 1:num.groups) {
    cells[[i]] <- rownames(x = object.var[object.var[, 1] == levels.split[i], , drop = FALSE])
  }
  marker.test <- list()
  if (is.null(cells.1)) {
    cells.1 <- WhichCells(object = object, idents = ident.1)
    if (!is.null(ident.2)) {
      cells.2 <- cells.2 %||% WhichCells(object = object, idents = ident.2)
    } else {
      cells.2 <- setdiff(colnames(object), cells.1)
    }
    object <- SetIdent(object = object, cells = colnames(x = object), value = paste(Idents(object = object), object.var[, 1], sep = "_"))
    ident.2.save <- ident.2
    for (i in 1:num.groups) {
      level.use <- levels.split[i]
      ident.use.1 <- paste(ident.1, level.use, sep = "_")
      ident.use.1.exists <- ident.use.1 %in% Idents(object = object)
      if (!all(ident.use.1.exists)) {
        bad.ids <- ident.1[!ident.use.1.exists]
        warning("Identity: ", paste(bad.ids, collapse = ", "), " not present in group ", level.use, ". Skipping ", level.use, call. = FALSE, immediate. = TRUE)
        next
      }
      ident.2 <- ident.2.save
      cells.1.use <- WhichCells(object = object, idents = ident.use.1)
      if (length(cells.1.use) < min.cells.group) {
        warning(level.use, " has fewer than ", min.cells.group, " cells in Identity: ", paste(ident.1, collapse = ", "), ". Skipping ", level.use, call. = FALSE, immediate. = TRUE)
        next
      }
      if (is.null(x = ident.2)) {
        cells.2.use <- setdiff(x = cells[[i]], y = cells.1.use)
        ident.use.2 <- names(x = which(x = table(Idents(object = object)[cells.2.use]) > 0))
        ident.2 <- gsub(pattern = paste0("_", level.use), replacement = "", x = ident.use.2)
        if (length(x = ident.use.2) == 0) {
          stop(paste("Only one identity class present:", ident.1))
        }
      } else {
        ident.use.2 <- paste(ident.2, level.use, sep = "_")
        cells.2.use <- WhichCells(object = object, idents = ident.use.2)
      }
      if (length(cells.2.use) < min.cells.group) {
        warning(level.use, " has fewer than ", min.cells.group, " cells. Skipping ", level.use, call. = FALSE, immediate. = TRUE)
        next
      }
      if (verbose) {
        message("Testing group ", level.use, ": (", paste(ident.1, collapse = ", "), ") vs (", paste(ident.2, collapse = ", "), ")")
      }
      ident.use.2.exists <- ident.use.2 %in% Idents(object = object)
      if (!all(ident.use.2.exists)) {
        bad.ids <- ident.2[!ident.use.2.exists]
        warning("Identity: ", paste(bad.ids, collapse = ", "),
          " not present in group ", level.use, ". Skipping ",
          level.use,
          call. = FALSE, immediate. = TRUE
        )
        next
      }
      marker.test[[level.use]] <- FindMarkers(
        object = Assays(object, assay), slot = slot, cells.1 = cells.1.use, cells.2 = cells.2.use, features = features,
        test.use = test.use, logfc.threshold = logfc.threshold,
        min.pct = min.pct, min.diff.pct = min.diff.pct, max.cells.per.ident = max.cells.per.ident,
        min.cells.group = min.cells.group, min.cells.feature = min.cells.feature,
        norm.method = norm.method, base = base, pseudocount.use = pseudocount.use, mean.fxn = mean.fxn,
        latent.vars = latent.vars, only.pos = only.pos,
        verbose = verbose, ...
      )
    }
  } else {
    for (i in 1:num.groups) {
      level.use <- levels.split[i]
      cells.1.use <- intersect(cells[[i]], cells.1)
      if (length(cells.1.use) < min.cells.group) {
        warning(level.use, " has fewer than ", min.cells.group, " cells. Skipping ", level.use, call. = FALSE, immediate. = TRUE)
        next
      }
      if (is.null(x = cells.2)) {
        cells.2.use <- setdiff(x = cells[[i]], y = cells.1.use)
      } else {
        cells.2.use <- intersect(cells[[i]], cells.2)
      }
      if (length(cells.2.use) < min.cells.group) {
        warning(level.use, " has fewer than ", min.cells.group, " cells. Skipping ", level.use, call. = FALSE, immediate. = TRUE)
        next
      }
      if (verbose) {
        message("Testing group ", level.use, ": (", paste("cells.1", collapse = ", "), ") vs (", paste("cells.2", collapse = ", "), ")")
      }
      marker.test[[level.use]] <- FindMarkers(
        object = Assays(object, assay), slot = slot, cells.1 = cells.1.use, cells.2 = cells.2.use, features = features,
        test.use = test.use, logfc.threshold = logfc.threshold,
        min.pct = min.pct, min.diff.pct = min.diff.pct, max.cells.per.ident = max.cells.per.ident,
        min.cells.group = min.cells.group, min.cells.feature = min.cells.feature,
        norm.method = norm.method, base = base, pseudocount.use = pseudocount.use, mean.fxn = mean.fxn,
        latent.vars = latent.vars, only.pos = only.pos,
        verbose = verbose, ...
      )
    }
  }
  marker.test <- marker.test[!sapply(marker.test, is.null)]
  if (length(marker.test) == 0) {
    warning("No group was tested", call. = FALSE, immediate. = TRUE)
    return(NULL)
  }
  genes.conserved <- Reduce(f = intersect, x = lapply(X = marker.test, FUN = function(x) {
    return(rownames(x = x))
  }))
  markers.conserved <- list()
  for (i in 1:length(x = marker.test)) {
    markers.conserved[[i]] <- marker.test[[i]][genes.conserved, , drop = FALSE]
    colnames(x = markers.conserved[[i]]) <- paste(names(x = marker.test)[i], colnames(x = markers.conserved[[i]]), sep = "_")
  }
  markers.combined <- Reduce(cbind, markers.conserved)
  fc <- FoldChange(Assays(object, assay), slot = slot, cells.1 = cells.1, cells.2 = cells.2, features = genes.conserved, norm.method = norm.method, base = base, pseudocount.use = pseudocount.use, mean.fxn = mean.fxn)
  markers.combined <- cbind(markers.combined, fc[genes.conserved, , drop = FALSE])
  logFC.codes <- colnames(x = markers.combined)[grepl(pattern = "*avg_log.*FC$", x = colnames(x = markers.combined))]
  if (isTRUE(only.pos)) {
    markers.combined <- markers.combined[apply(markers.combined[, logFC.codes] > 0, 1, all), , drop = FALSE]
  } else {
    markers.combined <- markers.combined[apply(markers.combined[, logFC.codes] < 0, 1, all) | apply(markers.combined[, logFC.codes] > 0, 1, all), , drop = FALSE]
  }
  pval.codes <- colnames(x = markers.combined)[grepl(pattern = "*_p_val$", x = colnames(x = markers.combined))]
  if (length(x = pval.codes) > 1) {
    markers.combined[["max_pval"]] <- apply(X = markers.combined[, pval.codes, drop = FALSE], MARGIN = 1, FUN = max)
    combined.pval <- data.frame(cp = apply(X = markers.combined[, pval.codes, drop = FALSE], MARGIN = 1, FUN = function(x) {
      return(metap(x, method = meta.method)$p)
    }))
    meta.method.name <- meta.method
    colnames(x = combined.pval) <- paste0(meta.method.name, "_p_val")
    markers.combined <- cbind(markers.combined, combined.pval)
    markers.combined[, "p_val"] <- markers.combined[, paste0(meta.method.name, "_p_val")]
    markers.combined <- markers.combined[order(markers.combined[, paste0(meta.method.name, "_p_val")]), , drop = FALSE]
  } else {
    markers.combined[, "max_pval"] <- markers.combined[, "p_val"] <- markers.combined[, pval.codes]
    warning("Only a single group was tested", call. = FALSE, immediate. = TRUE)
  }
  return(markers.combined)
}

# ---- SCP-analysis.R:1671-2106 : RunDEtest ----
RunDEtest <- function(srt, group_by = NULL, group1 = NULL, group2 = NULL, cells1 = NULL, cells2 = NULL, features = NULL,
                      markers_type = c("all", "paired", "conserved", "disturbed"),
                      grouping.var = NULL, meta.method = c("maximump", "minimump", "wilkinsonp", "meanp", "sump", "votep"),
                      test.use = "wilcox", only.pos = TRUE, fc.threshold = 1.5, base = 2, pseudocount.use = 1, mean.fxn = NULL,
                      min.pct = 0.1, min.diff.pct = -Inf, max.cells.per.ident = Inf, latent.vars = NULL,
                      min.cells.feature = 3, min.cells.group = 3,
                      norm.method = "LogNormalize", p.adjust.method = "bonferroni", slot = "data", assay = NULL,
                      BPPARAM = BiocParallel::bpparam(), seed = 11, verbose = TRUE, ...) {
  set.seed(seed)
  markers_type <- match.arg(markers_type)
  meta.method <- match.arg(meta.method)
  if (markers_type %in% c("conserved", "disturbed")) {
    if (is.null(grouping.var)) {
      stop("'grouping.var' must be provided when finding conserved or disturbed markers")
    }
  }
  assay <- assay %||% DefaultAssay(srt)

  status <- check_DataType(srt, slot = slot, assay = assay)
  if (slot == "counts" && status != "raw_counts") {
    stop("Data in the 'counts' slot is not raw counts.")
  }
  if (slot == "data" && status != "log_normalized_counts") {
    if (status == "raw_counts") {
      warning("Data in the 'data' slot is raw counts. Perform NormalizeData(LogNormalize) on the data.", immediate. = TRUE)
      srt <- NormalizeData(object = srt, assay = assay, normalization.method = "LogNormalize", verbose = FALSE)
    }
    if (status == "raw_normalized_counts") {
      warning("Data in the 'data' slot is raw_normalized_counts. Perform NormalizeData(LogNormalize) on the data.", immediate. = TRUE)
      srt <- NormalizeData(object = srt, assay = assay, normalization.method = "LogNormalize", verbose = FALSE)
    }
    if (status == "unknown") {
      warning("Data in the 'data' slot is unknown. Please check the data type.")
    }
  }
  bpprogressbar(BPPARAM) <- TRUE
  bpRNGseed(BPPARAM) <- seed

  time_start <- Sys.time()
  if (verbose) {
    message(paste0("[", time_start, "] ", "Start DEtest"))
    message("Workers: ", bpworkers(BPPARAM))
  }

  if (fc.threshold < 1) {
    stop("fc.threshold must be greater than or equal to 1")
  }

  if (!is.null(cells1) || !is.null(group1)) {
    if (is.null(cells1)) {
      if (is.null(group_by)) {
        stop("'group_by' must be provided when 'group1' specified")
      }
      cells1 <- colnames(srt)[srt[[group_by, drop = TRUE]] %in% group1]
    }
    if (is.null(cells2) && !is.null(group2)) {
      cells2 <- colnames(srt)[srt[[group_by, drop = TRUE]] %in% group2]
    }
    if (!all(cells1 %in% colnames(srt))) {
      stop("cells1 has some cells not in the Seurat object.")
    }
    if (is.null(cells2)) {
      cells2 <- colnames(srt)[!colnames(srt) %in% cells1]
      group2 <- "others"
    }
    if (!all(cells2 %in% colnames(srt))) {
      stop("cells2 has some cells not in the Seurat object.")
    }
    if (length(cells1) < 3 || length(cells2) < 3) {
      stop("Cell groups must have more than 3 cells")
    }
    if (verbose) {
      message("Find ", markers_type, " markers(", test.use, ") for custom cell groups...")
    }

    if (markers_type == "all") {
      markers <- FindMarkers(
        object = Assays(srt, assay), slot = slot,
        cells.1 = cells1,
        cells.2 = cells2,
        features = features,
        test.use = test.use,
        logfc.threshold = log(fc.threshold, base = base),
        base = base,
        min.pct = min.pct,
        min.diff.pct = min.diff.pct,
        max.cells.per.ident = max.cells.per.ident,
        min.cells.feature = min.cells.feature,
        min.cells.group = min.cells.group,
        latent.vars = latent.vars,
        only.pos = only.pos,
        norm.method = norm.method,
        pseudocount.use = pseudocount.use,
        mean.fxn = mean.fxn,
        verbose = FALSE,
        ...
      )
      if (!is.null(markers) && nrow(markers) > 0) {
        markers[, "gene"] <- rownames(markers)
        markers[, "group1"] <- group1 %||% "group1"
        markers[, "group2"] <- group2 %||% "group2"
        rownames(markers) <- NULL
        markers[, "group1"] <- factor(markers[, "group1"], levels = unique(markers[, "group1"]))
        if ("p_val" %in% colnames(markers)) {
          markers[, "p_val_adj"] <- p.adjust(markers[, "p_val"], method = p.adjust.method)
        }
        markers[, "test_group_number"] <- as.integer(table(markers[["gene"]])[markers[, "gene"]])
        MarkersMatrix <- as.data.frame.matrix(table(markers[, c("gene", "group1")]))
        markers[, "test_group"] <- apply(MarkersMatrix, 1, function(x) {
          paste0(colnames(MarkersMatrix)[x > 0], collapse = ";")
        })[markers[, "gene"]]
        srt@tools[["DEtest_custom"]][[paste0("AllMarkers_", test.use)]] <- markers
        srt@tools[["DEtest_custom"]][["cells1"]] <- cells1
        srt@tools[["DEtest_custom"]][["cells2"]] <- cells2
      } else {
        warning("No markers found.", immediate. = TRUE)
      }
    }
    if (markers_type == "conserved") {
      markers <- FindConservedMarkers2(
        object = srt, assay = assay, slot = slot,
        cells.1 = cells1,
        cells.2 = cells2,
        features = features,
        grouping.var = grouping.var,
        test.use = test.use,
        logfc.threshold = log(fc.threshold, base = base),
        base = base,
        min.pct = min.pct,
        min.diff.pct = min.diff.pct,
        max.cells.per.ident = max.cells.per.ident,
        min.cells.feature = min.cells.feature,
        min.cells.group = min.cells.group,
        latent.vars = latent.vars,
        only.pos = only.pos,
        norm.method = norm.method,
        meta.method = meta.method,
        pseudocount.use = pseudocount.use,
        mean.fxn = mean.fxn,
        verbose = FALSE,
        ...
      )
      if (!is.null(markers) && nrow(markers) > 0) {
        markers[, "gene"] <- rownames(markers)
        markers[, "group1"] <- group1 %||% "group1"
        markers[, "group2"] <- group2 %||% "group2"
        rownames(markers) <- NULL
        markers[, "group1"] <- factor(markers[, "group1"], levels = unique(markers[, "group1"]))
        if ("p_val" %in% colnames(markers)) {
          markers[, "p_val_adj"] <- p.adjust(markers[, "p_val"], method = p.adjust.method)
        }
        markers[, "test_group_number"] <- as.integer(table(markers[["gene"]])[markers[, "gene"]])
        MarkersMatrix <- as.data.frame.matrix(table(markers[, c("gene", "group1")]))
        markers[, "test_group"] <- apply(MarkersMatrix, 1, function(x) {
          paste0(colnames(MarkersMatrix)[x > 0], collapse = ";")
        })[markers[, "gene"]]
        srt@tools[["DEtest_custom"]][[paste0("ConservedMarkers_", test.use)]] <- markers
        srt@tools[["DEtest_custom"]][["cells1"]] <- cells1
        srt@tools[["DEtest_custom"]][["cells2"]] <- cells2
      } else {
        warning("No markers found.", immediate. = TRUE)
      }
    }
    if (markers_type == "disturbed") {
      srt_tmp <- srt
      srt_tmp[[grouping.var, drop = TRUE]][setdiff(colnames(srt_tmp), cells1)] <- NA
      bpprogressbar(BPPARAM) <- FALSE
      srt_tmp <- RunDEtest(
        srt = srt_tmp, assay = assay, slot = slot,
        group_by = grouping.var,
        markers_type = "all",
        features = features,
        test.use = test.use,
        fc.threshold = fc.threshold,
        base = base,
        min.pct = min.pct,
        min.diff.pct = min.diff.pct,
        max.cells.per.ident = max.cells.per.ident,
        min.cells.feature = min.cells.feature,
        min.cells.group = min.cells.group,
        latent.vars = latent.vars,
        only.pos = only.pos,
        norm.method = norm.method,
        p.adjust.method = p.adjust.method,
        pseudocount.use = pseudocount.use,
        mean.fxn = mean.fxn,
        BPPARAM = BPPARAM,
        seed = seed,
        verbose = FALSE,
        ...
      )
      markers <- srt_tmp@tools[[paste0("DEtest_", grouping.var)]][[paste0("AllMarkers_", test.use)]]
      if (!is.null(markers) && nrow(markers) > 0) {
        colnames(markers) <- gsub("group", "var", colnames(markers))
        markers[["group1"]] <- group1 %||% "group1"
        srt@tools[["DEtest_custom"]][[paste0("DisturbedMarkers_", test.use)]] <- markers
        srt@tools[["DEtest_custom"]][["cells1"]] <- cells1
      } else {
        warning("No markers found.", immediate. = TRUE)
      }
    }
  } else {
    if (is.null(group_by)) {
      cell_group <- Idents(srt)
      group_by <- "active.ident"
    } else {
      cell_group <- srt[[group_by, drop = TRUE]]
    }
    if (!is.factor(cell_group)) {
      cell_group <- factor(cell_group, levels = unique(cell_group))
    }
    cell_group <- lapply(levels(cell_group), function(x) {
      cell <- cell_group[cell_group == x]
      out <- sample(cell, size = min(max.cells.per.ident, length(cell)), replace = FALSE)
      return(out)
    })
    cell_group <- setNames(unlist(lapply(cell_group, function(x) x), use.names = FALSE), unlist(lapply(cell_group, names)))

    args1 <- list(
      object = Assays(srt, assay),
      slot = slot,
      features = features,
      test.use = test.use,
      logfc.threshold = log(fc.threshold, base = base),
      base = base,
      min.pct = min.pct,
      min.diff.pct = min.diff.pct,
      max.cells.per.ident = max.cells.per.ident,
      min.cells.feature = min.cells.feature,
      min.cells.group = min.cells.group,
      latent.vars = latent.vars,
      only.pos = only.pos,
      norm.method = norm.method,
      pseudocount.use = pseudocount.use,
      mean.fxn = mean.fxn,
      verbose = FALSE,
      ...
    )

    if (verbose) {
      message("Find ", markers_type, " markers(", test.use, ") among ", nlevels(cell_group), " groups...")
    }
    if (markers_type == "all") {
      AllMarkers <- bplapply(levels(cell_group), FUN = function(group) {
        cells.1 <- names(cell_group)[which(cell_group == group)]
        cells.2 <- names(cell_group)[which(cell_group != group)]
        # print(paste0(group," cells.1:",length(cells.1)," cells.2:",length(cells.2)))
        if (length(cells.1) < 3 || length(cells.2) < 3) {
          return(NULL)
        } else {
          args1[["cells.1"]] <- cells.1
          args1[["cells.2"]] <- cells.2
          markers <- do.call(FindMarkers, args1)
          if (!is.null(markers) && nrow(markers) > 0) {
            markers[, "gene"] <- rownames(markers)
            markers[, "group1"] <- as.character(group)
            markers[, "group2"] <- "others"
            if ("p_val" %in% colnames(markers)) {
              markers[, "p_val_adj"] <- p.adjust(markers[, "p_val"], method = p.adjust.method)
            }
            return(markers)
          } else {
            return(NULL)
          }
        }
      }, BPPARAM = BPPARAM)
      AllMarkers <- do.call(rbind.data.frame, AllMarkers)
      if (!is.null(AllMarkers) && nrow(AllMarkers) > 0) {
        rownames(AllMarkers) <- NULL
        AllMarkers[, "group1"] <- factor(AllMarkers[, "group1"], levels = levels(cell_group))
        AllMarkers[, "test_group_number"] <- as.integer(table(AllMarkers[["gene"]])[AllMarkers[, "gene"]])
        AllMarkersMatrix <- as.data.frame.matrix(table(AllMarkers[, c("gene", "group1")]))
        AllMarkers[, "test_group"] <- apply(AllMarkersMatrix, 1, function(x) {
          paste0(colnames(AllMarkersMatrix)[x > 0], collapse = ";")
        })[AllMarkers[, "gene"]]
        srt@tools[[paste0("DEtest_", group_by)]][[paste0("AllMarkers_", test.use)]] <- AllMarkers
      } else {
        srt@tools[[paste0("DEtest_", group_by)]][[paste0("AllMarkers_", test.use)]] <- data.frame()
      }
    }

    if (markers_type == "paired") {
      pair <- expand.grid(x = levels(cell_group), y = levels(cell_group))
      pair <- pair[pair[, 1] != pair[, 2], , drop = FALSE]
      PairedMarkers <- bplapply(seq_len(nrow(pair)), function(i) {
        cells.1 <- names(cell_group)[which(cell_group == pair[i, 1])]
        cells.2 <- names(cell_group)[which(cell_group == pair[i, 2])]
        if (length(cells.1) < 3 || length(cells.2) < 3) {
          return(NULL)
        } else {
          args1[["cells.1"]] <- cells.1
          args1[["cells.2"]] <- cells.2
          markers <- do.call(FindMarkers, args1)
          if (!is.null(markers) && nrow(markers) > 0) {
            markers[, "gene"] <- rownames(markers)
            markers[, "group1"] <- as.character(pair[i, 1])
            markers[, "group2"] <- as.character(pair[i, 2])
            if ("p_val" %in% colnames(markers)) {
              markers[, "p_val_adj"] <- p.adjust(markers[, "p_val"], method = p.adjust.method)
            }
            return(markers)
          } else {
            return(NULL)
          }
        }
      }, BPPARAM = BPPARAM)
      PairedMarkers <- do.call(rbind.data.frame, PairedMarkers)
      if (!is.null(PairedMarkers) && nrow(PairedMarkers) > 0) {
        rownames(PairedMarkers) <- NULL
        PairedMarkers[, "group1"] <- factor(PairedMarkers[, "group1"], levels = levels(cell_group))
        PairedMarkers[, "test_group_number"] <- as.integer(table(PairedMarkers[["gene"]])[PairedMarkers[, "gene"]])
        PairedMarkersMatrix <- as.data.frame.matrix(table(PairedMarkers[, c("gene", "group1")]))
        PairedMarkers[, "test_group"] <- apply(PairedMarkersMatrix, 1, function(x) {
          paste0(colnames(PairedMarkersMatrix)[x > 0], collapse = ";")
        })[PairedMarkers[, "gene"]]
        srt@tools[[paste0("DEtest_", group_by)]][[paste0("PairedMarkers_", test.use)]] <- PairedMarkers
        srt@tools[[paste0("DEtest_", group_by)]][[paste0("PairedMarkersMatrix_", test.use)]] <- PairedMarkersMatrix
      } else {
        warning("No markers found.", immediate. = TRUE)
        srt@tools[[paste0("DEtest_", group_by)]][[paste0("PairedMarkers_", test.use)]] <- data.frame()
        srt@tools[[paste0("DEtest_", group_by)]][[paste0("PairedMarkersMatrix_", test.use)]] <- NULL
      }
    }

    if (markers_type == "conserved") {
      ConservedMarkers <- bplapply(levels(cell_group), FUN = function(group) {
        cells.1 <- names(cell_group)[which(cell_group == group)]
        cells.2 <- names(cell_group)[which(cell_group != group)]
        # print(paste0(group," cells.1:",length(cells.1)," cells.2:",length(cells.2)))
        if (length(cells.1) < 3 || length(cells.2) < 3) {
          return(NULL)
        } else {
          args1[["cells.1"]] <- cells.1
          args1[["cells.2"]] <- cells.2
          args1[["object"]] <- srt
          args1[["assay"]] <- assay
          args1[["grouping.var"]] <- grouping.var
          args1[["meta.method"]] <- meta.method
          markers <- do.call(FindConservedMarkers2, args1)
          if (!is.null(markers) && nrow(markers) > 0) {
            markers[, "gene"] <- rownames(markers)
            markers[, "group1"] <- as.character(group)
            markers[, "group2"] <- "others"
            if ("p_val" %in% colnames(markers)) {
              markers[, "p_val_adj"] <- p.adjust(markers[, "p_val"], method = p.adjust.method)
            }
            return(markers)
          } else {
            return(NULL)
          }
        }
      }, BPPARAM = BPPARAM)
      ConservedMarkers <- do.call(rbind.data.frame, lapply(ConservedMarkers, function(x) x[, c("avg_log2FC", "pct.1", "pct.2", "max_pval", "p_val", "p_val_adj", "gene", "group1", "group2")]))
      if (!is.null(ConservedMarkers) && nrow(ConservedMarkers) > 0) {
        rownames(ConservedMarkers) <- NULL
        ConservedMarkers[, "group1"] <- factor(ConservedMarkers[, "group1"], levels = levels(cell_group))
        ConservedMarkers[, "test_group_number"] <- as.integer(table(ConservedMarkers[["gene"]])[ConservedMarkers[, "gene"]])
        ConservedMarkersMatrix <- as.data.frame.matrix(table(ConservedMarkers[, c("gene", "group1")]))
        ConservedMarkers[, "test_group"] <- apply(ConservedMarkersMatrix, 1, function(x) {
          paste0(colnames(ConservedMarkersMatrix)[x > 0], collapse = ";")
        })[ConservedMarkers[, "gene"]]
        ConservedMarkers <- ConservedMarkers[, c("avg_log2FC", "pct.1", "pct.2", "max_pval", "p_val", "p_val_adj", "gene", "group1", "group2", "test_group_number", "test_group")]
        srt@tools[[paste0("DEtest_", group_by)]][[paste0("ConservedMarkers_", test.use)]] <- ConservedMarkers
      } else {
        warning("No markers found.", immediate. = TRUE)
        srt@tools[[paste0("DEtest_", group_by)]][[paste0("ConservedMarkers_", test.use)]] <- data.frame()
      }
    }

    if (markers_type == "disturbed") {
      sub_BPPARAM <- SerialParam()
      bpprogressbar(sub_BPPARAM) <- FALSE
      DisturbedMarkers <- bplapply(levels(cell_group), FUN = function(group) {
        cells.1 <- names(cell_group)[which(cell_group == group)]
        srt_tmp <- srt
        srt_tmp[[grouping.var, drop = TRUE]][setdiff(colnames(srt_tmp), cells.1)] <- NA
        if (length(na.omit(unique(srt_tmp[[grouping.var, drop = TRUE]]))) < 2) {
          return(NULL)
        } else {
          srt_tmp <- RunDEtest(
            srt = srt_tmp, assay = assay, slot = slot,
            group_by = grouping.var,
            markers_type = "all",
            features = features,
            test.use = test.use,
            fc.threshold = fc.threshold,
            base = base,
            min.pct = min.pct,
            min.diff.pct = min.diff.pct,
            max.cells.per.ident = max.cells.per.ident,
            min.cells.feature = min.cells.feature,
            min.cells.group = min.cells.group,
            latent.vars = latent.vars,
            only.pos = only.pos,
            norm.method = norm.method,
            p.adjust.method = p.adjust.method,
            pseudocount.use = pseudocount.use,
            mean.fxn = mean.fxn,
            BPPARAM = sub_BPPARAM,
            seed = seed,
            verbose = FALSE,
            ...
          )
          markers <- srt_tmp@tools[[paste0("DEtest_", grouping.var)]][[paste0("AllMarkers_", test.use)]]
          if (!is.null(markers) && nrow(markers) > 0) {
            colnames(markers) <- gsub("group", "var", colnames(markers))
            markers[["group1"]] <- as.character(group)
            return(markers)
          } else {
            return(NULL)
          }
        }
      }, BPPARAM = BPPARAM)
      DisturbedMarkers <- do.call(rbind.data.frame, DisturbedMarkers)
      if (!is.null(DisturbedMarkers) && nrow(DisturbedMarkers) > 0) {
        rownames(DisturbedMarkers) <- NULL
        DisturbedMarkers[, "group1"] <- factor(DisturbedMarkers[, "group1"], levels = levels(cell_group))
        DisturbedMarkers[, "test_group_number"] <- as.integer(table(unique(DisturbedMarkers[, c("gene", "group1")])[["gene"]])[DisturbedMarkers[, "gene"]])
        DisturbedMarkersMatrix <- as.data.frame.matrix(table(DisturbedMarkers[, c("gene", "group1")]))
        DisturbedMarkers[, "test_group"] <- apply(DisturbedMarkersMatrix, 1, function(x) {
          paste0(colnames(DisturbedMarkersMatrix)[x > 0], collapse = ";")
        })[DisturbedMarkers[, "gene"]]
        srt@tools[[paste0("DEtest_", group_by)]][[paste0("DisturbedMarkers_", test.use)]] <- DisturbedMarkers
      } else {
        warning("No markers found.", immediate. = TRUE)
        srt@tools[[paste0("DEtest_", group_by)]][[paste0("DisturbedMarkers_", test.use)]] <- data.frame()
      }
    }
  }
  time_end <- Sys.time()
  if (verbose) {
    message(paste0("[", time_end, "] ", "DEtest done"))
    message("Elapsed time:", format(round(difftime(time_end, time_start), 2), format = "%Y-%m-%d %H:%M:%S"))
  }
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

