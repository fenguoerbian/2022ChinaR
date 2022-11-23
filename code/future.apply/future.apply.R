library(future.apply)    # default plan is sequential
n <- 16
x <- rnorm(n)
lapply(1 : 5, function(id){
    print(paste("id = ", id, sep = ""))
    Sys.sleep(0.5)
    sum(x[1 : id])
})

future_lapply(1 : 5, function(id){
    print(paste("id = ", id, sep = ""))
    Sys.sleep(0.5)
    sum(x[1 : id])
})

tmp <- function(n){
    res <- future_lapply(1 : 5, function(id){
        Sys.sleep(0.5)
        sum(x[1 : id])
    })
    return(res)
}
tmp(n)


plan(cluster)
lapply(1 : 5, function(id){
    print(paste("id = ", id, sep = ""))
    Sys.sleep(0.5)
    sum(x[1 : id])
})

future_lapply(1 : 5, function(id){
    print(paste("id = ", id, sep = ""))
    Sys.sleep(0.5)
    sum(x[1 : id])
})
tmp(n)

