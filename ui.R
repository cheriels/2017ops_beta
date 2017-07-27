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
  headerPanel(
    tags$strong("ICPRB")
  ), 
  mainPanel(
    div(
      tabsetPanel(
        tabPanel("Situational Awareness",
                 #----------------------------------------------------------------------------
                 fluidRow(
                   # Sidebar with a slider input for number of bins 
                   column(width = 4,
                          # Line break.
                          tags$br(),
                          #h4("X-Axis"),
                          dateInput("today.override", 
                                    paste0("Override today's date (", Sys.Date(), "):")),
                          dateRangeInput("date.range.sa",
                                         "Date range for graphs:", 
                                         start = Sys.Date() - 30,
                                         end = Sys.Date() + 15)),
                   column(width = 2,
                          # Line break.
                          tags$br(),
                          #h4("Y-Axis"),
                          numericInput("min.flow.sa", "Minimum Flow:",
                                       0, min = 0, max = 10 * 9,
                                       width = "110px"),
                          numericInput("max.flow.sa", "Maximum Flow:",
                                       NA, min = 0, max = 10 * 9,
                                       width = "110px")
                          ),
                   column(width = 3,
                          tags$br(),
                          checkboxGroupInput("gages.sa", "Variables to show:",
                                             c("Point of Rocks" = "por",
                                               "Little Falls" = "lfalls",
                                               "Little Falls (Predicted)" = "lfalls_from_upstr"),
                                             selected = c("por", "lfalls", "lfalls_from_upstr")),
                          actionButton("reset.sa", "Reset"),
                          actionButton("clear.sa", "Clear")
                          )
                   
                   #                 div(style = "height:200px;background-color: gray;")
                 ), # End fluidRow
                 #----------------------------------------------------------------------------
                 # Horizontal line break
                 tags$hr(),
                 tags$br(),
                 #----------------------------------------------------------------------------
                 fluidRow(
                   
                   # Show a plot of the generated distribution
                   plotOutput("constant_lagk", width = "100%")
                 ) # End fluidRow
        ), # End tabPanel "Situational Awareness"
        #----------------------------------------------------------------------------
        tabPanel("One-Day Operations",
                 fluidRow(
                 # Sidebar with a slider input for number of bins 
                 column(width = 4,
                        # Line break.
                        tags$br(),
                        #h4("X-Axis"),
                        dateInput("today.override", 
                                  paste0("Override today's date (", Sys.Date(), "):")),
                        dateRangeInput("date.range.odo",
                                       "Date range for graphs:", 
                                       start = Sys.Date() - 7,
                                       end = Sys.Date() + 5)),
                 column(width = 2,
                        # Line break.
                        tags$br(),
                        #h4("Y-Axis"),
                        numericInput("min.flow.odo", "Minimum Flow:",
                                     0, min = 0, max = 10 * 9,
                                     width = "110px"),
                        numericInput("max.flow.odo", "Maximum Flow:",
                                     NA, min = 0, max = 10 * 9,
                                     width = "110px")
                 ),
                 column(width = 3,
                        tags$br(),
                        checkboxGroupInput("gages.odo", "Variables to show:",
                                           c("Point of Rocks" = "por",
                                             "Little Falls" = "lfalls",
                                             "Variable Lag-K" = "predicted",
                                             "MARFC Forecast" = "marfc"),
                                           selected = c("por", "lfalls",
                                                        "predicted", "marfc")),
                        actionButton("reset.odo", "Reset"),
                        actionButton("clear.odo", "Clear")
                 )
                 ),
                 tags$hr(),
                 fluidRow(
                     plotOutput("odo", width = "100%")
                 )
                 
                 
        ), # End tabPanel "One-Day Operations"
        #----------------------------------------------------------------------------
        tabPanel("North Branch Release",
                 fluidRow(
                   # Sidebar with a slider input for number of bins 
                   column(width = 4,
                          # Line break.
                          tags$br(),
                          #h4("X-Axis"),
                          dateInput("today.override", 
                                    paste0("Override today's date (", Sys.Date(), "):")),
                          dateRangeInput("date.range.nbr",
                                         "Date range for graphs:", 
                                         start = Sys.Date() - 7,
                                         end = Sys.Date() + 5)),
                   column(width = 2,
                          # Line break.
                          tags$br(),
                          #h4("Y-Axis"),
                          numericInput("min.flow.nbr", "Minimum Flow:",
                                       0, min = 0, max = 10 * 9,
                                       width = "110px"),
                          numericInput("max.flow.nbr", "Maximum Flow:",
                                       NA, min = 0, max = 10 * 9,
                                       width = "110px")
                   ),
                   column(width = 3,
                          tags$br(),
                          checkboxGroupInput("gages.nbr", "Variables to show:",
                                             c("Luke" = "luke",
                                               "Little Falls" = "lfalls"),
                                             selected = c("luke", "lfalls")),
                          actionButton("reset.nbr", "Reset"),
                          actionButton("clear.nbr", "Clear")
                   )
                 ),
                 tags$hr(),
                 fluidRow(
                   plotOutput("nbr", width = "100%")
                 )
                 ),
        #----------------------------------------------------------------------------
        tabPanel("Demand Time Series",
                 fluidRow(
                   # Sidebar with a slider input for number of bins 
                   column(width = 4,
                          # Line break.
                          tags$br(),
                          #h4("X-Axis"),
                          dateInput("today.override", 
                                    paste0("Override today's date (", Sys.Date(), "):")),
                          dateRangeInput("date.range.dts",
                                         "Date range for graphs:", 
                                         start = Sys.Date() - 7,
                                         end = Sys.Date() + 5)),
                   column(width = 2,
                          # Line break.
                          tags$br(),
                          #h4("Y-Axis"),
                          numericInput("min.flow.dts", "Minimum Flow:",
                                       0, min = 0, max = 10 * 9,
                                       width = "110px"),
                          numericInput("max.flow.dts", "Maximum Flow:",
                                       NA, min = 0, max = 10 * 9,
                                       width = "110px")
                   ),
                   column(width = 3,
                          tags$br(),
                          checkboxGroupInput("gages.dts", "Variables to show:",
                                             c("wa_greatfalls" = "wa_greatfalls",
                                               "wa_littlefalls" = "wa_littlefalls",
                                               "fw_potomac_prod" = "fw_potomac_prod",
                                               "fw_griffith_prod" = "fw_griffith_prod",
                                               "wssc_potomac_prod" = "wssc_potomac_prod",
                                               "wssc_patuxent_prod" = "wssc_patuxent_prod"),
                                             selected = c("wa_greatfalls", "wa_littlefalls", 
                                                          "fw_potomac_prod", "fw_griffith_prod",  
                                                          "wssc_potomac_prod", "wssc_patuxent_prod")),
                          actionButton("reset.dts", "Reset"),
                          actionButton("clear.dts", "Clear")
                 ),
                 tags$hr(),
                 fluidRow(
                   plotOutput("dts", width = "100%")
                 )
                 )
        )
        #----------------------------------------------------------------------------
      ), style = 'width: 1000px; height: 1000px') # End tabsetPanel and End div
  ) # End mainPanel
  
) # End fluidPage
) # End shinyUI

