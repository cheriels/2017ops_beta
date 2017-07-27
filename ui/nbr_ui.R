tabPanel("North Branch Release",
         fluidRow(
           # Sidebar with a slider input for number of bins 
           column(width = 3,
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
                               width = "120px"),
                  numericInput("max.flow.nbr", "Maximum Flow:",
                               NA, min = 0, max = 10 * 9,
                               width = "120px")
           ),
           column(width = 3,
                  tags$br(),
                  tags$br(),
                  checkboxGroupInput("gages.nbr", NULL,
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
)