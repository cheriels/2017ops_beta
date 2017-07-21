# C. Schultz, Jul 21, 2017
#
# This file has the mechanics for adding future recession flows and constant lags to a daily flow time series.
#    It needs to be converted into a function!
#
# Key inputs are:
#           daily flow time series - below I'm using POR flows read from a flow file
#           startdate - of the time series
#           testtoday - today's date, or test date
#           K = recession coefficient
#           lag = lag in days, rounded to nearest day

library(dplyr)

# create a "test today" - currently the last day of the test daily flow data set:
testtoday <- as.Date("2017-07-18")
startdate <- as.Date("2017-01-01")

por.K <- 0.042 # Using the POR recession coefficient from our daily drought ops tool
por.lag <- 2 # Using the POR low flow lag, rounded to nearest day, from our daily drought ops tool

# read daily flows at sites from Little Falls to Point of Rocks:
flowfile_daily <- "c:/workspace/2017ops_beta/data/flow_daily_cfs.csv"
flows_daily <- read.csv(flowfile_daily, stringsAsFactors = FALSE)
flows <- flows_daily[,1:6]
names(flows) <- c("date", "lfalls","seneca","goose","monocacy","por")
flows$date <- as.Date(flows$date)

# focus on Point of Rocks - add future recession
upstr <- select(flows, date, por)
str(upstr)
upstr <- upstr %>% mutate(por1=lag(por,n=1), por2=lag(por,n=2)) %>%
  mutate(recess_init = pmin(por,por1,por2)) %>%  # pmin gives minimums of each row
  mutate(recess_time = ifelse(date - testtoday < 0, 0, date - testtoday)) %>%
  mutate(por_recess = ifelse(date < testtoday, por, recess_init[testtoday-startdate+1]*exp(-por.K*recess_time))) %>%
  # Add a column with the lagged flow
  mutate(por_recess_lag = lag(por_recess,por.lag)) %>%
  select(date, por, por_recess_lag)

# Look at the results in the vicinity of "today":
upstr[(testtoday-startdate-10):(testtoday-startdate+10),]