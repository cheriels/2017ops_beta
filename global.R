#------------------------------------------------------------------------------
# read flows:
flows.df <- read.csv("data/flow_daily_cfs.csv", stringsAsFactors = FALSE) %>% 
  dplyr::select(1:6) %>% 
  dplyr::rename(lfalls = X1646500,
                seneca = X1645000,
                goose = X1644000,
                monocacy = X1643000,
                por = X1638500) %>% 
  dplyr::mutate(date = as.Date(date))
#------------------------------------------------------------------------------


lag_k <- function(flow.df, gage, todays.date, start.date, lag.days = 1) {
  gage <- rlang::enquo(gage)
  gage.string <- rlang::quo_name(gage)
  if (gage.string == "por") gage.k <- 0.042
  if (gage.string == "monocacy") gage.k <- 0.050
  #----------------------------------------------------------------------------
  final.df <- flow.df %>% 
    # recess and lag POR flows
    mutate(flow1 = lag(rlang::UQ(gage), n = 1),
           flow2 = lag(rlang::UQ(gage), n = 2),
           recess_init = pmin(rlang::UQ(gage), flow1, flow2), # pmin gives minimums of each row
           recess_time = ifelse(date - todays.date < 0, 0, date - todays.date),
           #recess_time = case_when(
           #  date - todays.date < 0 ~ 0,
           #  TRUE ~ date - today.date
           #),
           recess = ifelse(date < todays.date, rlang::UQ(gage), 
                               recess_init[todays.date - start.date + 1] * exp(-gage.k * recess_time)),
           recess_lag = lag(recess, lag.days)) %>% 
    select(-flow1, -flow2, - recess_init, -recess_time, - recess)
  
  names(final.df)[names(final.df) %in% "recess_lag"] <- paste(gage.string, "recess_lag", sep = "_")
  return(final.df)
}
