tabPanel("Situational Awareness",
         fluidRow(
           align = "center",
           plotOutput("sa", height = plot.height, width = plot.width)
         ), # End fluidRow
         fluidRow(
           column(width = 12,
                  align = "center",
                  textOutput("sa_notification_1"),
                  tags$head(tags$style(HTML("#sa_notification_1{
                                       color: red;
                                       font-size: 20px;
                                       font-style: italic;
                                                              }"
                                           )
                                       )
                            )
                  ) # End column
         ) # End fluidRow
) # End tabPanel