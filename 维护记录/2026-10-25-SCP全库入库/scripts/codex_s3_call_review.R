# R language dispatch demonstration only. NOT an SCP/algorithm verification case.
private <- new.env(parent=baseenv())
evalq({
  example_generic <- function(x,...)UseMethod('example_generic',object=x)
  example_generic.default <- function(x,...)length(x)
},private)
by_function <- local({f<-private$example_generic; function(...)do.call(f,list(...))})
by_name <- local({e<-private; function(...)do.call('example_generic',list(...),envir=e)})
by_function_private <- local({f<-private$example_generic;e<-private;function(...)do.call(f,list(...),envir=e)})
show <- function(label,call)tryCatch(cat(label,call,'\n'),error=function(e)cat(label,'ERROR:',conditionMessage(e),'\n'))
show('function-object call',by_function(1:3))
show('named call in private method environment',by_name(1:3))
show('function-object call with explicit private environment',by_function_private(1:3))
