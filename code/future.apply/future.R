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
