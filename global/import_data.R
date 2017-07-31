# Import daily flow data.
daily.df <- read.csv("data/flow_daily_cfs.csv", stringsAsFactors = FALSE) %>% 
  dplyr::select(1:6) %>% 
  dplyr::rename(date_time = date,
                lfalls = X1646500,
                seneca = X1645000,
                goose = X1644000,
                monocacy = X1643000,
                por = X1638500) %>% 
  dplyr::mutate(date_time = as.Date(date_time))
#------------------------------------------------------------------------------
# Import marfc data.
marfc.df <- data.table::fread("data/marfc_brkm2.csv", data.table = FALSE) %>% 
  dplyr::mutate(date_time = lubridate::mdy_hm(date_time),
                stage = as.numeric(gsub("ft", "", stage)),
                state_units = "ft",
                flow = as.numeric(gsub("kcfs", "", flow)) * 1000,
                flow_units = "cfs")
# Prepare marfc data to be merged with hourly flow data.
marfc.forecast <- marfc.df %>% 
  dplyr::filter(type == "forecast") %>% 
  dplyr::select(date_time, flow) %>% 
  dplyr::rename(marfc = flow)
#------------------------------------------------------------------------------
# Import hourly flow data.
hourly.df <- data.table::fread("data/flow_hourly_cfs.csv", data.table = FALSE) %>% 
  dplyr::select(date_time, x1598500, x1638500, x1645000,
                x1644000, x1643000, x1646500) %>% 
  dplyr::rename(luke = x1598500,
                por = x1638500,
                seneca = x1645000,
                goose = x1644000,
                monocacy = x1643000,
                lfalls = x1646500) %>% 
  dplyr::mutate(date_time = lubridate::ymd_hm(date_time)) %>% 
  dplyr::full_join(marfc.forecast, by = "date_time") %>% 
  tidyr::gather(gage, flow, luke:marfc) %>% 
  dplyr::filter(!is.na(flow))
#------------------------------------------------------------------------------
# Import variable lag-k reference table.
klag.df <- data.table::fread("data/k_lag.csv", data.table = FALSE) %>% 
  rename_all(tolower) %>% 
  mutate(gage = tolower(gage))# %>% 
#  select(-lag) %>% # REMOVE in WHEN MORE GAGES ADDED**********************************************************
#  rename(lag = lag_to_lfall) # REMOVE in WHEN MORE GAGES ADDED************************************************
#------------------------------------------------------------------------------
withdrawals.df <- data.table::fread("data/current/withdrawal_daily_mgd.csv",
                                    data.table = FALSE) %>% 
  dplyr::rename(date_time = date) %>% 
  dplyr::mutate(date_time = lubridate::ymd(date_time))
#------------------------------------------------------------------------------