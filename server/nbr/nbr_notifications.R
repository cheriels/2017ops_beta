#----------------------------------------------------------------------------
# Notifications related to the 9-day forecast and North Branch release:
tot.withdrawal <- reactive({
  if (is.null(withdrawals.df())) return(NULL)
  with.scalar <- withdrawals.df() %>%
    filter(date_time == todays.date(),
           site == "potomac_total") %>%
    pull(flow)
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
output$nbr_notification_1 <- renderText({
  if (is.null(lfalls.natural.mgd.today()) & is.null(tot.withdrawal())) {
    paste("Little Falls flow today",
          "and",
          "yesterday's total Potomac withdrawal",
          "cannot be calculated for the currently selected 'Todays Date'.")
  } else if (!is.null(lfalls.today.mgd()) & is.null(tot.withdrawal())) {
    paste("Little Falls flow today  ",
          lfalls.today.mgd(), 
          "but",
          "yesterday's total Potomac withdrawal",
          "cannot be calculated for the currently selected 'Todays Date'.")
  } else if (is.null(lfalls.today.mgd()) & !is.null(tot.withdrawal())) {
    paste("Little Falls flow today ",
          "cannot be calculated for the currently selected 'Todays Date'",
          "but",
          "yesterday's total Potomac withdrawal was",
          tot.withdrawal(),
          " MGD.")
  } else if (!is.null(lfalls.today.mgd()) & !is.null(tot.withdrawal())) {
    paste("Little Falls flow today is ",
#          lfalls.natural.mgd.today()$lfalls_natural0,
          lfalls.today.mgd(),
          " MGD and natural flow at Little Falls is estimated to be ",
          lfalls.natural.mgd.today()$lfalls_natural,
          " MGD. The total of Potomac withdrawals today, and estimated in 9 days, is ",
          lfalls.natural.mgd.today()$potomac_total,
          " MGD; and the forecast for observed flow at Little Falls in 9 days is",
          lfalls.natural.mgd.today()$lfalls_9dayfc,
          " MGD")
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