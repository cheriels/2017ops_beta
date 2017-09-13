wellPanel(
  style = "background-color: #ffffff;",
  fluidRow(
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
    column(width = 12, offset = 1, align = "left",
           textOutput("sa_notification_2"),
           textOutput("sa_notification_3"),
           textOutput("sa_notification_4")
    )
)
)