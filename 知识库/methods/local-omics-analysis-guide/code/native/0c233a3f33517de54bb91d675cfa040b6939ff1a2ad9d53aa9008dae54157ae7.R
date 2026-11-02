triangle <- function(pairs, type = "upper") {
	x = c(0, 0, 1)
	y = c(0, 1, 1)
	if (type == "lower") {
		x = c(0, 1, 1)
		y = c(0, 0, 1)
	}
	mat = do.call(
		rbind,
		apply(pairs, 1, function (row) {
			a = row[1]
			b = row[2]
			data.frame(
				x = x + a - 0.5,
				y = y + b - 0.5,
				group = paste(a, b, sep = "-")
			)
		}))
	return(mat)
}
