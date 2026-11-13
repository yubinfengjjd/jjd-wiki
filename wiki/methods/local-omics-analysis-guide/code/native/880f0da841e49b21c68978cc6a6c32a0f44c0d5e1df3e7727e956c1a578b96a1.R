is_hit <- function(nm, id){
	nm_hit <- !is.na(nm) && str_detect(nm, name_regex)
	id_hit <- !is.na(id) && str_detect(id, paste(lactyl_kegg_ids, collapse="|"))
	nm_hit || id_hit
}
