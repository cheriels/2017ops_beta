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
    dplyr::filter(date_time >= start.date - lubridate::days(3) &
                    date_time <= end.date + lubridate::days(1))
  #----------------------------------------------------------------------------
  if (nrow(hourly.sub) == 0 ) return(NULL)
  #----------------------------------------------------------------------------
  
  variable_confluence <- function(long1.df, gage1, lag1, long2.df,gage2, lag2, klag.df) {
    g1.df <- variable_lagk(long1.df, gage1, lag1, klag.df)
    g2.df <- variable_lagk(long2.df, gage2, lag2, klag.df)
    final.df <- bind_rows(long2.df, g1.df, g2.df) %>% 
      group_by(date_time, gage) %>% 
      summarize(flow = sum(flow)) %>% 
      ungroup()
    return(final.df)
  }
  
  conf.1 <- variable_confluence(hourly.df, "por", "por_1", 
                                hourly.df, "monocacy", "mon_jug", klag.df)
  conf.2 <- variable_confluence(conf.1, "predicted", "por_2",
                                hourly.df, "goose", "goose", klag.df)
  conf.3 <- variable_confluence(conf.2, "predicted", "por_3",
                                hourly.df, "seneca", "seneca", klag.df)
  pred.df <- variable_lagk(conf.3, "predicted", "por_4", klag.df)
  lagk.df <- bind_rows(hourly.df, pred.df)
  #----------------------------------------------------------------------------
  withdrawals.sub <- withdrawals.reac() %>% 
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
    dplyr::mutate(flow = if_else(gage == "predicted", flow - (withdrawals), flow)) %>% 
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
                           "predicted" = "Little Falls (Predicted)",
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


