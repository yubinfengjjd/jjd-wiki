# SCP 0.5.6 commit b9b0eb7a | source R/SCP-plot.R:14698-14706
# sha256(func-block)=239d46399405e0f18ba94b0eacfaf378d6a98d0b04d597097e3a5d17350ecdff
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
patchworkGrob <- function(x, BPPARAM = BiocParallel::SerialParam(), ...) {
  annotation <- modifyList(patchwork:::default_annotation, x$patches$annotation[!vapply(x$patches$annotation, is.null, logical(1))])
  x <- patchwork:::recurse_tags(x, annotation$tag_levels, annotation$tag_prefix, annotation$tag_suffix, annotation$tag_sep)$patches
  plot <- patchwork:::get_patches(x)
  gtable <- build_patchwork(plot, BPPARAM = BPPARAM)
  gtable <- patchwork:::annotate_table(gtable, annotation)
  class(gtable) <- setdiff(class(gtable), "gtable_patchwork")
  gtable
}
