wellPanel(
  fluidRow(
    column(width = 2,
           #align = "center",
           tags$style(type='text/css', "#large .selectize-input { line-height: 60px; }"),
           dateInput("today.override", 
                     paste0("Today's Date (", Sys.Date(), "):"),
                     value = Sys.Date(),
                     #paste0("Today's Date (", "2017-07-25", "):"),
                     #value = "2017-07-25",
                     width = "250px"),
           div(id = "large",
               dateRangeInput("date.range",
                              "Date Range:", 
                              start = Sys.Date() - lubridate::days(30),
                              end = Sys.Date() + lubridate::days(30),
                              width = "250px"))
    ),
    column(width = 2,
           selectInput("data.dir", "Data Directory:",
                       c("Current" = "current",
                         "Drex2017" = "drex2017"),
                       width = "250px")
    ),
    column(width = 1,
           numericInput("min.flow", "Minimum Flow:",
                        0, min = 0, max = 10 * 9,
                        width = "125px"),
           numericInput("max.flow", "Maximum Flow:",
                        NA, min = 0, max = 10 * 9,
                        width = "125px")
    ),
    column(width = 1,
           selectInput("flow.units", "Flow Units:",
                       c("CFS" = "cfs",
                         "MGD" = "mgd"),
                       width = "125px")
    ),
    column(width = 6,
           conditionalPanel("input.tab == 'Situational Awareness'",
                            checkboxGroupInput("gages.sa",  NULL,
                                               c("Point of Rocks" = "por",
                                                 "Monacacy" = "mon_jug",
                                                 "Little Falls" = "lfalls",
                                                 "Little Falls (Predicted from upstream gages)" = "lfalls_from_upstr",
                                                 "Little Falls trigger for drought ops" = "lfalls_trigger"),
                                               selected = c("por",  "lfalls",
                                                            "lfalls_from_upstr", "lfalls_trigger")),
                            actionButton("reset.sa", "Reset"),
                            actionButton("clear.sa", "Clear")
           ), # End Conditional Panel Situational Awareness
           conditionalPanel("input.tab == 'One-Day Operations'",
                            checkboxGroupInput("gages.odo", NULL,
                                               c("Point of Rocks" = "por",
                                                 "Little Falls" = "lfalls",
                                                 "Variable Lag-K" = "predicted",
                                                 "MARFC Forecast" = "marfc"),
                                               selected = c("por", "lfalls",
                                                            "predicted", "marfc")),
                            actionButton("reset.odo", "Reset"),
                            actionButton("clear.odo", "Clear")
           ), # End Conditional Panel North Branch Release
           conditionalPanel("input.tab == 'North Branch Release'",
                            checkboxGroupInput("gages.nbr", NULL,
                                               c("Luke" = "luke",
                                                 "Little Falls" = "lfalls",
                                                 "Little Falls (Low Flow Forecast System)" = "lfalls_lffs"),
                                               selected = c("luke", "lfalls", "lfalls_lffs")),
                            actionButton("reset.nbr", "Reset"),
                            actionButton("clear.nbr", "Clear")
           ), # End Conditional Panel One-Day Operations
           conditionalPanel("input.tab == 'Demand Time Series'",
                            column(6,
                                   align = "left",
                                   #uiOutput("day.dd.dts"),
                                   uiOutput("supplier.dd.dts")
                            ),
                            column(6,
                                   uiOutput("gages.dts"),
                                   actionButton("reset.dts", "Reset"),
                                   actionButton("clear.dts", "Clear")
                            )
           ) # End Conditional Panel One-Day Operations
    )
  ), # End fluidRow
  conditionalPanel("input.tab == 'Situational Awareness'",
                   fluidRow(
                     hr(),
                     column(width = 12,
                            align = "left",
                            textOutput("sa_notification_1"),
                            tags$head(
                              tags$style(
                                HTML("#sa_notification_1{
                                     color: #FF0000;
                                     height:40px;
                                     font-size: 20px;
                                     font-style: italic;}"
                                )
                              )
                            )
                     ),# End column
                     column(width = 12, #offset = 1, align = "left",
                            tags$ul(
                              tags$li(textOutput("sa_notification_2")),
                              tags$li(textOutput("sa_notification_3")),
                              tags$li(textOutput("sa_notification_4"))
                            )
                     )
                   )
  ),
  conditionalPanel("input.tab == 'North Branch Release'",
                   fluidRow(
                     hr(),
                     column(width = 12, offset = 0, align = "left",
                            textOutput("nbr_notification_1")
                     )
                   )
  )#,
  #style = "padding: 25px;"
  ) # End wellPanel
