select_top10_paths <- function(df, top_n = 5, sig_only = TRUE) {
  d <- df %>% filter(is.finite(Log2FC))
  
  pick_side <- function(dat, side = c("state3", "state1")) {
    side <- match.arg(side)
    if (side == "state3") {
      cand <- dat %>% arrange(desc(Log2FC))
      sig  <- cand %>% filter(p_adj < 0.05)
      top  <- if (sig_only) sig else cand
      top  <- top %>% slice_head(n = top_n) %>% pull(Pathway)
      if (length(top) < top_n) {
        top <- unique(c(top, cand$Pathway))[seq_len(min(top_n, nrow(cand)))]
      }
      top
    } else {
      cand <- dat %>% arrange(Log2FC)
      sig  <- cand %>% filter(p_adj < 0.05)
      top  <- if (sig_only) sig else cand
      top  <- top %>% slice_head(n = top_n) %>% pull(Pathway)
      if (length(top) < top_n) {
        top <- unique(c(top, cand$Pathway))[seq_len(min(top_n, nrow(cand)))]
      }
      top
    }
  }
  
  unique(c(pick_side(d, "state3"), pick_side(d, "state1")))
}
