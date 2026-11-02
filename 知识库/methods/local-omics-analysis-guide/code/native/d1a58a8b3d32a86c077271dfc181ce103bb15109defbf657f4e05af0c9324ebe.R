ExtractVar <- function(fit){
  Feature <- quiet(switch(
    EXPR = class(fit)[1],
    "lognet" = rownames(coef(fit))[which(coef(fit)[, 1]!=0)],
    "glm" = names(coef(fit)),
    "svm.formula" = fit$subFeature,
    "train" = fit$coefnames,
    "glmboost" = names(coef(fit)[abs(coef(fit))>0]),
    "plsRglmmodel" = rownames(fit$Coeffs)[fit$Coeffs!=0],
    "rfsrc" = var.select(fit, verbose = F)$topvars,
    "gbm" = rownames(summary.gbm(fit, plotit = F))[summary.gbm(fit, plotit = F)$rel.inf>0],
    "xgb.Booster" = fit$subFeature,
    "naiveBayes" = fit$subFeature
  ))

  Feature <- setdiff(Feature, c("(Intercept)", "Intercept"))
  return(Feature)
}
