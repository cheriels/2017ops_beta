tabPanel("Demand Time Series",
         fluidRow(
           fluidRow(
             align = "center",
             plotOutput("dts", height = "350px", width = "95%")
           ),
           #-------------------------------------------------------------------
           wellPanel(
             fluidRow(
               # Sidebar with a slider input for number of bins 
               column(width = 4,
                      #align = "center",
                      dateInput("today.override.dts", 
                                paste0("Today's Date (", Sys.Date(), "):"),
                                width = "200px"),
                      dateRangeInput("date.range.dts",
                                     "Date Range:", 
                                     start = Sys.Date() - 5,
                                     end = Sys.Date() + 5,
                                     width = "200px")),
               column(width = 4,
                      numericInput("min.flow.dts", "Minimum Flow:",
                                   0, min = 0, max = 10 * 9,
                                   width = "120px"),
                      numericInput("max.flow.dts", "Maximum Flow:",
                                   NA, min = 0, max = 10 * 9,
                                   width = "120px")
               ),
               column(width = 3,
                      tags$head(tags$style(HTML(".multicol{font-size:15px;
                                                  height:auto;
                                                  -webkit-column-count: 2;
                                                  -moz-column-count: 2;
                                                  column-count: 2;
                                                  }

                                                  div.checkbox {margin-top: 0px;}"
                                                )) 
                      ),
                      tags$div(align = "left", 
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
                                                  inline = TRUE)),
                      actionButton("reset.dts", "Reset"),
                      actionButton("clear.dts", "Clear")
               )
             ) # End fluidRow
           ) # End wellPanel
         ) # fluidRow
) # End tabPanel