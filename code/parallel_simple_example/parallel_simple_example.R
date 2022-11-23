library(parallel)
a <- rnorm(12)
slow_function <- function(invec){
    res <- 0
    for(i in 1 : length(invec)){
        Sys.sleep(0.1)
        res <- res + invec[i]
    }
    return(res)
}

cls <- makeCluster(4)
ind_seq <- clusterSplit(cls, a)
clusterExport(cls, varlist = "slow_function")
res_par <- parSapply(cls, ind_seq, slow_function)
res <- sum(res_par)


library(microbenchmark)
microbenchmark("single" = slow_function(a), 
               "par" = {
                   res_par <- parSapply(cls, ind_seq, slow_function)
                   res <- sum(res_par)
                   
               }, times = 10)
stopCluster(cls)
