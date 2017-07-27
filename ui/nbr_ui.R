tabPanel("North Branch Release",
         fluidRow(
           fluidRow(
             align = "center",
             plotOutput("nbr", height = "350px", width = "95%")
           ),
           #-------------------------------------------------------------------
           wellPanel(
             fluidRow(
               # Sidebar with a slider input for number of bins 
               column(width = 4,
                      #align = "center",
                      dateInput("today.override.nbr", 
                                paste0("Today's Date (", Sys.Date(), "):"),
                                width = "200px"),
                      dateRangeInput("date.range.nbr",
                                     "Date Range:", 
                                     start = Sys.Date() - 5,
                                     end = Sys.Date() + 5,
                                     width = "200px")),
               column(width = 4,
                      numericInput("min.flow.nbr", "Minimum Flow:",
                                   0, min = 0, max = 10 * 9,
                                   width = "120px"),
                      numericInput("max.flow.nbr", "Maximum Flow:",
                                   NA, min = 0, max = 10 * 9,
                                   width = "120px")
               ),
               column(width = 4,
                      tags$br(),
                      checkboxGroupInput("gages.nbr", NULL,
                                         c("Luke" = "luke",
                                           "Little Falls" = "lfalls"),
                                         selected = c("luke", "lfalls")),
                      actionButton("reset.nbr", "Reset"),
                      actionButton("clear.nbr", "Clear")
               )
             ) # End fluidRow
           ) # End wellPanel
         ) # fluidRow
) # End tabPanel