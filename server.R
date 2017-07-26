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
library(rlang)
library(data.table)


# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  #----------------------------------------------------------------------------
  # TAB 1
  # Situational Awareness (sa)
  #----------------------------------------------------------------------------
  source("scripts/constant_lagk.R", local = TRUE)
  #----------------------------------------------------------------------------
  # TAB 2
  # One-Day Operations (odo)
  #----------------------------------------------------------------------------
  source("scripts/odo.R", local = TRUE)
  #----------------------------------------------------------------------------
})
