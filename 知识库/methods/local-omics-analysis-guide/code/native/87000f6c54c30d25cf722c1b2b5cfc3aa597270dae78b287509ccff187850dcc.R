recover_rctd_weight_exports <- function() {
  known_weight_cols <- c("B_cells", "Endothelial", "Epithelial", "Fibroblasts", "Macrophage", "Mast_cells", "NKT_cells", "Plasma_cells", "SmoothMuscle", "T_cells")
  recovered_rows <- list()
  for (sample_id in names(objs)) {
    md <- objs[[sample_id]]@meta.data
    cols <- intersect(known_weight_cols, colnames(md))
    if (length(cols) < 3) next
    weight_tbl <- as.matrix(md[, cols, drop = FALSE])
    rs <- rowSums(weight_tbl, na.rm = TRUE)
    keep <- rs > 0
    weight_tbl[keep, ] <- weight_tbl[keep, , drop = FALSE] / rs[keep]
    out_tbl <- tibble(spot = rownames(weight_tbl)) %>% bind_cols(as.data.frame(weight_tbl))
    readr::write_csv(out_tbl, file.path(dir_map$metadata, paste0(sample_id, "_rctd_weight_matrix.csv")))
    recovered_rows[[sample_id]] <- tibble(sample_id = sample_id, weight_columns = paste(cols, collapse = "|"), n_weight_columns = length(cols))
  }
  recovered_tbl <- bind_rows(recovered_rows)
  if (nrow(recovered_tbl)) {
    audit_fix <- audit_tbl %>% select(-weight_columns, -n_weight_columns) %>% left_join(recovered_tbl, by = "sample_id")
    readr::write_csv(audit_fix, file.path(dir_map$audit, "object_audit.csv"))
    summary_path <- file.path(dir_map$summary, "cellchat_rctd_spot_summary.md")
    if (file.exists(summary_path)) {
      txt <- readLines(summary_path, warn = FALSE)
      idx <- grep('^- RCTD weight columns detected:', txt)
      if (length(idx) == 1) {
        all_cols <- unique(unlist(strsplit(paste(recovered_tbl$weight_columns, collapse = "|"), "\\|")))
        txt[idx] <- paste0("- RCTD weight columns detected: ", paste(all_cols, collapse = ", "))
        writeLines(txt, summary_path)
      }
    }
    log_message("Recovered and exported RCTD weight matrices for %d samples", nrow(recovered_tbl))
  }
}
