library(tidyverse)

working.data.dir <- file.path("data_ts", "current")
na.replace <- c("", " ", "Eqp", "#N/A", "-999999")
#------------------------------------------------------------------------------
daily.df <- file.path(working.data.dir, "flows_obs/flow_daily_cfs.csv") %>% 
  data.table::fread(data.table = FALSE,
                    na.strings = na.replace) %>% 
  dplyr::filter(!is.na(site)) %>% 
  dplyr::mutate(date_time = as.POSIXct(date_time),
                date_time = lubridate::ymd(date_time))

#------------------------------------------------------------------------------

marfc.forecast <- file.path(working.data.dir, "flow_fc/nws/MARFC_BRKM2.csv") %>% 
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

#------------------------------------------------------------------------------
hourly.df <- file.path(working.data.dir, "flows_obs/flow_hourly_cfs.csv") %>% 
  data.table::fread(data.table = FALSE,
                    na.strings = na.replace) %>% 
  dplyr::filter(!is.na(site)) %>% 
  dplyr::mutate(date_time = lubridate::ymd_hms(date_time)) %>% 
  dplyr::bind_rows(marfc.forecast) %>% 
  dplyr::filter(!is.na(flow))

#------------------------------------------------------------------------------

lowflow.hourly.df <- file.path(working.data.dir, "flow_fc/lffs/lfalls_sim_hourly.csv") %>% 
  data.table::fread(data.table = FALSE,
                    na.strings = na.replace) %>% 
  dplyr::select(datetime, lfalls_sim) %>% 
  dplyr::rename(date_time = datetime) %>% 
  dplyr::mutate(date_time = lubridate::ymd_hms(date_time)) %>% 
  tidyr::gather(site, flow, lfalls_sim)

#------------------------------------------------------------------------------

file.path(working.data.dir, "flow_fc/lffs/lfalls_sim_daily.csv") %>% 
  data.table::fread(data.table = FALSE,
                    na.strings = na.replace)

#------------------------------------------------------------------------------

with.df <- file.path(working.data.dir, "withdrawals/withdrawals_wma_daily_mgd.csv") %>% 
  data.table::fread(data.table = FALSE,
                    na.strings = na.replace) %>% 
  dplyr::filter(!rowSums(is.na(.)) == ncol(.))


pot.total <- with.df %>% 
  dplyr::filter(location == "Potomac River"#,
                #day == "yesterday",
                #measurement == "daily average withdrawals"
                ) %>% 
  dplyr::group_by(measurement, date_time, units) %>% 
  dplyr::summarize(value = sum(value)) %>% 
  dplyr::ungroup() %>% 
  dplyr::mutate(unique_id = "potomac_total") %>%
  dplyr::filter(!rowSums(is.na(.)) == ncol(.))

withdrawals.df <- dplyr::bind_rows(with.df, pot.total) %>% 
  dplyr::rename(site = unique_id,
                flow = value) %>% 
  #dplyr::mutate(date_time = as.Date(date_time, "%m/%d/%Y")) %>% 
  dplyr::filter(!stringr::str_detect(site, "usable storage|usable capacity"))


#------------------------------------------------------------------------------
klag.df <- data.table::fread("data/parameters/k_lag.csv", data.table = FALSE) %>% 
  rename_all(tolower) %>% 
  mutate(site = tolower(site))

source("global/load_packages.R", local = TRUE)
source("global/import_data.R", local = TRUE)
source("functions/gen_plots_func.R", local = TRUE)
source("functions/date_standards_func.R", local = TRUE)
source("functions/constant_lagk_func.R", local = TRUE)
source("functions/variable_lagk_func.R", local = TRUE)
source("functions/rolling_min_func.R", local = TRUE)
source("functions/convert_flow_func.R", local = TRUE)
