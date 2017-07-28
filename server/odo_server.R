# Update the dateRangeInput if start date changes
observeEvent(input$date.range.odo, {
  date_standards(name = "date.range.odo",
                 session,
                 start.date = input$date.range.odo[1],
                 end.date = input$date.range.odo[2],
                 min.range = 1)
})
#----------------------------------------------------------------------------
observeEvent(input$reset.odo, {
  updateCheckboxGroupInput(session, "gages.odo", 
                           selected = c("por", "lfalls",
                                        "predicted", "marfc"))
})
#----------------------------------------------------------------------------
observeEvent(input$clear.odo, {
  updateCheckboxGroupInput(session, "gages.odo", "Variables to show:",
                           c("Point of Rocks" = "por",
                             "Little Falls" = "lfalls",
                             "Variable Lag-K" = "predicted",
                             "MARFC Forecast" = "marfc"),
                           selected = NULL)
})
#----------------------------------------------------------------------------
odo.df <- reactive({
  start.date <- as.Date(input$date.range.odo[1]) %>% 
    paste("00:00:00") %>% 
    as.POSIXct()
  end.date <- as.Date(input$date.range.odo[2]) %>% 
    paste("00:00:00") %>% 
    as.POSIXct()
  
  sub.df <- hourly.df %>% 
    dplyr::select(date_time, por, lfalls, marfc) %>% 
    dplyr::filter(date_time >= start.date - lubridate::days(3) &
                    date_time <= end.date + lubridate::days(1))
  if (nrow(sub.df) == 0 ) return(NULL)
  final.df <- sub.df %>% 
    variable_lagk(por, "por_1", klag.df) %>% 
    tidyr::gather(gage, flow, 2:ncol(.)) %>% 
    dplyr::filter(!is.na(flow))
  
  return(final.df)
})
#----------------------------------------------------------------------------
output$odo <- renderPlot({
  
  gen_plots(odo.df(),
            start.date = input$date.range.odo[1],
            end.date = input$date.range.odo[2], 
            min.flow = input$min.flow.odo,
            max.flow = input$max.flow.odo,
            gages.checked = input$gages.odo,
            labels.vec = c("por" = "Point of Rocks",
                           "lfalls" = "Little Falls",
                           "predicted" = "Predicted",
                           "marfc" = "MARFC Forecast"),
            linetype.vec = c("lfalls" = "solid",
                             "marfc" = "dashed",
                             "por" = "solid",
                             "predicted" = "dashed"),
            color.vec = c("lfalls" = "#0072B2",
                          "marfc" = "#009E73",
                          "por" = "#E69F00",
                          "predicted" = "#56B4E9"))
}) # End output$odo


