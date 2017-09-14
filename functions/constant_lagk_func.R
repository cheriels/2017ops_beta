
# Constant Lag-K function.
constant_lagk <- function(flow.df, gage, todays.date, lag.days = 1) {
  todays.date <- lubridate::ymd(todays.date)
  gage <- rlang::enquo(gage)
  gage.string <- rlang::quo_name(gage)
  if (gage.string == "por") gage.recessk <- 0.042
  if (gage.string == "mon_jug") gage.recessk <- 0.050
  #----------------------------------------------------------------------------
  lag.df <- flow.df %>% 
    dplyr::select(date_time, site, flow) %>% 
    dplyr::filter(site %in% gage.string) %>% 
    # recess and lag POR flows
    mutate(flow1 = lag(flow, n = 1),
           flow2 = lag(flow, n = 2),
           recess_init = pmin(flow, flow1, flow2), # pmin gives minimums of each row
           recess_time = ifelse(date_time - todays.date < 0, 0, date_time - todays.date),
           recess = ifelse(date_time < todays.date, flow, 
                           recess_init[date_time == todays.date] * exp(-gage.recessk * recess_time)),
           recess_lag = lag(recess, lag.days)) %>% 
    select(-flow1, -flow2, - recess_init, -recess_time, - recess, - site) %>% 
    tidyr::gather(site, flow, flow:recess_lag) %>% 
    dplyr::mutate(
      site = dplyr::case_when(
        site == "flow" ~ gage.string,
        site == "recess_lag" ~ paste(gage.string, "recess_lag", sep = "_"),
        TRUE ~ "ERROR"))
  
  final.df <- dplyr::bind_rows(lag.df,
                               dplyr::filter(flow.df, !site %in% gage.string))
  return(final.df)
}
