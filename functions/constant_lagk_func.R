
# Constant Lag-K function.
constant_lagk <- function(flow.df, gage, todays.date, start.date, lag.days = 1) {
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
           recess_time = ifelse(date_time - todays.date < 0, 0, date_time - todays.date),
           #recess_time = case_when(
           #  date_time - todays.date < 0 ~ 0,
           #  TRUE ~ date_time - today.date
           #),
           recess = ifelse(date_time < todays.date, rlang::UQ(gage), 
                           #                           recess_init[todays.date - start.date + 1] * exp(-gage.k * recess_time)),
                           recess_init[todays.date] * exp(-gage.k * recess_time)),
           recess_lag = lag(recess, lag.days)) %>% 
    select(-flow1, -flow2, - recess_init, -recess_time, - recess)
  
  names(final.df)[names(final.df) %in% "recess_lag"] <- paste(gage.string, "recess_lag", sep = "_")
  return(final.df)
}