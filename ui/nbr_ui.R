tabPanel("North Branch Release",
         fluidRow(
           align = "center",
           plotOutput("nbr", height = plot.height, width = plot.width)
         ), # fluidRow
         fluidRow(
           column(width = 12, offset = 1, align = "left", textOutput("nbr_notification_1")
           ) # End column
         ) # End fluidRow
) # End tabPanel