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
shinyUI(navbarPage(title = tags$a("", href = "http://icprbcoop.org/drupal4/self-breifing-conditions", target = "_blank",
                                  tags$span(style="color:white", "CO-OP")),
                   id = "tab",
                   inverse = TRUE, 
                   theme = shinythemes::shinytheme("spacelab"),
                   
                   source("ui/sa_ui.R", local = TRUE)$value,
                   source("ui/odo_ui.R", local = TRUE)$value,
                   source("ui/nbr_ui.R", local = TRUE)$value,
                   source("ui/dts_ui.R", local = TRUE)$value,
                   #source("ui/coop_link_ui.R", local = TRUE)$value,
                   source("ui/wellpanel_ui.R", local = TRUE)$value,
                   tags$head(tags$style(".shiny-plot-output{height:50vh !important;}"),
                             #tags$style(".well{height:40vh !important;}"),
                             tags$style(".well{margin-bottom: 0px;}"))
                   
))