library(shiny)
library(ggplot2)
library(dplyr)
library(rlang)
library(data.table)
library(zoo)
#------------------------------------------------------------------------------
# Import daily flow data.
daily.df <- read.csv("data/flow_daily_cfs.csv", stringsAsFactors = FALSE) %>% 
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
# Prepare marfc data to be merged with hourly flow data.
marfc.forecast <- marfc.df %>% 
  dplyr::filter(type == "forecast") %>% 
  dplyr::select(date_time, flow) %>% 
  dplyr::rename(marfc = flow)
#------------------------------------------------------------------------------
# Import hourly flow data.
hourly.df <- data.table::fread("data/flow_hourly_cfs.csv", data.table = FALSE) %>% 
  dplyr::select(date_time, x1638500, x1646500, x1598500) %>% 
  dplyr::rename(por = x1638500,
                lfalls = x1646500,
                luke = x1598500) %>% 
  dplyr::mutate(date_time = lubridate::ymd_hm(date_time)) %>% 
  dplyr::full_join(marfc.forecast, by = "date_time")
#------------------------------------------------------------------------------
# Import variable lag-k reference table.
klag.df <- data.table::fread("data/k_lag.csv", data.table = FALSE) %>% 
  rename_all(tolower) %>% 
  mutate(gage = tolower(gage)) %>% 
  select(-lag) %>% # REMOVE in WHEN MORE GAGES ADDED**********************************************************
  rename(lag = lag_to_lfall) # REMOVE in WHEN MORE GAGES ADDED************************************************
#------------------------------------------------------------------------------
source("functions/variable_lagk_func.R", local = TRUE)
#test <- variable_lagk(hourly.df, por, "por_1", klag.df)
#------------------------------------------------------------------------------
withdrawals.df <- data.table::fread("data/current/withdrawal_daily_mgd.csv",
                                 data.table = FALSE) %>% 
  dplyr::rename(date_time = date) %>% 
  dplyr::mutate(date_time = lubridate::ymd(date_time))
#------------------------------------------------------------------------------

