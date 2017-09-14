
variable_lagk <- function(long.df, site.name, por.lag, klag.df) {
  #------------------------------------------------------------------------------
  klag.sub <- klag.df %>% 
    dplyr::filter(site == por.lag) %>% 
    dplyr::select(flow, lag)
  #------------------------------------------------------------------------------
  predicted.df <- long.df %>% 
    dplyr::filter(site == site.name) %>% 
    dplyr::mutate(range = as.character(cut(flow, breaks = klag.sub$flow)),
                  lower_flow = as.numeric(gsub("\\(|,.*", "", range)),
                  upper_flow = as.numeric(gsub(".*,|\\]", "", range))) %>% 
    dplyr::left_join(klag.sub, by = c("lower_flow" = "flow")) %>% 
    dplyr::left_join(klag.sub, by = c("upper_flow" = "flow")) %>% 
    dplyr::rename(lower_lag = lag.x,
                  upper_lag = lag.y) %>% 
    dplyr::mutate(lag = lower_lag + ((upper_lag - lower_lag) * (flow - lower_flow) / (upper_flow - lower_flow)),
                  lag = date_time + lag * 3600) %>% 
    dplyr::select(lag, site, flow) %>% 
    dplyr::rename(date_time = lag) %>% 
    dplyr::mutate(site = "predicted") %>% 
    dplyr::mutate(date_time = as.POSIXct(round(date_time, units = "hours"))) %>% 
    dplyr::group_by(date_time, site) %>% 
    dplyr::summarise(flow = mean(flow))
  #------------------------------------------------------------------------------
  start.date <- min(predicted.df$date_time, na.rm = TRUE)
  end.date <- max(predicted.df$date_time, na.rm = TRUE)
  date.frame <- date_frame(start.date, end.date, "hour")
  final.df <- left_join(date.frame, predicted.df, by = "date_time") %>% 
    mutate(flow = c(rep(NA, which.min(is.na(flow)) - 1),
                         zoo::na.approx(flow)),
           site = "predicted") %>% 
    dplyr::filter(!is.na(flow))
  #------------------------------------------------------------------------------
  return(final.df)
}
