tabPanel("Situational Awareness",
         fluidRow(
           align = "center",
           plotOutput("sa", height = plot.height, width = plot.width)
         ), # End fluidRow
         fluidRow(
           column(width = 12,
                  align = "left",
                  #tags$br(),
                  #tags$br(),
                  textOutput("sa_notification_1"),
                  tags$head(tags$style(HTML("#sa_notification_1{
                                       color: #FF0000;
                                       height:40px;
                                       font-size: 20px;
                                       font-style: italic;
                                                              }"
                  )
                  )
                  )
           ) # End column
         ), # End fluidRow
         fluidRow(
           column(width = 12,
                  align = "left",
                  #tags$br(),
                  #tags$br(),
                  textOutput("sa_notification_2"),
                  tags$head(tags$style(HTML("#sa_notification_2{
                                            color: #FF0000;
                                            height:30px;
                                            font-size: 16px;
                                            font-style: italic;
                                            }"
                  )
                  )
                  )
                  ) # End column
                  ), # End fluidRow
         fluidRow(
           column(width = 12,
                  align = "left",
                  #tags$br(),
                  #tags$br(),
                  textOutput("sa_notification_3"),
                  tags$head(tags$style(HTML("#sa_notification_3{
                                            color: #FF0000;
                                            height:30px;
                                            font-size: 16px;
                                            font-style: italic;
                                            }"
                  )
                  )
                  )
                  ) # End column
                  ), # End fluidRow
         fluidRow(
           column(width = 12,
                  align = "left",
                  #tags$br(),
                  #tags$br(),
                  textOutput("sa_notification_4"),
                  tags$head(tags$style(HTML("#sa_notification_4{
                                            color: #FF0000;
                                            height:30px;
                                            font-size: 16px;
                                            font-style: italic;
                                            }"
                  )
                  )
                  )
                  ) # End column
                  ) # End fluidRow
) # End tabPanel
