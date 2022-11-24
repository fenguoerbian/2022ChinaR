library(foreach)
a <- 10
foreach(i = 1 : 12, j = 12 : 1, .combine = rbind) %dopar%{
    Sys.sleep(0.5)
    print(paste("i = ", i, ", j = ", j, sep = ""))
    data.frame(i, j, a)
}

library(doParallel)
registerDoParallel()
foreach(i = 1 : 12, j = 12 : 1, .combine = rbind) %dopar%{
    Sys.sleep(0.5)
    print(paste("i = ", i, ", j = ", j, sep = ""))    # where is my output?
    data.frame(i, j, a)
} 

foreach(i = 1 : 8, .combine = c) %dopar% {
    ls()
}

system.time(
    foreach(i = 1 : 12, j = 12 : 1, .combine = rbind) %dopar%{
        Sys.sleep(0.5)
        print(paste("i = ", i, ", j = ", j, sep = ""))
        data.frame(i, j, a)
    } 
)

foreach(i = 1 : 4, .combine = `+`) %dopar%{
    start <- (i - 1) * 25 + 1
    stop <- i * 25
    sum(start : stop)
}

# foreach uses for-loop syntax, but it's actually more like a `apply` function
# so `<<-` will not work.


library(doFuture)
registerDoFuture()
plan(cluster)
foreach(i = 1 : 12, j = 12 : 1, .combine = rbind) %dopar%{
    Sys.sleep(0.5)
    print(paste("i = ", i, ", j = ", j, sep = ""))    # output is relayed back with future backend
    data.frame(i, j, a)
} 



library(doRNG)
registerDoParallel()

set.seed(1234)
rnorm(2)
set.seed(1234)
(s1 <- foreach(i=1:4) %dopar% { runif(1) })
set.seed(1234)
(s2 <- foreach(i=1:4) %dopar% { runif(1) })
identical(s1, s2)

# single %dorng% loops are reproducible
(r1 <- foreach(i=1:4, .options.RNG=1234) %dorng% { runif(2) })
(r2 <- foreach(i=1:4, .options.RNG=1234) %dorng% { runif(2) })
identical(r1, r2)

registerDoFuture()
plan(cluster)
set.seed(1234)
rnorm(2)
set.seed(1234)
(s1 <- foreach(i=1:4) %dopar% { runif(1) })
set.seed(1234)
(s2 <- foreach(i=1:4) %dopar% { runif(1) })
identical(s1, s2)
