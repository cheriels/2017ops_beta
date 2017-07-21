#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)
library(dplyr)
#library(data.table)
flowfile <- "c:/workspace/2017ops_beta/data/flow_daily_cfs.csv"

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  output$testPlot <- renderPlot({
    
    # read flows:
    flows_daily <- read.csv(flowfile, stringsAsFactors = FALSE)
    flows <- flows_daily[,1:6]
    names(flows) <- c("date", "lfalls","seneca","goose","monocacy","por")
    flows$date <- as.Date(flows$date)
    
    # set parameters based on values in our daily drought ops tool
    por.K <- 0.042 
    monocacy.K <- 0.050
    # Using lags of 1 day for now, but change to 2 for low flows
    por.lag <- 1
    monocacy.lag <- 1
    
# Add recessions and lags - want to do this using function in future!
    
    upstr <- select(flows, date, lfalls, por, monocacy)
    str(upstr)
    # recess and lag POR flows
    upstr <- upstr %>% mutate(flow1=lag(por,n=1), flow2=lag(por,n=2)) %>%
      mutate(recess_init = pmin(por,flow1,flow2)) %>%  # pmin gives minimums of each row
      mutate(recess_time = ifelse(date - testtoday < 0, 0, date - testtoday)) %>%
      mutate(por_recess = ifelse(date < testtoday, por, recess_init[testtoday-startdate+1]*exp(-por.K*recess_time))) %>%
      mutate(por_recess_lag = lag(por_recess,por.lag))
    str(upstr)
    # recess and lag Monocacy flows
      upstr <- upstr %>% mutate(flow1=lag(monocacy,n=1), flow2=lag(monocacy,n=2)) %>%
      mutate(recess_init = pmin(monocacy,flow1,flow2)) %>%  # pmin gives minimums of each row
      mutate(monocacy_recess = ifelse(date < testtoday, monocacy, recess_init[testtoday-startdate+1]*exp(-monocacy.K*recess_time))) %>%
      mutate(monocacy_recess_lag = lag(monocacy_recess,monocacy.lag)) %>%
      # Predict Little Falls from POR and Monocacy
      mutate(lfalls_from_upstr = por_recess_lag + monocacy_recess_lag) %>%
      select(date, lfalls, por, lfalls_from_upstr)

      # plot flows
    upstr <- subset(upstr, date > as.Date(input$daterange1[1]) & date < as.Date(input$daterange1[2]))
    ggplot(upstr, aes(x=date)) + geom_line(aes(y=lfalls, color="Little Falls"), size=2) + 
          geom_line(aes(y=por, color="Point of Rocks"), size=1) +
          geom_line(aes(y=lfalls_from_upstr, color="LFalls-predicted"), size=1) +
          scale_colour_manual(name="Station", breaks = c("Little Falls","Point of Rocks", "LFalls-predicted"), values=c("skyblue1","green","blue"))
      

    # plot flows
#    flows <- subset(flows, date > as.Date(input$daterange1[1]) & date < as.Date(input$daterange1[2]))
#    ggplot(flows, aes(x=date)) + geom_line(aes(y=lfalls, color="Little Falls"), size=2) + 
#          geom_line(aes(y=por, color="Point of Rocks"), size=1) +
#          geom_line(aes(y=monocacy, color="Monocacy"), size=1) +
#          scale_colour_manual(name="Station", breaks = c("Little Falls","Point of Rocks", "Monocacy"), values=c("skyblue1","green","blue"))
      
      
    
  })
  
})
