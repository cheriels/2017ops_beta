tabPanel("North Branch Release",
         fluidRow(
           align = "center",
           plotOutput("nbr", height = plot.height, width = plot.width),
           br(),
           #wellPanel(
           #  align = "middle",
          #   style = "background-color: #ffffff;",
             column(width = 12, offset = 0, align = "left",
                    textOutput("nbr_notification_1")
           )
         #) # wellPanel
         ) # End fluidRow
) # End tabPanel