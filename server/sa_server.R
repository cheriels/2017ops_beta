
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
    tidyr::gather(gage, flow, lfalls:lfalls_trigger) %>% 
    na.omit()
  
  return(final.df)
})
#----------------------------------------------------------------------------
output$sa <- renderPlot({
  start.date <- start.date()
  end.date <- end.date()
  #----------------------------------------------------------------------------
  gen_plots(sa.df(),
            start.date,
            end.date, 
            min.flow = input$min.flow,
            max.flow = input$max.flow,
            gages.checked = input$gages.sa,
            labels.vec = c("lfalls" = "Little Falls",
                           "lfalls_from_upstr" = "Little Falls (Predicted)",
                           "por" = "Point of Rocks",
                           "lfalls_trigger" = "Little Falls trigger for drought ops"),
            linesize.vec = c("lfalls" = 2,
                             "lfalls_from_upstr" = 1.5,
                             "por" = 2,
                             "lfalls_trigger" = 1.5),
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
# This is very crude, but my first try at adding notifications
# first, for flow at Little Falls and total Potomac withdrawals:
x <- daily.df %>%
  mutate(lfalls_mgd = round(lfalls/1.547)) # convert cfs to mgd
withdrawals.df <- withdrawals.df %>%
  mutate(potomac_total = wa_greatfalls + wa_littlefalls + fw_potomac_prod + wssc_potomac_prod)
output$sa_notification_1 <- renderText({
#  x <- daily.df %>%
  x <- x %>%
    select(date_time, lfalls_mgd) %>%
    filter(date_time == todays.date()) %>%
    select(lfalls_mgd)
  y <- withdrawals.df %>%
    filter(date_time == todays.date()) %>%
    select(potomac_total)
  paste("Today's flow at Little Falls flow is ", x, " MGD, and yesterday's total Potomac withdrawal was ", y, " MGD.")
})
# Next, the trigger for drought ops - as stated in the original Drought Manual
# (but actually needs to be any time over the next 5 days)
output$sa_notification_2 <- renderText({
  y <- withdrawals.df %>%
    filter(date_time == todays.date()) %>%
    select(potomac_total)
  y <- y + 100
  paste("The trigger for drought operations: observed flow at Little Falls = ", y, " MGD.")
})
# Next the LFAA's trigger for the Alert Stage
output$sa_notification_3 <- renderText({
  y <- withdrawals.df %>%
    filter(date_time == todays.date()) %>%
    select(potomac_total)
  paste("The trigger for the LFAA Alert Stage: observed flow at Little Falls = ", y, " MGD.")
})
# Next the LFAA's trigger for the Restriction Stage
output$sa_notification_4 <- renderText({
  y <- withdrawals.df %>%
    filter(date_time == todays.date()) %>%
    select(potomac_total)  
  y <- y*0.25
  paste("The trigger for the LFAA Restriction Stage is ", y, " MGD.")
})
# Notification for the LFAA Alert Stage
# Notification for the LFAA Restriction Stage