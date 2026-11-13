wf_project_palette <- function(n, palette_name = "npg") {
  vals <- switch(
    palette_name,
    d3 = ggsci::pal_d3("category20")(max(n, 3)),
    aaas = ggsci::pal_aaas("default")(max(n, 3)),
    lancet = ggsci::pal_lancet("lanonc")(max(n, 3)),
    npg = ggsci::pal_npg("nrc")(max(n, 10)),
    ggsci::pal_npg("nrc")(max(n, 10))
  )
  if (length(vals) < n) vals <- rep(vals, length.out = n)
  vals[seq_len(n)]
}
