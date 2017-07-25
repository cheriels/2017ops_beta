#
# This is the user-interface definition of a first try Shiny web application to
#    replace CO-OP's Excel tools, DroughtOps_Daily.xlsx and DroughtOps_Hourly.xlsx.
#
# To get this to run - from Console - type
#   > setwd("c:/workspace/2017ops_beta/scripts")
#   > library(shiny)
#
# Then you can run the shiny app by typing
#   > runApp()
#
# To close the app, hit the red button on the upper right of Console.

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  # The first tab, Situational Awareness. is meant to give ops staff a first look at where we are today
  # and what needs to be done.
  # Right now I'm working on a graph of Little Falls flow, predicted Little Falls flow, and Point of Rocks flow.
  # I want to add to the graph the Point of Rocks trigger for daily monitoring,
  # and the Little Falls trigger for enhanced drought operations.
  #----------------------------------------------------------------------------
  mainPanel(
    div(
    tabsetPanel(

      tabPanel("Situational Awareness",
               #----------------------------------------------------------------------------
               fluidRow(
                 # Sidebar with a slider input for number of bins 
                 column(width = 4,
                        #h4("X-Axis"),
                        dateInput("today.override", 
                                  paste0("Override today's date (", Sys.Date(), "):")),
                        dateRangeInput("date.range1",
                                       "Date range for graphs:", 
                                       start = Sys.Date() - 30,
                                       end = Sys.Date() + 15)),
                 column(width = 6,
                        #h4("Y-Axis"),
                        numericInput("min.flow", "Minimum Flow:",
                                     NA, min = 0, max = 10 * 9,
                                     width = "110px"),
                        numericInput("max.flow", "Maximum Flow:",
                                     NA, min = 0, max = 10 * 9,
                                     width = "110px")
                        )#,
#                 div(style = "height:200px;background-color: gray;")
               ), # End fluidRow
               #----------------------------------------------------------------------------
               # Horizontal lin break
               tags$hr(),
               #----------------------------------------------------------------------------
               fluidRow(
                 # Show a plot of the generated distribution
                 textOutput("This is a test"),
                 plotOutput("constant_lagk", width = "100%")
               )# End fluidRow
      ), # End tabPanel "Situational Awareness"
      #----------------------------------------------------------------------------
      tabPanel("Variable Lag-K"),
      #----------------------------------------------------------------------------
      tabPanel("Other")
      #----------------------------------------------------------------------------
    ), style = 'width: 1000px; height: 1000px') # End tabsetPanel and End div
  ) # End mainPanel
  
) # End fluidPage
) # End shinyUI

