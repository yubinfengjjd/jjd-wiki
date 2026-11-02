extract_tables_from_cellchat <- function(cellchat, scenario_id) {
  comm_tbl <- subsetCommunication(cellchat, slot.name = "net", thresh = 0.05)
  path_tbl <- subsetCommunication(cellchat, slot.name = "netP", thresh = 0.05)
  if (is.null(comm_tbl) || !nrow(comm_tbl)) comm_tbl <- tibble()
  if (is.null(path_tbl) || !nrow(path_tbl)) path_tbl <- tibble()
  lr_tbl <- if (nrow(comm_tbl)) {
    comm_tbl %>%
      group_by(pathway_name, interaction_name, ligand, receptor) %>%
      summarise(
        n_edges = n(),
        total_prob = sum(prob, na.rm = TRUE),
        mean_prob = mean(prob, na.rm = TRUE),
        min_pval = min(pval, na.rm = TRUE),
        .groups = "drop"
      ) %>%
      arrange(desc(total_prob), min_pval)
  } else {
    tibble()
  }
  path_total_tbl <- if (nrow(path_tbl)) {
    path_tbl %>%
      group_by(pathway_name) %>%
      summarise(
        n_edges = n(),
        total_prob = sum(prob, na.rm = TRUE),
        mean_prob = mean(prob, na.rm = TRUE),
        .groups = "drop"
      ) %>%
      arrange(desc(total_prob))
  } else {
    tibble()
  }
  summary_tbl <- tibble(
    scenario_id = scenario_id,
    n_groups = length(levels(cellchat@idents)),
    n_significant_edges = nrow(comm_tbl),
    n_significant_pathway_edges = nrow(path_tbl),
    n_lr_pairs = nrow(lr_tbl),
    total_probability = if (nrow(comm_tbl)) sum(comm_tbl$prob, na.rm = TRUE) else 0,
    high_outgoing_probability = if (nrow(comm_tbl)) sum(comm_tbl$prob[comm_tbl$source == "EpiSpot_UBE2L6_high"], na.rm = TRUE) else 0,
    low_outgoing_probability = if (nrow(comm_tbl)) sum(comm_tbl$prob[comm_tbl$source == "EpiSpot_UBE2L6_low"], na.rm = TRUE) else 0
  )
  list(comm = comm_tbl, pathway = path_tbl, pathway_total = path_total_tbl, lr_total = lr_tbl, summary = summary_tbl)
}
