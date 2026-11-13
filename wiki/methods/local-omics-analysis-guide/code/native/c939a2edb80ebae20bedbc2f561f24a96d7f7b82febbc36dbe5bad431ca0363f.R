RunRF <- function(Train_set, Train_label, mode, classVar){
  rf_nodesize = 5 # may modify
  Train_label[[classVar]] <- as.factor(Train_label[[classVar]])
  fit <- rfsrc(formula = formula(paste0(classVar, "~.")),
               data = cbind(Train_set, Train_label[classVar]),
               ntree = 1000, nodesize = rf_nodesize,
               importance = T,
               proximity = T,
               forest = T)
  fit$subFeature = colnames(Train_set)
  if (mode == "Model") return(fit)
  if (mode == "Variable") return(ExtractVar(fit))
}
