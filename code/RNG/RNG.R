library(parallel)

# RNGkind("default")
set.seed(10)
(a <- rnorm(10))
(a <- rnorm(10))

set.seed(10)
(a <- rnorm(10))

# --- PSOCK will have their own seed ---
cls <- makeCluster(4)
parSapply(cls, 1 : 4, function(id){
    rnorm(10)
})
stopCluster(cls)

# --- fork will copy the seed setting of main session ---
set.seed(10)
cls <- makeCluster(4, type = "FORK")
parSapply(cls, 1 : 4, function(id){
    rnorm(10)
})

set.seed(10)
parSapply(cls, 1 : 4, function(id){    # but fork only happens when sessions starts...
    rnorm(10)
})

stopCluster(cls)


# --- you can always manually set seed on worker session ---
# However, these approaches do not guarantee high-quality random numbers.
cls <- makeCluster(4)
parSapply(cls, 1 : 4, function(id){
    set.seed(10)
    rnorm(10)
})

parSapply(cls, 1 : 4, function(id){
    set.seed(id)
    rnorm(10)
})

stopCluster(cls)


# --- parallel RNG stream ---
# RNGkind("L'Ecuyer-CMRG")
set.seed(10)
rnorm(10)
set.seed(10)
rnorm(10)

cls <- makeCluster(4)
clusterSetRNGStream(cls, 10)
parSapply(cls, 1 : 4, function(id){
    rnorm(10)
})
stopCluster(cls)



set.seed(10)
cls <- makeCluster(4, type = "FORK")
clusterSetRNGStream(cls, 10)
parSapply(cls, 1 : 4, function(id){
    rnorm(10)
})
stopCluster(cls)
