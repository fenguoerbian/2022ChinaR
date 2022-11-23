library(parallel)
a <- rnorm(100)

# ------ PSOCK ------
cls <- makeCluster(4)
parSapply(cls, 1 : 10, function(id){
    return(a[id])    # a is not available at workers
})
# Error in checkForRemoteErrors(val) : 
#     4 nodes produced errors; first error: object 'a' not found

clusterExport(cls, varlist = "a")    # export a to workers
parSapply(cls, 1 : 10, function(id){
    return(a[id])    
})
stopCluster(cls)
rm(cls)

# ------ FORK ------
cls <- makeCluster(4, type = "FORK")
parSapply(cls, 1 : 10, function(id){
    return(a[id])    # a is available due to FORK
})
stopCluster(cls)
rm(cls)

# ------ memory useage of FORK ------
a <- rnorm(1 * 10 ^ 8)
gc()
a[1 : 10]

cls <- makeCluster(4, type = "FORK")
# clusterEvalQ(cls, {gc()})

parSapply(cls, 1 : 10, function(id){
    return(a[id])
})

parSapply(cls, 1 : 10, function(id){
    a[id] <<- id
    return(a[id])
})

parLapply(cls, 1 : 10, function(id){
    return(a[1 : 10])
})


stopCluster(cls)
rm(cls)

