library(progressr)
slow_sum <- function(x) {
    p <- progressr::progressor(along = x)
    sum <- 0
    for (kk in seq_along(x)) {
        Sys.sleep(0.5)
        sum <- sum + x[kk]
        p(message = sprintf("Added %g", x[kk]))
    }
    sum
}
handlers("default")
y <- slow_sum(1 : 5)    # I don't want progress
with_progress(y <- slow_sum(1 : 5))    # I want progress report

handlers("progress")
with_progress(y <- slow_sum(1 : 10))

handlers("rstudio")
with_progress(y <- slow_sum(1:10))

handlers("progress")
handlers(global = TRUE)    # available for R >= 4.0, always repsenting progress
y <- slow_sum(1 : 5)

# ------ work with normal output ------
slow_sum <- function(x) {
    p <- progressr::progressor(along = x)
    sum <- 0
    for (kk in seq_along(x)) {
        Sys.sleep(0.5)
        sum <- sum + x[kk]
        print(paste("kk = ", kk, sep = ""))
        p(message = sprintf("Added %g", x[kk]))
    }
    sum
}
y <- slow_sum(1 : 5)

# ------ supports parallel processing ------
# --- future.apply ---
library(future.apply)
plan(cluster)

xs <- 1:5

with_progress({
    p <- progressor(along = xs)
    y <- future_lapply(xs, function(x, ...) {
        Sys.sleep(6.0-x)
        p(sprintf("x=%g", x))
        sqrt(x)
    })
})

# --- foreach with doFuture ---
library(doFuture)
registerDoFuture()
plan(cluster)

xs <- 1:5

with_progress({
    p <- progressor(along = xs)
    y <- foreach(x = xs) %dopar% {
        Sys.sleep(6.0-x)
        p(sprintf("x=%g", x))
        sqrt(x)
    }
})


# ------ nested progress bar, still work in progress ------
# currently only the first layer of progress is reported
# See https://github.com/HenrikBengtsson/progressr/issues/78 for more discussion
inside_fun <- function(idvec){
    pb <- progressr::progressor(along = idvec)
    for(id in idvec){
        pb(message = paste("current ID = ", id, sep = ""))
        Sys.sleep(0.25)
    }
    return(idvec)
}

outside_fun <- function(idvec_mat){
    pb2 <- progressr::progressor(along = 1 : nrow(idvec_mat))
    for(id in 1 : nrow(idvec_mat)){
        pb2(message = paste("List ID = ", id, sep = ""))
        Sys.sleep(1)
        inside_fun(idvec_mat[id, ])
    }
    NULL
}

# handlers("progress")

inside_fun(1 : 10)

outside_fun(matrix(1 : 30, nrow = 3, byrow = T))    # currently only the first layer of progress is reported
# at last will be a progress from `inside_fun`
#   that's because progress report from `outside_fun` finishes, then a call to `inside_fun`
