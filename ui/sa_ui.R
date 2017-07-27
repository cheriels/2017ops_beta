tabPanel("Situational Awareness",
         fluidRow(
           # Sidebar with a slider input for number of bins 
           column(width = 3,
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
                               width = "120px"),
                  numericInput("max.flow.sa", "Maximum Flow:",
                               NA, min = 0, max = 10 * 9,
                               width = "120px")
           ),
           column(width = 3,
                  #align = "middle",
                  tags$br(),
                  tags$br(),
                  checkboxGroupInput("gages.sa",  NULL,
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
           #plotlyOutput("constant_lagk")
           plotOutput("constant_lagk")
         ) # End fluidRow
)