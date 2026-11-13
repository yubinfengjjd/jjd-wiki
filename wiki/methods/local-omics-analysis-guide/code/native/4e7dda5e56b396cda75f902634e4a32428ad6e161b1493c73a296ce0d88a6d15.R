Addsingscore<-function(oc,signatures,seed=123,assay=null,slot="data"){
	set.seed(seed)
	if(is.null(assay)){
		assay=Seurat::DefaultAssay(oc)
	}
	matrix=Seurat::GetAssayData(object=oc,slot=slot,assay=assay)

	markers=signatures
	h.gsets.list=markers %>% purrr::compact()

	singscore.rank=singscore::rankGenes(as.data.frame(matrix))
	#calculate separately
	singscore.scores=list()
	for (i in seq_along(h.gsets.list)){
		if (any(stringr::str_detect(h.gsets.list[[i]],pattern = "\\+$|-$"))){
			h.gsets.list.positive=stringr::str_match(h.gsets.list[[i]],pattern="(.+)\\+")[,2] %>% purrr::discard(is.na)
			h.gsets.list.negative=stringr::str_match(h.gsets.list[[i]],pattern="(.+)-")[,2] %>% purrr::discard(is.na)
			if(length(h.gsets.list.positive)==0){
				singscore.scores[[i]]=singscore::simpleScore(singscore.rank,upSet=h.gsets.list.negative,centerScore=F)
			}
			if(length(h.gsets.list.negative)==0){
				singscore.scores[[i]]=singscore::simpleScore(singscore.rank,upSet=h.gsets.list.positive,centerScore=F)
			}
			if((length(h.gsets.list.positive)!=0)&(length(h.gsets.list.negative)!=0)){
				singscore.scores[[i]]=singscore::simpleScore(singscore.rank,upSet=h.gsets.list.positive,downSet=h.gsets.list.negative,centerScore=F)
			}
		}else{
			singscore.scores[[i]]=singscore::simpleScore(singscore.rank,upSet=h.gsets.list[[i]],centerScore=F)
		}
		TotalScore=NULL
		singscore.scores[[i]]=singscore.scores[[i]] %>%
			dplyr::select(TotalScore) %>%
			magrittr::set_colnames(names(h.gsets.list)[i])}
	names(singscore.scores)=names(h.gsets.list)
	singscore.scores=do.call(cbind,singscore.scores)
	oc=Seurat::AddMetaData(oc,as.data.frame(singscore.scores))
	return(oc)
}
