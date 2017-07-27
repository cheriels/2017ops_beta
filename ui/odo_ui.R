tabPanel("One-Day Operations",
         fluidRow(
           # Sidebar with a slider input for number of bins 
           column(width = 3,
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
                               width = "120px"),
                  numericInput("max.flow.odo", "Maximum Flow:",
                               NA, min = 0, max = 10 * 9,
                               width = "120px")
           ),
           column(width = 3,
                  tags$br(),
                  tags$br(),
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
         ),
         tags$hr(),
         fluidRow(
           plotOutput("odo", width = "100%")
         )
         
         
)