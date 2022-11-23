library(parallel)

fun1 <- function(invec){
    return(sum(invec))
}

fun2 <- function(invec, b){
    return(sum(invec + b))
}


a <- rnorm(100)
bb <- 1

# ------ explicit functions and variabls ------
cls <- makeCluster(4)
id_seq <- clusterSplit(cls, a)
parSapply(cls, id_seq, fun1)    # fun1 will be transported automatically
parSapply(cls, id_seq, fun2, b = bb)    # fun2 and bb will be transported automatically


fun3 <- function(invec){
    res <- fun1(invec = invec)
    return(res)
}
parSapply(cls, id_seq, fun3)    # could not find fun1 at worker nodes
clusterEvalQ(cls, ls())
clusterExport(cls, varlist = "fun1")    # pass fun1 to workers
parSapply(cls, id_seq, fun3)    # now it's OK
clusterEvalQ(cls, ls())

stopCluster(cls)
rm(cls)


fun4 <- function(invec, b, cls){
    res <- parSapply(cls, invec, function(x, b){
        return(x ^ b)
    }, b = b)
    return(res)
}


fun5 <- function(invec){
    # print(parent.frame())
    res <- invec ^ b
    return(res)
}

fun51 <- function(invec, b, cls){
    res <- parSapply(cls, invec, function(x){
        return(x ^ b)
    })
    return(res)
}

fun52 <- function(invec, cls){
    clusterExport(cls, varlist = "b")    # b will be exported and remained at worker session, default is .GlobalEnv
    res <- parSapply(cls, invec, function(x){
        return(x ^ b)
    })
    return(res)
}

bb <- 2
b <- 3
cls <- makeCluster(4)
fun4(invec = 1 : 10, b = bb, cls = cls)
fun5(invec = 1 : 10)
fun51(invec = 1 : 10, b = 2, cls = cls)
fun51(invec = 1 : 10, b = bb, cls = cls)    # lazy evaluation
fun52(invec = 1 : 10, cls = cls)

clusterEvalQ(cls, ls())
stopCluster(cls)
rm(cls)


fun53 <- function(invec, b, cls){
    res <- parSapply(cls, invec, function(x){
        return(x ^ b + d)
    })
    return(res)
}

fun6 <- function(invec, b, cls){
    d <- b
    res <- fun53(invec = invec, b = b,  cls = cls)
    return(res)
}
fun61 <- function(invec, b, cls){
    d <- b
    clusterExport(cls, varlist = "d")    # set envir = environment()
    res <- fun53(invec = invec, b = b,  cls = cls)
    return(res)
}
b <- 1
d <- 0
cls <- makeCluster(4)
fun53(invec = 1 : 10, b = 2, cls = cls)
fun6(invec = 1 : 10, b = 2, cls = cls)
clusterExport(cls, varlist = "d")
fun61(invec = 1 : 10, b = 2, cls = cls)
