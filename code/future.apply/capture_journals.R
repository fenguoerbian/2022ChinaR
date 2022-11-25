# WIP journal system
remotes::install_github("HenrikBengtsson/future", ref = "9875992")

library(tidyverse)
library(future)
n_worker <- 3
n <- 6

plan(sequential)    # default plan

plan(cluster, workers = n_worker)

slow <- function(x){
    Sys.sleep(x / 5)
    return(x)
}

tmp0 <- capture_journals({
    f <- future(slow(2))
    v <- value(f) 
})

summary(tmp0)
print(tmp0)


tmp <- capture_journals({
    fs <- lapply(1:n, function(x) future(slow(x)))
    vs <- value(fs)  
})

# tmp_f <- capture_journals({
#     fs <- lapply(1:n, function(x) future(slow(x)))
#     # vs <- value(fs)  
# })
# 
# tmp_v <- capture_journals({
#     # fs <- lapply(1:n, function(x) future(slow(x)))
#     vs <- value(fs)  
# })
# 
# identical(tmp, tmp_f)
# identical(tmp, tmp_v)
# identical(tmp_f, tmp_v)

tmp_l <- capture_journals({
    future.apply::future_lapply(
        1 : n, 
        slow
    )
})

event_lvls <- c("create", "launch", 
                "getWorker", "eraseWorker", 
                "attachPackages", "exportGlobals", 
                "evaluate", "resolved", "gather")

type_lvls <- c("overhead", "evaluation", "querying")


journal_dat1 <- lapply(1 : n, function(idx, indata){
    cbind(job_idx = idx, indata[[idx]])
}, indata = tmp)

journal_dat1 <- do.call(rbind, journal_dat1)

My_Summary <- function(.data, only_parent = TRUE){
    if(only_parent){
       .data <- .data %>% 
           filter(is.na(parent))
    }
    
    res <- .data %>%
        group_by(job_idx) %>%
        mutate(ostart = min(start)) %>%
        ungroup() %>%
        mutate(ostart = ostart - min(start)) %>%
        mutate(event = factor(event, levels = event_lvls), 
               type = factor(type, levels = type_lvls), 
               start_d = ostart + at, 
               stop_d = ostart + at + duration)
    
    return(res)
}


My_Plot <- function(.data, type){
    n_job <- length(unique(.data$job_idx))
    n_worker <- length(unique(.data$session_uuid)) - 1
    
    p <- ggplot(
        .data, 
        aes(color = {{type}}, fill = {{type}})) + 
        geom_rect(aes(xmin = start_d, xmax = stop_d, 
                      ymin = job_idx - 0.2, ymax = job_idx + 0.2), 
                  alpha = 0.5) + 
        labs(x = "time", y = "job index", 
             title = paste0("Job num: ", n_job, ". Worker num: ", n_worker)) + 
        scale_y_continuous(trans = "reverse")
    return(p)
}


fig_type <- journal_dat1 %>%
    My_Summary() %>%
    My_Plot(type)

fig_type

cairo_pdf("fig_type.pdf", width = 8, height = 4)
print(fig_type)
dev.off()

fig_event <- journal_dat1 %>%
    My_Summary() %>%
    My_Plot(event)

fig_event

cairo_pdf("fig_event.pdf", width = 8, height = 4)
print(fig_event)
dev.off()

fig_event2 <- journal_dat1 %>%
    My_Summary(only_parent = FALSE) %>%
    My_Plot(event)

fig_event2

cairo_pdf("fig_event2.pdf", width = 8, height = 4)
print(fig_event2)
dev.off()




journal_dat2 <- lapply(1 : length(tmp_l), function(idx, indata){
    cbind(job_idx = idx, indata[[idx]])
}, indata = tmp_l)

journal_dat2 <- do.call(rbind, journal_dat2)


journal_dat2 %>%
    filter(is.na(parent)) %>%
    group_by(job_idx) %>%
    mutate(ostart = min(start)) %>%
    ungroup() %>%
    mutate(ostart = ostart - min(start)) %>%
    mutate(event = factor(event, levels = event_lvls), 
           type = factor(type, levels = type_lvls), 
           start_d = ostart + at, 
           stop_d = ostart + at + duration) %>%
    ggplot(aes(x = job_idx, y = start_d, color = type, fill = type)) + 
    geom_rect(aes(xmin = job_idx - 0.25, xmax = job_idx + 0.25, 
                  ymin = start_d, ymax = stop_d), 
              alpha = 0.5)

journal_dat2 %>%
    filter(is.na(parent)) %>%
    group_by(job_idx) %>%
    mutate(ostart = min(start)) %>%
    ungroup() %>%
    mutate(ostart = ostart - min(start)) %>%
    mutate(event = factor(event, levels = event_lvls), 
           type = factor(type, levels = type_lvls), 
           start_d = ostart + at, 
           stop_d = ostart + at + duration) %>%
    ggplot(aes(x = job_idx, y = start_d, color = event, fill = event)) + 
    geom_rect(aes(xmin = job_idx - 0.25, xmax = job_idx + 0.25, 
                  ymin = start_d, ymax = stop_d), 
              alpha = 0.5)
