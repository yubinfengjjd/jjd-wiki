# CellChat-style ligand-receptor communication aggregation, pathway ranking, and sender-receiver matrix.
# Adapted from Cai et al., npj Precision Oncology 2026 (05_crosstalk_metabolism.R).

run_cellchat_lr_inference <- function(
  lr_df,
  pval_cutoff = 0.05,
  min_prob = 0
) {
  req <- c("source", "target", "ligand", "receptor", "pathway_name", "prob", "pval")
  missing <- setdiff(req, colnames(lr_df))
  if (length(missing) > 0L) {
    stop("Missing required LR columns: ", paste(missing, collapse = ", "))
  }

  df <- lr_df[!is.na(lr_df$prob) & !is.na(lr_df$pval), , drop = FALSE]
  df$prob <- as.numeric(df$prob)
  df$pval <- as.numeric(df$pval)
  sig <- df[df$pval < pval_cutoff & df$prob > min_prob, , drop = FALSE]
  if (nrow(sig) == 0L) {
    stop("No significant L-R interactions remained after filtering")
  }

  # 1. Pathway-level communication probability aggregation & ranking
  pw_split <- split(sig, sig$pathway_name)
  pathway_ranking <- do.call(rbind, lapply(names(pw_split), function(pw) {
    sub <- pw_split[[pw]]
    data.frame(
      pathway_name = pw,
      total_prob = round(sum(sub$prob), 6),
      mean_prob = round(mean(sub$prob), 6),
      max_prob = round(max(sub$prob), 6),
      n_edges = nrow(sub),
      n_unique_lr = length(unique(paste(sub$ligand, sub$receptor, sep = "_"))),
      n_sources = length(unique(sub$source)),
      n_targets = length(unique(sub$target)),
      stringsAsFactors = FALSE
    )
  }))
  pathway_ranking <- pathway_ranking[order(-pathway_ranking$total_prob, -pathway_ranking$n_edges), , drop = FALSE]
  pathway_ranking$rank <- seq_len(nrow(pathway_ranking))
  rownames(pathway_ranking) <- NULL

  # 2. Directed sender -> receiver interaction count and total probability matrix
  pair_key <- paste(sig$source, sig$target, sep = "||")
  pair_split <- split(sig, pair_key)
  sender_receiver <- do.call(rbind, lapply(pair_split, function(sub) {
    data.frame(
      source = as.character(sub$source[1]),
      target = as.character(sub$target[1]),
      n_interactions = nrow(sub),
      total_prob = round(sum(sub$prob), 6),
      mean_prob = round(mean(sub$prob), 6),
      top_pathway = names(sort(table(sub$pathway_name), decreasing = TRUE))[1],
      stringsAsFactors = FALSE
    )
  }))
  sender_receiver <- sender_receiver[order(-sender_receiver$n_interactions, -sender_receiver$total_prob), , drop = FALSE]
  rownames(sender_receiver) <- NULL

  count_tab <- stats::xtabs(n_interactions ~ source + target, data = sender_receiver)
  count_matrix <- data.frame(
    source = rownames(count_tab),
    as.data.frame.matrix(count_tab),
    check.names = FALSE,
    stringsAsFactors = FALSE
  )

  # 3. Outgoing / incoming signaling hub strength per cell type
  all_cells <- sort(unique(c(as.character(sig$source), as.character(sig$target))))
  out_n <- stats::setNames(integer(length(all_cells)), all_cells)
  in_n <- stats::setNames(integer(length(all_cells)), all_cells)
  out_p <- stats::setNames(numeric(length(all_cells)), all_cells)
  in_p <- stats::setNames(numeric(length(all_cells)), all_cells)
  for (i in seq_len(nrow(sender_receiver))) {
    s <- sender_receiver$source[i]
    t <- sender_receiver$target[i]
    out_n[s] <- out_n[s] + sender_receiver$n_interactions[i]
    in_n[t] <- in_n[t] + sender_receiver$n_interactions[i]
    out_p[s] <- out_p[s] + sender_receiver$total_prob[i]
    in_p[t] <- in_p[t] + sender_receiver$total_prob[i]
  }
  hub_strength <- data.frame(
    cell_type = all_cells,
    outgoing_count = as.integer(out_n),
    incoming_count = as.integer(in_n),
    outgoing_prob = round(as.numeric(out_p), 6),
    incoming_prob = round(as.numeric(in_p), 6),
    stringsAsFactors = FALSE
  )
  hub_strength <- hub_strength[order(-(hub_strength$outgoing_prob + hub_strength$incoming_prob)), , drop = FALSE]
  rownames(hub_strength) <- NULL

  list(
    filtered_lr = sig,
    pathway_ranking = pathway_ranking,
    sender_receiver_long = sender_receiver,
    sender_receiver_matrix = count_matrix,
    hub_strength = hub_strength
  )
}
