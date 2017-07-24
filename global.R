#------------------------------------------------------------------------------
# read flows:
flows.df <- read.csv("data/flow_daily_cfs.csv", stringsAsFactors = FALSE) %>% 
  dplyr::select(1:6) %>% 
  dplyr::rename(lfalls = X1646500,
                seneca = X1645000,
                goose = X1644000,
                monocacy = X1643000,
                por = X1638500) %>% 
  dplyr::mutate(date = as.Date(date))
#------------------------------------------------------------------------------



