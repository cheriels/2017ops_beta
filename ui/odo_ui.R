tabPanel("One-Day Operations",
           fluidRow(
             align = "center",
             plotOutput("odo", height = plot.height, width = plot.width),
             br()
           ) # End fluidRow
) # End tabPanel