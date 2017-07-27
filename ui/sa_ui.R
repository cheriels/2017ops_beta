
tabPanel("Situational Awareness",
         fluidRow(
           fluidRow(
               align = "center",
               # Show a plot of the generated distribution
               #plotlyOutput("constant_lagk")
               plotOutput("constant_lagk", height = "350px", width = "95%")
           ), # End fluidRow
           #----------------------------------------------------------------------------
           wellPanel(
             fluidRow(
             # Sidebar with a slider input for number of bins 
             column(width = 4,
                    #align = "center",
                    dateInput("today.override.sa", 
                              paste0("Today's Date (", Sys.Date(), "):"),
                              width = "200px"),
                    dateRangeInput("date.range.sa",
                                   "Date Range:", 
                                   start = Sys.Date() - 30,
                                   end = Sys.Date() + 15,
                                   width = "200px")),
             column(width = 4,
                    numericInput("min.flow.sa", "Minimum Flow:",
                                 0, min = 0, max = 10 * 9,
                                 width = "120px"),
                    numericInput("max.flow.sa", "Maximum Flow:",
                                 NA, min = 0, max = 10 * 9,
                                 width = "120px")
             ),
             column(width = 4,
                    #tags$br(),
                    checkboxGroupInput("gages.sa",  NULL,
                                       c("Point of Rocks" = "por",
                                         "Little Falls" = "lfalls",
                                         "Little Falls (Predicted)" = "lfalls_from_upstr"),
                                       selected = c("por", "lfalls", "lfalls_from_upstr")),
                    actionButton("reset.sa", "Reset"),
                    actionButton("clear.sa", "Clear")
             )
           ) # End fluidRow
           ) # End wellPanel
           ) # End fluidRow
) # End tabPanel
