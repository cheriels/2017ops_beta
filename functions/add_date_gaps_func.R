


add_date_gaps <- function(data, start.date, end.date, period) {
  start.date <- min(min(data$date_time), start.date)
  end.date <- max(max(data$date_time), end.date)
  date.temp <- date_frame(start.date,
                          end.date,
                          period)
  
  
  site.vec <- unique(data$site)
  data.nest <- data %>% 
    group_by(site) %>% 
    nest()
  final.list <- purrr::map(site.vec, function(site.i) {
    data.sub <- data.nest %>% 
      filter(site == site.i) %>% 
      unnest() %>% 
      full_join(date.temp, by = "date_time") %>% 
      mutate(site = site.i)
  })
  final.df <- bind_rows(final.list)
  return(final.df)
}