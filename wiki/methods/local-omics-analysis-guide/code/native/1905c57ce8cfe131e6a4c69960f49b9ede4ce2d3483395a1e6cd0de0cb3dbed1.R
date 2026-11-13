CalPredictScore <- function(fit, new_data, type = "lp"){
  new_data <- new_data[, fit$subFeature]
  RS <- quiet(switch(
    EXPR = class(fit)[1],
    "lognet"      = predict(fit, type = 'response', as.matrix(new_data)), # response
    "glm"         = predict(fit, type = 'response', as.data.frame(new_data)), # response
    "svm.formula" = predict(fit, as.data.frame(new_data), probability = T), # 
    "train"       = predict(fit, new_data, type = "prob")[[2]],
    "glmboost"    = predict(fit, type = "response", as.data.frame(new_data)), # response
    "plsRglmmodel" = predict(fit, type = "response", as.data.frame(new_data)), # response
    "rfsrc"        = predict(fit, as.data.frame(new_data))$predicted[, "1"],
    "gbm"          = predict(fit, type = 'response', as.data.frame(new_data)), # response
    "xgb.Booster" = predict(fit, as.matrix(new_data)),
    "naiveBayes" = predict(object = fit, type = "raw", newdata = new_data)[, "1"]
    # "drf" = predict(fit, functional = "mean", as.matrix(new_data))$mean
  ))
  RS = as.numeric(as.vector(RS))
  names(RS) = rownames(new_data)
  return(RS)
}
