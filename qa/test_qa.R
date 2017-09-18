working.data.dir <- file.path("data_ts", "current")


todays.date <- as.POSIXct("2017-09-11")
start.date <- todays.date - lubridate::days(10)
end.date <- todays.date + lubridate::days(100)

date.temp <- date_frame(start.date,
                        end.date,
                        "hours")
#----------------------------------------------------------------------------
hourly.sub <- hourly.df %>% 
  dplyr::filter(date_time >= start.date  &
                  date_time <= todays.date) #%>% 
#    tidyr::spread(site, flow) %>% 
#    dplyr::left_join(date.temp, ., by = "date_time") %>% 
#    tidyr::gather(site, flow, 5:ncol(.))
#----------------------------------------------------------------------------
if (nrow(hourly.sub) == 0 ) return(NULL)
#----------------------------------------------------------------------------

variable_confluence <- function(long1.df, gage1, lag1, long2.df, gage2, lag2, klag.df) {
  g1.df <- variable_lagk(long1.df, gage1, lag1, klag.df)
  g2.df <- variable_lagk(long2.df, gage2, lag2, klag.df)
  final.df <- bind_rows(long2.df, g1.df, g2.df) %>% 
    group_by(date_time, site) %>% 
    summarize(flow = sum(flow)) %>% 
    ungroup()
  return(final.df)
}

conf.1 <- variable_confluence(hourly.sub, "por", "por_1", 
                              hourly.sub, "mon_jug", "mon_jug", klag.df)
conf.2 <- variable_confluence(conf.1, "predicted", "por_2",
                              hourly.sub, "goose", "goose", klag.df)
conf.3 <- variable_confluence(conf.2, "predicted", "por_3",
                              hourly.sub, "seneca", "seneca", klag.df)
pred.df <- variable_lagk(conf.3, "predicted", "por_4", klag.df)
lagk.df <- bind_rows(hourly.sub, pred.df)
#----------------------------------------------------------------------------
withdrawals.sub <- withdrawals.df %>% 
  # Yesterday or Today??????????????????????????????????????????????????????????????????????
  dplyr::filter(measurement == "daily average withdrawals",
                day == "yesterday") %>% 
  dplyr::select(date_time, site, flow) %>% 
  tidyr::spread(site, flow) %>% 
  dplyr::mutate(withdrawals = rowSums(.[, c("WA Potomac River at Great Falls daily average withdrawals",
                                            "WA Potomac River at Little Falls daily average withdrawals",
                                            'FW Potomac River',
                                            'WSSC Potomac River')],
                                      na.rm = TRUE)) %>% 
  dplyr::select(date_time, withdrawals) %>% 
  dplyr::rename(date = date_time)
#----------------------------------------------------------------------------
final.df <- lagk.df %>% 
  tidyr::separate(date_time, into = c("date", "time"), convert = TRUE,
                  sep = " ", remove = FALSE) %>% 
  dplyr::mutate(date = as.Date(date)) %>% 
  dplyr::left_join(withdrawals.sub, by = "date") %>% 
  dplyr::select(-date, -time) %>% 
  dplyr::mutate(flow2 = if_else(site == "predicted" & !is.na(withdrawals),
                                flow - withdrawals,
                                flow)) %>% 
  dplyr::select(-withdrawals) %>% 
  dplyr::filter(!is.na(flow))
