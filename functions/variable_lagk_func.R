
variable_lagk <- function(long.df, gage.name, por.lag, klag.df) {
  #------------------------------------------------------------------------------
  gage.name = rlang::enquo(gage.name)
  #------------------------------------------------------------------------------
  klag.sub <- klag.df %>% 
    dplyr::filter(gage == por.lag) %>% 
    dplyr::select(flow, lag)
  #------------------------------------------------------------------------------
  flow.df <- long.df %>% 
    dplyr::mutate(range = as.character(cut(rlang::UQ(gage.name), 
                                           breaks = klag.sub$flow)),
                  lower_flow = as.numeric(gsub("\\(|,.*", "", range)),
                  upper_flow = as.numeric(gsub(".*,|\\]", "", range))) %>% 
    dplyr::left_join(klag.sub, by = c("lower_flow" = "flow")) %>% 
    dplyr::left_join(klag.sub, by = c("upper_flow" = "flow")) %>% 
    dplyr::rename(lower_lag = lag.x,
                  upper_lag = lag.y) %>% 
    dplyr::mutate(lag = lower_lag + ((upper_lag - lower_lag) * (rlang::UQ(gage.name) - lower_flow) / (upper_flow - lower_flow)),
                  lag = date_time + lag * 3600)
  #------------------------------------------------------------------------------
  lag.df <- dplyr::select(flow.df, rlang::UQ(gage.name), lag) %>% 
    dplyr::filter(!is.na(lag)) %>% 
    dplyr::mutate(lag = as.POSIXct(round(lag, units = "hours"))) %>% 
    dplyr::rename(date_time = lag,
                  predicted = rlang::UQ(gage.name)) %>% 
    dplyr::group_by(date_time) %>% 
    dplyr::summarise(predicted = mean(predicted))
  #------------------------------------------------------------------------------
  final.df <- flow.df %>% 
    dplyr::select(-lag) %>% 
    dplyr::full_join(lag.df, by = "date_time") %>% 
    dplyr::mutate(predicted = c(rep(NA, which.min(is.na(predicted)) - 1),
                                zoo::na.approx(predicted))) %>% 
    dplyr::select(-range, -lower_flow, - upper_flow, - lower_lag, -upper_lag)
  #------------------------------------------------------------------------------
  return(final.df)
}



