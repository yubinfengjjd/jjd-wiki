f <- "E:/research-wiki/知识库/methods/scp-local-source/source/R/SCP-cellqc.R"
ex <- parse(f, keep.source=TRUE)
cat("exprs", length(ex), "\n")
for (e in ex[1:8]) {
  cat("head:", if(is.call(e)) paste(class(e[[1]]), as.character(e[[1]])[1]) else class(e), "| name:", if(is.call(e)&&is.name(e[[2]])) as.character(e[[2]]) else "NA", "| srcref:", !is.null(attr(e,"srcref")), "\n")
}
cat("srcfile:", !is.null(attr(ex,"srcref")), "\n")
