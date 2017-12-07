# Load packages using script copied from:
# https://www.r-bloggers.com/install-and-load-missing-specifiedneeded-packages-on-the-fly/
# needed packages for a job
need <- c("shiny",
          "shinythemes",
          "ggplot2",
          "dplyr",
          "rlang",
          "data.table",
          "stringi",
          #"plotly",
          "Cairo",
          "RcppRoll",
          "tidyr",
          "zoo") 
# find out which packages are installed
ins <- installed.packages()[, 1] 
# check if the needed packages are installed
(Get <-
    need[which(is.na(match(need, ins)))]) 
# install the needed packages if they are not-installed
if (length(Get) > 0) {
  install.packages(Get)
} 
# load the needed packages
eval(parse(text = paste("library(", need, ")")))
rm(Get, ins, need)
#------------------------------------------------------------------------------
options(shiny.usecairo = TRUE)