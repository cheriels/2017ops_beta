#------------------------------------------------------------------------------
# Import daily flow data.
flows.df <- read.csv("data/flow_daily_cfs.csv", stringsAsFactors = FALSE) %>% 
  dplyr::select(1:6) %>% 
  dplyr::rename(lfalls = X1646500,
                seneca = X1645000,
                goose = X1644000,
                monocacy = X1643000,
                por = X1638500) %>% 
  dplyr::mutate(date = as.Date(date))
#------------------------------------------------------------------------------
# Import marfc data.
marfc.df <- data.table::fread("data/marfc_brkm2.csv", data.table = FALSE) %>% 
  dplyr::mutate(date_time = lubridate::mdy_hm(date_time),
                stage = as.numeric(gsub("ft", "", stage)),
                state_units = "ft",
                flow = as.numeric(gsub("kcfs", "", flow)) * 1000,
                flow_units = "cfs")


