#------------------------------------------------------------------------------
# Import variable lag-k reference table.
klag.df <- data.table::fread("data/parameters/k_lag.csv", data.table = FALSE) %>% 
  rename_all(tolower) %>% 
  mutate(site = tolower(site))# %>% 
#  select(-lag) %>% # REMOVE in WHEN MORE GAGES ADDED**********************************************************
#  rename(lag = lag_to_lfall) # REMOVE in WHEN MORE GAGES ADDED************************************************
#------------------------------------------------------------------------------
