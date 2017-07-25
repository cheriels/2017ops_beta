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


# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  #----------------------------------------------------------------------------
  # Situational Awareness (Tab 1)
  source("scripts/constant_lagk.R", local = TRUE)
  #----------------------------------------------------------------------------
  # MARFC (Tab 2)
  source("scripts/marfc.R", local = TRUE)
  #----------------------------------------------------------------------------
  
  #----------------------------------------------------------------------------
})
