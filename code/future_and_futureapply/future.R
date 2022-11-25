library(future)
plan(cluster)

x <- future({
    x <- matrix(rnorm(10 ^ 6), nrow = 10 ^ 3)
    for(i in 1 : 5){
        print(paste("i = ", i))
        res <- eigen(x) 
    }
    return(res)
}, seed = T)

resolved(x)
a <- rnorm(10)

while(!resolved(x)){
    cat("...")
    Sys.sleep(0.2)
}
y <- value(x)



#  library(future)
cls <- makeClusterPSOCK("xxx.xxx.xxx.xxx", user = "username", rscript = "~/anaconda3/envs/my_R/bin/Rscript")
plan(cluster, workers = cls)
x <- future({
    x <- matrix(rnorm(10 ^ 6), nrow = 10 ^ 3)
    for(i in 1 : 2){
        print(paste("i = ", i))
        res <- eigen(x) 
    }
    return(res)
})
resolved(x)
# [1] TRUE
y <- value(x)
plan(sequential)


# WIP, journal system

remotes::install_github("git@github.com:HenrikBengtsson/future.git", ref = "9875992", force = TRUE)

library(future)

?capture_journals()
plan(cluster, workers = 2)
slow_fcn <- function(x) {
    Sys.sleep(x / 10)
    sqrt(x)
}

js <- capture_journals({
    fs <- lapply(3:1, FUN = function(x) future(slow_fcn(x)))
    value(fs)
})
lapply(js, function(indata){indata[1 : 6, c("event", "type", "parent", "duration")]})
