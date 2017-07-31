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
  hourly.sub <- hourly.reac() %>% 
    dplyr::select(date_time, por,  lfalls, marfc) %>% 
    dplyr::filter(date_time >= start.date - lubridate::days(3) &
                    date_time <= end.date + lubridate::days(1))
  #----------------------------------------------------------------------------
  if (nrow(hourly.sub) == 0 ) return(NULL)
  #----------------------------------------------------------------------------
  lagk.df <- hourly.sub %>% 
    variable_lagk(por, "por_1", klag.df) %>% 
    tidyr::gather(gage, flow, 2:ncol(.)) %>% 
    dplyr::filter(!is.na(flow))
  #----------------------------------------------------------------------------
  withdrawals.sub <- #withdrawals.reac() %>% 
    withdrawals.df %>% 
    dplyr::select(-fw_griffith_prod, - wssc_patuxent_prod) %>% 
    # Used "+" instead of rowSums to be more specific.
    dplyr::mutate(withdrawals = wa_greatfalls + wa_littlefalls + 
                    fw_potomac_prod + wssc_potomac_prod) %>% 
    dplyr::select(date_time, withdrawals) %>% 
    dplyr::rename(date = date_time)
  #----------------------------------------------------------------------------
  final.df <- lagk.df %>% 
    tidyr::separate(date_time, into = c("date", "time"), convert = TRUE,
                    sep = " ", remove = FALSE) %>% 
    dplyr::mutate(date = as.Date(date)) %>% 
    dplyr::left_join(withdrawals.sub, by = "date") %>% 
    dplyr::select(-date, -time) %>% 
    dplyr::mutate(flow = if_else(gage == "predicted", flow - withdrawals, flow)) %>% 
    dplyr::select(-withdrawals)
  #----------------------------------------------------------------------------
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


