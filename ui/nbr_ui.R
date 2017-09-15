tabPanel("North Branch Release",
         fluidRow(
           align = "center",
           plotOutput("nbr", height = plot.height, width = plot.width),
           br()
         ) # End fluidRow
) # End tabPanel