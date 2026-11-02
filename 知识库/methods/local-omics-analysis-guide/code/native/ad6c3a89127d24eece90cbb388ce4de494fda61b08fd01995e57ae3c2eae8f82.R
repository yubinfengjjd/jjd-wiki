read_folder_gmt <- function(folder_path){
	gmt_files <- list.files(folder_path, pattern = "\\.gmt$", full.names = TRUE)
	gene_sets <- list()
	for(f in gmt_files){
		gmt <- getGmt(f)
		set_names <- names(geneIds(gmt))
		genes <- geneIds(gmt)
		for(i in seq_along(set_names)){
			new_name <- paste0(tools::file_path_sans_ext(basename(f)), 
												 "_", set_names[i])
			gene_sets[[new_name]] <- unique(genes[[i]])
		}
	}
	return(unique(unlist(gene_sets)))  # 返回合并后的唯一基因列表
}
