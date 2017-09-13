tabPanel("Situational Awareness",
         fluidRow(
           align = "center",
           plotOutput("sa", height = plot.height, width = plot.width)
         ), # End fluidRow
         br(),
         source("ui/sa/sa_wellpanel.R", local = TRUE)$value
) # End tabPanel
