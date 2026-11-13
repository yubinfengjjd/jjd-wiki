guess_cat <- function(x){
	if (grepl("^C\\d{5}$", x)) return("compound")
	if (grepl("^R\\d{5}$", x)) return("reaction")
	if (grepl("^M\\d{5}$", x)) return("module")
	if (grepl("^\\d+\\.\\d+\\.\\d+\\.\\d+$", x)) return("enzyme")
	if (grepl("^(map|hsa|mmu|rno|ko)\\d{5}$", x)) return("pathway")
	return(NA_character_)
}
