args<-commandArgs(TRUE)
x<-jsonlite::read_json(args[1],simplifyVector=FALSE)
find_call<-function(e,fn) {
 if(!is.call(e))return(NULL)
 if(is.symbol(e[[1]]) && identical(as.character(e[[1]]),fn))return(e)
 if(length(e)>1)for(i in 2:length(e)){r<-find_call(e[[i]],fn);if(!is.null(r))return(r)}
 NULL
}
r<-list()
for(fn in names(x)) {
 r[[fn]]<-tryCatch({
   expr<-parse(text=x[[fn]])
   call<-NULL
   for(e in expr){call<-find_call(e,fn);if(!is.null(call))break}
   if(is.null(call))stop('documented function not found in parsed example')
   a<-as.list(call)[-1]
   list(named_args=names(a)[nzchar(names(a))])
 },error=function(e)list(parse_error=conditionMessage(e)))
}
jsonlite::write_json(r,args[2],auto_unbox=FALSE,pretty=TRUE)
