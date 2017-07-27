tabPanel("One-Day Operations",
         fluidRow(
           fluidRow(
             align = "center",
             plotOutput("odo", height = "350px", width = "95%")
           ), # End fluidRow
           #-------------------------------------------------------------------
           wellPanel(
             fluidRow(
               # Sidebar with a slider input for number of bins 
               column(width = 4,
                      #align = "center",
                      dateInput("today.override.odo", 
                                paste0("Today's Date (", Sys.Date(), "):"),
                                width = "200px"),
                      dateRangeInput("date.range.odo",
                                     "Date Range:", 
                                     start = Sys.Date() - 5,
                                     end = Sys.Date() + 5,
                                     width = "200px")),
               column(width = 4,
                      numericInput("min.flow.odo", "Minimum Flow:",
                                   0, min = 0, max = 10 * 9,
                                   width = "120px"),
                      numericInput("max.flow.odo", "Maximum Flow:",
                                   NA, min = 0, max = 10 * 9,
                                   width = "120px")
               ),
               column(width = 4,
                      checkboxGroupInput("gages.odo", NULL,
                                         c("Point of Rocks" = "por",
                                           "Little Falls" = "lfalls",
                                           "Variable Lag-K" = "predicted",
                                           "MARFC Forecast" = "marfc"),
                                         selected = c("por", "lfalls",
                                                      "predicted", "marfc")),
                      actionButton("reset.odo", "Reset"),
                      actionButton("clear.odo", "Clear")
               )
             ) # End fluidRow
           ) # End wellPanel
         ) # fluidRow
) # End tabPanel