PredictClass <- function(fit, new_data){
  new_data <- new_data[, fit$subFeature]
  label <- quiet(switch(
    EXPR = class(fit)[1],
    "lognet"      = predict(fit, type = 'class', as.matrix(new_data)),
    "glm"         = ifelse(test = predict(fit, type = 'response', as.data.frame(new_data))>0.5,
                           yes = "1", no = "0"),
    "svm.formula" = predict(fit, as.data.frame(new_data), decision.values = T),
    "train"       = predict(fit, new_data, type = "raw"),
    "glmboost"    = predict(fit, type = "class", as.data.frame(new_data)),
    "plsRglmmodel" = ifelse(test = predict(fit, type = 'response', as.data.frame(new_data))>0.5,
                            yes = "1", no = "0"),
    "rfsrc"        = predict(fit, as.data.frame(new_data))$class,
    "gbm"          = ifelse(test = predict(fit, type = 'response', as.data.frame(new_data))>0.5,
                            yes = "1", no = "0"),
    "xgb.Booster" = ifelse(test = predict(fit, as.matrix(new_data))>0.5,
                           yes = "1", no = "0"),
    "naiveBayes" = predict(object = fit, type = "class", newdata = new_data)
    # "drf" = predict(fit, functional = "mean", as.matrix(new_data))$mean
  ))
  label = as.character(as.vector(label))
  names(label) = rownames(new_data)
  return(label)
}
