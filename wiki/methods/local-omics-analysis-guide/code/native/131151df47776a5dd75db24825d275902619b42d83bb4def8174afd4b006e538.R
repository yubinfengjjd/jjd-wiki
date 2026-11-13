RunglmBoost <- function(Train_set, Train_label, mode, classVar){
  data <- cbind(Train_set, Train_label[classVar])
  data[[classVar]] <- as.factor(data[[classVar]])
  fit <- glmboost(eval(parse(text = paste(classVar, "~."))),
                  data = data,
                  family = Binomial())
  
  cvm <- cvrisk(fit, papply = lapply,
                folds = cv(model.weights(fit), type = "kfold"))
  fit <- glmboost(eval(parse(text = paste(classVar, "~."))),
                  data = data,
                  family = Binomial(), 
                  control = boost_control(mstop = max(mstop(cvm), 40)))
  
  fit$subFeature = colnames(Train_set)
  if (mode == "Model") return(fit)
  if (mode == "Variable") return(ExtractVar(fit))
}
