tabPanel("Demand Time Series",
         fluidRow(
           align = "center",
           plotOutput("dts", height = plot.height, width = plot.width),
           br()
         ) # fluidRow
) # End tabPanel