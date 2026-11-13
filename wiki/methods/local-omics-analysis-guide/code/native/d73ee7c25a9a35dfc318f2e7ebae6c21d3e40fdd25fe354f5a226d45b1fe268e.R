wf_set_seed <- function(cfg) set.seed(cfg$analysis$seeds$global %||% 1L)
