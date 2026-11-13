# SCP 0.5.6 commit b9b0eb7a | source R/SCP-plot.R:16-60
# sha256(func-block)=0a26d2b3dc57f46928714d1cac486c0cf3341b346b8fe1bda5f147733e3eac39
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
theme_scp <- function(aspect.ratio = NULL, base_size = 12, ...) {
  text_size_scale <- base_size / 12
  args1 <- list(
    aspect.ratio = aspect.ratio,
    text = element_text(size = 12 * text_size_scale, color = "black"),
    plot.title = element_text(size = 14 * text_size_scale, colour = "black", vjust = 1),
    plot.subtitle = element_text(size = 13 * text_size_scale, hjust = 0, margin = margin(b = 3)),
    plot.background = element_rect(fill = "white", color = "white"),
    axis.line = element_blank(),
    axis.title = element_text(size = 13 * text_size_scale, colour = "black"),
    axis.text = element_text(size = 12 * text_size_scale, colour = "black"),
    strip.text = element_text(size = 12.5 * text_size_scale, colour = "black", hjust = 0.5, margin = margin(3, 3, 3, 3)),
    strip.background = element_rect(fill = "transparent", linetype = 0),
    strip.switch.pad.grid = unit(-1, "pt"),
    strip.switch.pad.wrap = unit(-1, "pt"),
    strip.placement = "outside",
    legend.title = element_text(size = 12 * text_size_scale, colour = "black", hjust = 0),
    legend.text = element_text(size = 11 * text_size_scale, colour = "black"),
    legend.key = element_rect(fill = "transparent", color = "transparent"),
    legend.key.size = unit(10, "pt"),
    legend.background = element_blank(),
    panel.background = element_rect(fill = "white", color = "white"),
    panel.border = element_rect(fill = "transparent", colour = "black", linewidth = 1)
  )
  args2 <- as.list(match.call())[-1]
  call.envir <- parent.frame(1)
  args2 <- lapply(args2, function(arg) {
    if (is.symbol(arg)) {
      eval(arg, envir = call.envir)
    } else if (is.call(arg)) {
      eval(arg, envir = call.envir)
    } else {
      arg
    }
  })
  for (n in names(args2)) {
    args1[[n]] <- args2[[n]]
  }
  args <- args1[names(args1) %in% formalArgs(theme)]
  out <- do.call(
    what = theme,
    args = args
  )
  return(out)
}
