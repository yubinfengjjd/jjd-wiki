ExtractVar <- function(fit){
  Feature <- quiet(switch(
    EXPR = class(fit)[1],
    "lognet" = rownames(coef(fit))[which(coef(fit)[, 1]!=0)], # 本身没有筛选变量的功能，但是可以舍去模型中系数为0的变量
    "glm" = names(coef(fit)), # 逐步回归可以对变量进行筛选
    "svm.formula" = fit$subFeature, # SVM对变量没有筛选功能，所以默认使用所有变量
    "train" = fit$coefnames, # LDA不能筛选变量，所以默认使用所有变量
    "glmboost" = names(coef(fit)[abs(coef(fit))>0]), # glmboost同样不具备筛选变量的功能，因此舍去模型中系数为0的变量
    "plsRglmmodel" = rownames(fit$Coeffs)[fit$Coeffs!=0], # plsRglmmodel同样不具备筛选变量的功能，因此舍去模型中系数为0的变量
    "rfsrc" = var.select(fit, verbose = F)$topvars, # rfsrc可以对变量进行筛选
    "gbm" = rownames(summary.gbm(fit, plotit = F))[summary.gbm(fit, plotit = F)$rel.inf>0], # gbm通过舍去重要性为0的变量来进行变量筛选
    "xgb.Booster" = fit$subFeature, # xgboost没有筛选变量的能力， 默认使用所有变量
    "naiveBayes" = fit$subFeature # naiveBayes没有筛选变量的能力，默认使用所有变量
    # "drf" = fit$subFeature # drf自带的变量系数提取函数会输出NA，因此默认使用所有变量
  ))
  
  Feature <- setdiff(Feature, c("(Intercept)", "Intercept"))
  return(Feature)
}
