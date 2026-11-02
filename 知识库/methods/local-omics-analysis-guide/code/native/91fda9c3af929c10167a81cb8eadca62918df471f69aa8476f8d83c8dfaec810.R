RunXGBoost <- function(Train_set, Train_label, mode, classVar){
  indexes = createFolds(Train_label[[classVar]], k = 5, list=T)
  CV <- unlist(lapply(indexes, function(pt){
    dtrain = xgb.DMatrix(data = Train_set[-pt, ],
                         label = Train_label[-pt, ])
    dtest = xgb.DMatrix(data = Train_set[pt, ],
                        label = Train_label[pt, ])
    watchlist <- list(train=dtrain, test=dtest)

    bst <- xgb.train(data=dtrain,
                     max.depth=2, eta=1, nthread = 2, nrounds=10,
                     watchlist=watchlist,
                     objective = "binary:logistic", verbose = F)
    which.min(bst$evaluation_log$test_logloss)
  }))

  nround <- as.numeric(names(which.max(table(CV))))
  fit <- xgboost(data = Train_set,
                 label = Train_label[[classVar]],
                 max.depth = 2, eta = 1, nthread = 2, nrounds = nround,
                 objective = "binary:logistic", verbose = F)
  fit$subFeature = colnames(Train_set)

  if (mode == "Model") return(fit)
  if (mode == "Variable") return(ExtractVar(fit))
}
