#------------------------------------------------------------------------------
# Import variable lag-k reference table.
klag.df <- data.table::fread("data/parameters/k_lag.csv", data.table = FALSE) %>% 
  rename_all(tolower) %>% 
  mutate(gage = tolower(gage))# %>% 
#  select(-lag) %>% # REMOVE in WHEN MORE GAGES ADDED**********************************************************
#  rename(lag = lag_to_lfall) # REMOVE in WHEN MORE GAGES ADDED************************************************
#------------------------------------------------------------------------------
