seurat_to_monocle <- function(otherCDS, assay, slot, lowerDetectionLimit = 0, import_all = FALSE) {
	if(class(otherCDS)[1] == 'Seurat') {
		requireNamespace("Seurat")
		data <- GetAssayData(otherCDS, assay = assay, slot = slot)
		data <- data[rowSums(as.matrix(data)) != 0,]
		pd <- new("AnnotatedDataFrame", data = otherCDS@meta.data)
		fData <- data.frame(gene_short_name = row.names(data), row.names = row.names(data))
		fd <- new("AnnotatedDataFrame", data = fData)
		if(all(data == floor(data))) {
			expressionFamily <- negbinomial.size()
		} else if(any(data < 0)){
			expressionFamily <- uninormal()
		} else {
			expressionFamily <- tobit()
		}
		valid_data <- data[, row.names(pd)]
		monocle_cds <- newCellDataSet(data,
																	phenoData = pd, 
																	featureData = fd,
																	lowerDetectionLimit=lowerDetectionLimit,
																	expressionFamily=expressionFamily)
		if(import_all) {
			if("Monocle" %in% names(otherCDS@misc)) {
				otherCDS@misc$Monocle@auxClusteringData$seurat <- NULL
				otherCDS@misc$Monocle@auxClusteringData$scran <- NULL
				monocle_cds <- otherCDS@misc$Monocle
				mist_list <- otherCDS
			} else {
				mist_list <- otherCDS
			}
		} else {
			mist_list <- list()
		} 
	} 
	return(monocle_cds)
}
