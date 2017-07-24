#
# This is the user-interface definition of a first try Shiny web application to
#    replace CO-OP's Excel tools, DroughtOps_Daily.xlsx and DroughtOps_Hourly.xlsx.
#
# To get this to run - from Console - type
#   > setwd("c:/workspace/2017ops_beta/scripts")
#   > library(shiny)
#
# Then you can run the shiny app by hitting the "Run App" icon, or typing in the console:
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
  # Later we might add output to alert us of an impending Great Falls load shift.
  
  fluidRow(
  # Title of first tab
    column(width = 6,
    h4("Situational Awareness")
    )
  ),
   fluidRow(
  
  # Sidebar with a slider input for number of bins 
      column(width = 6,
             dateInput("today_override","Optional override of today's date:"),
             dateRangeInput("daterange1", "Date range for graphs:", 
                     start = Sys.Date() - 30,
                     end = Sys.Date() + 15)
          ),
      column(width = 6,
             textOutput("testDate")
      )
   ),
  fluidRow(
    
    # Show a plot of the generated distribution
      textOutput("This is a test"),
      plotOutput("testPlot")
    )
  )
)

