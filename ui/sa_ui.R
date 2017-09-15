tabPanel("Situational Awareness",
         fluidRow(
           align = "center",
           plotOutput("sa", height = plot.height, width = plot.width),
           br()
         ) # End fluidRow
) # End tabPanel
