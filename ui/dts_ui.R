tabPanel("Demand Time Series",
         fluidRow(
           # Sidebar with a slider input for number of bins 
           column(width = 3,
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
                               width = "120px"),
                  numericInput("max.flow.dts", "Maximum Flow:",
                               NA, min = 0, max = 10 * 9,
                               width = "120px")
           ),
           column(width = 5,
                  tags$br(),
                  
                  tags$div(align = 'left', 
                           class = 'multicol', 
                           checkboxGroupInput("gages.dts", NULL,
                                              c("wa_greatfalls" = "wa_greatfalls",
                                                "wa_littlefalls" = "wa_littlefalls",
                                                "fw_potomac_prod" = "fw_potomac_prod",
                                                "fw_griffith_prod" = "fw_griffith_prod",
                                                "wssc_potomac_prod" = "wssc_potomac_prod",
                                                "wssc_patuxent_prod" = "wssc_patuxent_prod"),
                                              selected = c("wa_greatfalls", "wa_littlefalls", 
                                                           "fw_potomac_prod", "fw_griffith_prod",  
                                                           "wssc_potomac_prod", "wssc_patuxent_prod"),
                                              inline = F)),
                  actionButton("reset.dts", "Reset"),
                  actionButton("clear.dts", "Clear")
           )
         ),
         tags$hr(),
         fluidRow(
           plotOutput("dts", width = "100%")
         )
)