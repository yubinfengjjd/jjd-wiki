build_high_low_diff_table <- function(comm_tbl) {
  if (!nrow(comm_tbl)) return(tibble())
  high_out <- comm_tbl %>% filter(source == "EpiSpot_UBE2L6_high") %>% transmute(direction = "outgoing", partner = target, pathway_name, interaction_name, ligand, receptor, high_prob = prob, high_pval = pval)
  low_out <- comm_tbl %>% filter(source == "EpiSpot_UBE2L6_low") %>% transmute(direction = "outgoing", partner = target, pathway_name, interaction_name, ligand, receptor, low_prob = prob, low_pval = pval)
  high_in <- comm_tbl %>% filter(target == "EpiSpot_UBE2L6_high") %>% transmute(direction = "incoming", partner = source, pathway_name, interaction_name, ligand, receptor, high_prob = prob, high_pval = pval)
  low_in <- comm_tbl %>% filter(target == "EpiSpot_UBE2L6_low") %>% transmute(direction = "incoming", partner = source, pathway_name, interaction_name, ligand, receptor, low_prob = prob, low_pval = pval)
  full_join(bind_rows(high_out, high_in), bind_rows(low_out, low_in), by = c("direction", "partner", "pathway_name", "interaction_name", "ligand", "receptor")) %>%
    mutate(
      high_prob = coalesce(high_prob, 0),
      low_prob = coalesce(low_prob, 0),
      delta_prob = high_prob - low_prob,
      high_pval = coalesce(high_pval, 1),
      low_pval = coalesce(low_pval, 1),
      stronger_state = case_when(delta_prob > 0 ~ "high", delta_prob < 0 ~ "low", TRUE ~ "equal")
    ) %>%
    arrange(desc(abs(delta_prob)), pmin(high_pval, low_pval))
}
