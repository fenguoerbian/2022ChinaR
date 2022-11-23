library(parallel)


# ------ simple example 1 ------
cls <- makeCluster(4)

# we can split 1 to 100 directly 
idx_split <- clusterSplit(cls, 1 : 100)
res <- parLapply(cls, 
                 idx_split, 
                 function(invec){
                     return(sum(invec))
                 })

sum(unlist(res))

# Or we can just assign job indx
res <- parLapply(cls, 
                 1 : 4, 
                 function(idx){
                     start <- (idx - 1) * 25 + 1
                     stop <- idx * 25
                     invec <- start : stop
                     return(sum(invec))
                 })
sum(unlist(res))

stopCluster(cls)
rm(cls)

# ------ simple example 2 ------
library(mvtnorm)

cls <- makeCluster(4)

my_fun <- function(idx){
    start <- (idx - 1) * 25 + 1
    stop <- idx * 25
    invec <- start : stop
    return(sum(invec))
}

(res <- parLapply(cls, 1 : 4, my_fun))


a <- 25

my_fun2 <- function(idx){
    
    message("just for fun:")
    print(rmvnorm(1, mean = c(0, 0)))
    
    start <- (idx - 1) * a + 1
    stop <- idx * a
    invec <- start : stop
    return(sum(invec))
}

my_fun2(4)

res <- parLapply(cls, 1 : 4, my_fun2)    # error, could not find "rmvnorm"!


clusterEvalQ(cls, search())

clusterEvalQ(cls, {
    library(mvtnorm)
    search()
})

res <- parLapply(cls, 1 : 4, my_fun2)    # error, object "a" not found!


clusterExport(cls, varlist = "a")

res <- parLapply(cls, 1 : 4, my_fun2)    # OK, but the `message` and `print` is missing!
