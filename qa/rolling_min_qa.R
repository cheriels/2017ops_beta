
long.df <- sub.df %>% 
  dplyr::filter(site == "lfalls")
flow.col <- rlang::quo(flow)
roll.window <- 240
gage.name = "min"

rolling_min <- function(long.df, flow.col, roll.window, gage.name = "min") {
  flow.col <- rlang::enquo(flow.col)
  final.df <- long.df %>% 
    dplyr::mutate(min = c(rep(NA, roll.window - 1), 
                          RcppRoll::roll_min(rlang::UQ(flow.col), roll.window))) %>% 
    dplyr::select(date_time, min) %>% 
    tidyr::gather(site, flow, min) %>% 
    dplyr::mutate(site = gage.name) %>% 
    dplyr::filter(!is.na(flow)) %>% 
    dplyr::bind_rows(long.df)
  return(final.df)
}
