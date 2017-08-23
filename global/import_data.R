# Import daily flow data.
daily.df <- data.table::fread("data/current/flow_daily_cfs.csv", data.table = FALSE,
                              header = TRUE) %>% 
  dplyr::select(date, "1646500", "1645000", '1644000', "1643000", "1638500",
                "1598500", "1595800", "1597500", "1595500", "1596500") %>% 
  dplyr::rename(date_time = date,
                lfalls = "1646500",
                seneca = "1645000",
                goose = "1644000",
                monocacy = "1643000",
                por = "1638500",
                luke = "1598500",
                barnum = "1595800",
                bloomington = "1597500",
                kitzmiller = "1595500",
                barton = "1596500") %>% 
  dplyr::mutate(date_time = as.Date(date_time))
#------------------------------------------------------------------------------
# Import marfc data.
marfc.df <- data.table::fread("data/current/marfc_brkm2.csv", data.table = FALSE) %>% 
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
#hourly.path <- file.path("H:/Projects/COOP Data/usgs_flow",
#                         "flows2017_08_21_10_33_06.csv")
hourly.df <- data.table::fread("data/current/flow_hourly_cfs.csv", data.table = FALSE) %>% 
#hourly.df <- data.table::fread(hourly.path, data.table = FALSE) %>% 
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
klag.df <- data.table::fread("data/parameters/k_lag.csv", data.table = FALSE) %>% 
  rename_all(tolower) %>% 
  mutate(gage = tolower(gage))# %>% 
#  select(-lag) %>% # REMOVE in WHEN MORE GAGES ADDED**********************************************************
#  rename(lag = lag_to_lfall) # REMOVE in WHEN MORE GAGES ADDED************************************************
#------------------------------------------------------------------------------
withdrawals.df <- data.table::fread("data/current/withdrawal_daily_mgd.csv",
                                    data.table = FALSE) %>% 
  dplyr::rename(date_time = date) %>% 
  dplyr::mutate(date_time = lubridate::ymd(date_time)) %>%
  dplyr::mutate(potomac_total = wa_greatfalls + wa_littlefalls + fw_potomac_prod + wssc_potomac_prod)
#------------------------------------------------------------------------------
lowflow.hourly.df <- data.table::fread("data/current/lfalls_sim_hourly.csv",
                                data.table = FALSE) %>% 
  dplyr::select(datetime, lfalls_sim) %>% 
  dplyr::rename(date_time = datetime) %>% 
  dplyr::mutate(date_time = lubridate::ymd_hms(date_time)) %>% 
  tidyr::gather(gage, flow, lfalls_sim)
#------------------------------------------------------------------------------
lowflow.daily.df <- data.table::fread("data/current/lfalls_sim_daily.csv",
                                       data.table = FALSE)
#------------------------------------------------------------------------------
