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
  
  # Application title
  titlePanel("CO-OP Ops beta0"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      sliderInput("bins",
                  "Number of bins:",
                  min = 1,
                  max = 50,
                  value = 30),
      dateInput("today_override","Optional override of today's date:"),
      dateRangeInput("daterange1","Date range for graphs:", 
                     start = Sys.Date() - 30,
                     end = Sys.Date() + 15)
      
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      textOutput("This is a test"),
      plotOutput("distPlot")
    )
  )
))
