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
  todays.date <- todays.date()
  start.date <- start.date()
  end.date <- end.date()
  #----------------------------------------------------------------------------
  sub.df <- hourly.reac() %>% 
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
  start.date <- start.date()
  end.date <- end.date()
  #----------------------------------------------------------------------------
  gen_plots(odo.df(),
            start.date,
            end.date, 
            min.flow = input$min.flow,
            max.flow = input$max.flow,
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
                          "predicted" = "#56B4E9"),
            x.class = "datetime",
            y.lab = y.units())
}) # End output$odo


