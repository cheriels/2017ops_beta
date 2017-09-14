working.data.dir <- reactive({
  file.path("data_ts", input$data.dir)
})
na.replace <- c("", " ", "Eqp", "#N/A", "-999999")
#------------------------------------------------------------------------------
daily.df <- reactive({
 daily.df <- file.path(working.data.dir(), "flows_obs/flow_daily_cfs.csv") %>% 
    data.table::fread(data.table = FALSE,
                      na.strings = na.replace) %>% 
    dplyr::mutate(date_time = as.Date(date_time))
 return(daily.df)
})
#------------------------------------------------------------------------------
marfc.forecast <- reactive({
  marfc.df <- file.path(working.data.dir(), "flow_fc/nws/MARFC_BRKM2.csv") %>% 
    data.table::fread(data.table = FALSE,
                      na.strings = na.replace) %>% 
    dplyr::filter(type == "forecast") %>% 
    dplyr::select(date_time, flow) %>% 
    dplyr::mutate(date_time = lubridate::ymd_hm(date_time),
                  #stage = as.numeric(gsub("ft", "", stage)),
                  #state_units = "ft",
                  flow = as.numeric(gsub("kcfs", "", flow)) * 1000,
                  #flow_units = "cfs"
                  site = "marfc")
  return(marfc.df)
})
#------------------------------------------------------------------------------
hourly.df <- reactive({
  if(is.null(marfc.forecast())) NULL
  
  hourly.df <- file.path(working.data.dir(), "flows_obs/flow_hourly_cfs.csv") %>% 
    data.table::fread(data.table = FALSE,
                      na.strings = na.replace) %>% 
    dplyr::mutate(date_time = dplyr::if_else(nchar(date_time) == 19,
                                             lubridate::ymd_hms(date_time),
                                             lubridate::ymd_hm(date_time))) %>% 
    dplyr::bind_rows(marfc.forecast()) %>% 
    dplyr::filter(!is.na(flow))
  
  return(hourly.df)
})
#------------------------------------------------------------------------------
lowflow.hourly.df <- reactive({
  lowflow.hourly.df <- file.path(working.data.dir(), "flow_fc/lffs/lfalls_sim_hourly.csv") %>% 
    data.table::fread(data.table = FALSE,
                      na.strings = na.replace) %>% 
    dplyr::select(datetime, lfalls_sim) %>% 
    dplyr::rename(date_time = datetime) %>% 
    dplyr::mutate(date_time = lubridate::ymd_hms(date_time)) %>% 
    tidyr::gather(site, flow, lfalls_sim)
  
  return(lowflow.hourly.df)
})

#------------------------------------------------------------------------------
lowflow.daily.df <- reactive({
  file.path(working.data.dir(), "flow_fc/lffs/lfalls_sim_daily.csv") %>% 
    data.table::fread(data.table = FALSE,
                      na.strings = na.replace)
})
#------------------------------------------------------------------------------
withdrawals.df <- reactive({
  with.df <- file.path(working.data.dir(), "withdrawals/withdrawals_wma_daily_mgd.csv") %>% 
    data.table::fread(data.table = FALSE,
                      na.strings = na.replace) %>% 
    dplyr::rename(date_time = today) %>% 
    dplyr::mutate(date_time = lubridate::ymd(date_time)) %>% 
    dplyr::filter(!rowSums(is.na(.)) == ncol(.))
    
  
  pot.total <- with.df %>% 
    dplyr::filter(location == "Potomac River",
                  day == "yesterday",
                  measurement == "daily average withdrawals") %>% 
    dplyr::group_by(measurement, date_time, units) %>% 
    dplyr::summarize(value = sum(value)) %>% 
    dplyr::ungroup() %>% 
    dplyr::mutate(unique_id = "potomac_total",
                  # the values are from yesterday, so
                  # to correct date subtract 1.
                  date_time = date_time - lubridate::days(1)) %>% 
    dplyr::filter(!rowSums(is.na(.)) == ncol(.))
  
  withdrawals.df <- dplyr::bind_rows(with.df, pot.total) %>% 
    dplyr::rename(site = unique_id,
                  flow = value)
  
  return(withdrawals.df)
})
#------------------------------------------------------------------------------


