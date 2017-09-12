

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
                             "Little Falls (Predicted from upstream gages)" = "lfalls_from_upstr",
                             "Little Falls trigger for drought ops" = "lfalls_trigger"),
                           selected = NULL)
})
#------------------------------------------------------------------------------
sa.df <- reactive({
  if (is.null(daily.reac())) return(NULL)
  todays.date <- todays.date()
  start.date <- start.date()
  end.date <- end.date()
  #----------------------------------------------------------------------------
  sub.df <- daily.reac() %>% 
    #select(date_time, lfalls, por, monocacy) %>% 
    select(date_time, site, flow) %>% 
    dplyr::filter(date_time >= start.date - lubridate::days(3),
                  date_time <= end.date + lubridate::days(1),
                  site %in% c("lfalls", "por", "mon_jug"))
  if (nrow(sub.df) == 0 ) return(NULL)
  #----------------------------------------------------------------------------
  # recess and lag POR flows
  por.df <- sub.df %>% 
    constant_lagk(por, todays.date, lag.days = 1)
  #----------------------------------------------------------------------------
  # recess and lag Monocacy flows
  mon.df <- por.df %>% 
    constant_lagk(mon_jug, todays.date, lag.days = 1)
  #----------------------------------------------------------------------------
  pot_withdrawals.sub <- withdrawals.reac() %>% 
    dplyr::filter(unique_id == "potomac_total") %>% 
    dplyr::mutate(value = value + 100,
                  unique_id = "lfalls_trigger") %>% 
    dplyr::select(unique_id, date_time, value) %>% 
    dplyr::rename(site = unique_id,
                  flow = value)
  #----------------------------------------------------------------------------
  final.df <- dplyr::bind_rows(mon.df, pot_withdrawals.sub)
  
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
                           "lfalls_from_upstr" = "Little Falls (Predicted from upstream gages)",
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
tot.withdrawal <- reactive({
  if (is.null(withdrawals.df())) return(NULL)
  with.scalar <- withdrawals.df() %>%
    filter(date_time == todays.date(),
           unique_id == "potomac_total") %>%
    pull(value)
  if (length(with.scalar) == 0) return(NULL)
  return(with.scalar)
})
#----------------------------------------------------------------------------
cfs_to_mgd <- 1.547
lfalls.today.mgd <- reactive({
  if (is.null(daily.df())) return(NULL)
  lfalls.scalar <- daily.df() %>%
    filter(date_time == todays.date(),
           site == "lfalls") %>%
    mutate(flow = round(flow / cfs_to_mgd)) %>% 
    pull(flow)
  if (length(lfalls.scalar) == 0) return(NULL)
  return(lfalls.scalar)
})
#----------------------------------------------------------------------------
output$sa_notification_1 <- renderText({
  if (is.null(lfalls.today.mgd()) & is.null(tot.withdrawal())) {
    paste("Today's flow at Little Falls flow",
          "and",
          "yesterday's total Potomac withdrawal",
          "cannot be calculated for the currently selected 'Todays Date'.")
  } else if (!is.null(lfalls.today.mgd()) & is.null(tot.withdrawal())) {
    paste("Today's flow at Little Falls flow is ",
          lfalls.today.mgd(), 
          "but",
          "yesterday's total Potomac withdrawal",
          "cannot be calculated for the currently selected 'Todays Date'.")
  } else if (is.null(lfalls.today.mgd()) & !is.null(tot.withdrawal())) {
    paste("Today's flow at Little Falls flow",
          "cannot be calculated for the currently selected 'Todays Date'",
          "but",
          "yesterday's total Potomac withdrawal was",
          tot.withdrawal(),
          " MGD.")
  } else if (!is.null(lfalls.today.mgd()) & !is.null(tot.withdrawal())) {
    paste("Today's flow at Little Falls flow is ",
          lfalls.today.mgd(), 
          " MGD, and yesterday's total Potomac withdrawal was ",
          tot.withdrawal(),
          " MGD.")
  }
})
#----------------------------------------------------------------------------
# Next, the trigger for drought ops - as stated in the original Drought Manual
# (but actually needs to be any time over the next 5 days)
output$sa_notification_2 <- renderText({
  if (is.null(tot.withdrawal())) {
    paste("The trigger for drought operations: observed flow at Little Falls",
          "cannot be calculated for the currently selected 'Todays Date'.")
  } else {
    paste("The trigger for drought operations: observed flow at Little Falls = ",
          tot.withdrawal() + 100,
          " MGD.")
  }
})
#----------------------------------------------------------------------------
# Next the LFAA's trigger for the Alert Stage
output$sa_notification_3 <- renderText({
  if (is.null(tot.withdrawal())) {
    paste("The trigger for the LFAA Alert Stage: observed flow at Little Falls",
          "cannot be calculated for the currently selected 'Todays Date'.")
  } else {
    paste("The trigger for the LFAA Alert Stage: observed flow at Little Falls = ",
          tot.withdrawal(),
          " MGD.")
  }
})
#----------------------------------------------------------------------------
# Next the LFAA's trigger for the Restriction Stage
output$sa_notification_4 <- renderText({
  if (is.null(tot.withdrawal())) {
    paste("The trigger for the LFAA Restriction Stage",
          "cannot be calculated for the currently selected 'Todays Date'.")
  } else {
    paste("The trigger for the LFAA Restriction Stage is ",
          tot.withdrawal() * 0.25 + 125,
          " MGD.")
  }
})
#----------------------------------------------------------------------------
