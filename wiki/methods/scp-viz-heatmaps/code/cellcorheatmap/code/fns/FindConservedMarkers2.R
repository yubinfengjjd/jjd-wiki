# SCP 0.5.6 commit b9b0eb7a | source R/SCP-analysis.R:1070-1218
# sha256(func-block)=cd698214d44cfe536513319af8106c01f8c7001c71c133e4fde32ab51f26f7bc
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
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
