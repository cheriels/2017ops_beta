
#----------------------------------------------------------------------------
observeEvent(input$reset.sa, {
 updateCheckboxGroupInput(session, "gages.sa", 
                          selected = c("por", "lfalls", "lfalls_from_upstr", "lfalls_trigger"))
})
#----------------------------------------------------------------------------
observeEvent(input$clear.sa, {
  updateCheckboxGroupInput(session, "gages.sa", "Variables to show:",
                           c("Point of Rocks" = "por",
                             "Little Falls" = "lfalls",
                             "Little Falls (Predicted)" = "lfalls_from_upstr",
                             "Little Falls trigger for drought ops" = "lfalls_trigger"),
                           selected = NULL)
})
#------------------------------------------------------------------------------
sa.df <- reactive({
  todays.date <- todays.date()
  start.date <- start.date()
  end.date <- end.date()
  #----------------------------------------------------------------------------
  sub.df <- daily.reac() %>% 
    select(date_time, lfalls, por, monocacy) %>% 
    dplyr::filter(date_time >= start.date - lubridate::days(3) &
                    date_time <= end.date + lubridate::days(1))
  if (nrow(sub.df) == 0 ) return(NULL)
  por.df <- sub.df %>% 
    constant_lagk(por, todays.date, lag.days = 1)
  #----------------------------------------------------------------------------
  pot_withdrawals.sub <- #withdrawals.reac() %>% 
    withdrawals.df %>% 
    dplyr::select(-fw_griffith_prod, - wssc_patuxent_prod) %>% 
    # Used "+" instead of rowSums to be more specific.
    dplyr::mutate(pot_withdrawals = wa_greatfalls + wa_littlefalls + 
                    fw_potomac_prod + wssc_potomac_prod) %>% 
    dplyr::mutate(lfalls_trigger = pot_withdrawals + 100) %>%
    dplyr::select(date_time, lfalls_trigger)
#    dplyr::rename(date = date_time)
  #----------------------------------------------------------------------------
  por.df <- por.df %>% 
#    tidyr::separate(date_time, into = c("date", "time"), convert = TRUE,
#                    sep = " ", remove = FALSE) %>% 
#    dplyr::mutate(date = as.Date(date)) %>% 
    dplyr::left_join(pot_withdrawals.sub, by = "date_time")
#    dplyr::select(-date, -time) %>% 
#    dplyr::mutate(flow = if_else(gage == "predicted", flow - withdrawals, flow)) %>% 
#    dplyr::select(-withdrawals)
  #----------------------------------------------------------------------------
  #----------------------------------------------------------------------------
  # recess and lag Monocacy flows
  final.df <- por.df %>% 
    constant_lagk(monocacy, todays.date, lag.days = 1) %>% 
    # Predict Little Falls from POR and Monocacy
    mutate(lfalls_from_upstr = por_recess_lag + monocacy_recess_lag) %>% 
    select(date_time, lfalls, por, lfalls_from_upstr, lfalls_trigger) %>% 
    filter(date_time > start.date & date_time < end.date) %>% 
    tidyr::gather(gage, flow, lfalls:lfalls_trigger) %>% 
    na.omit()
  
  return(final.df)
})
#----------------------------------------------------------------------------
output$sa <- renderPlot({
  
  gen_plots(sa.df(),
            start.date = input$date.range[1],
            end.date = input$date.range[2], 
            min.flow = input$min.flow,
            max.flow = input$max.flow,
            gages.checked = input$gages.sa,
            labels.vec = c("lfalls" = "Little Falls",
                           "lfalls_from_upstr" = "Little Falls (Predicted)",
                           "por" = "Point of Rocks",
                           "lfalls_trigger" = "Little Falls trigger for drought ops"),
            linetype.vec = c("lfalls" = "solid",
                             "lfalls_from_upstr" = "dashed",
                             "por" = "solid",
                             "lfalls_trigger" = "dashed"),
            color.vec = c("lfalls" = "#0072B2",
                          "lfalls_from_upstr" = "#56B4E9",
                          "por" = "#E69F00",
                          "lfalls_trigger" = "#FF0000"),
            x.class = "date",
            y.lab = y.units())
}) # End output$sa
#----------------------------------------------------------------------------
output$sa_notification_1 <- renderText({
  x <- daily.df %>%
    filter(date_time == todays.date())
  xx <- round(x$lfalls[1]/1.547) # convert cfs to mgd
  y <- withdrawals.df %>%
    filter(date_time == todays.date())
  yy <- y$wa_greatfalls[1] + y$wa_littlefalls[1] + y$fw_potomac_prod[1] + y$wssc_potomac_prod[1] + 100
  paste("Today's flow at Little Falls flow is ", xx, "MGD. The trigger for drought operations is ", yy, " MGD.")
})