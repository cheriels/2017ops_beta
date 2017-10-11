working.data.dir <- file.path("data_ts", "current")


todays.date <- as.POSIXct("2017-09-11")
start.date <- todays.date - lubridate::days(10)
end.date <- todays.date + lubridate::days(100)

date.temp <- date_frame(start.date,
                        end.date,
                        "hours")
#----------------------------------------------------------------------------
sub.df <- hourly.df %>% 
  dplyr::filter(date_time <= todays.date)
#----------------------------------------------------------------------------
if (nrow(sub.df) == 0 ) return(NULL)
#----------------------------------------------------------------------------
lfalls.obs <- sub.df %>% 
  dplyr::filter(site == "lfalls") %>% 
  rolling_min(flow, 240, "obs") %>% 
  dplyr::filter(site == "obs")

lfalls.pred <- lowflow.hourly.df %>% 
  dplyr::filter(site == "lfalls_sim") %>% 
  rolling_min(flow, 240, "sim")

lfalls.df <- dplyr::bind_rows(lfalls.obs, lfalls.pred) %>% 
  distinct() %>% 
  tidyr::spread(site, flow) %>% 
  dplyr::filter(!is.na(sim)) %>% 
  tidyr::fill(obs) %>% 
  dplyr::mutate(lfalls_lffs = lfalls_sim - (sim - obs)) %>% 
  dplyr::select(date_time, lfalls_lffs) %>% 
  tidyr::gather(site, flow, lfalls_lffs)
#----------------------------------------------------------------------------
final.df <- dplyr::bind_rows(sub.df, lfalls.df) %>% 
  dplyr::filter(!is.na(flow))
