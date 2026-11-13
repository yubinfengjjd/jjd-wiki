pick_col <- function(df, candidates, default = NULL) {
	hit <- intersect(candidates, names(df))
	if (length(hit)) hit[1] else default
}
