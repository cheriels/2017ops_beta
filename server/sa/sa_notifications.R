#----------------------------------------------------------------------------
# Adding notifications based on yesterday's total Potomac withdrawals:
tot.withdrawal <- reactive({
  req(!is.null(todays.date()))
  if (is.null(withdrawals.df())) return(NULL)
  with.scalar <- withdrawals.df() %>%
    filter(date_time == todays.date() - lubridate::days(1),
           site == "potomac_total") %>%
    pull(flow)
  if (length(with.scalar) == 0) return(NULL)
  return(with.scalar)
})
#----------------------------------------------------------------------------
cfs_to_mgd <- 1.547
lfalls.today.mgd <- reactive({
  req(!is.null(todays.date()))
  if (is.null(daily.df())) return(NULL)
  lfalls.scalar <- daily.df() %>%
    filter(date_time == todays.date(),
           site == "lfalls") %>%
#    mutate(flow = round(flow / cfs_to_mgd)) %>% 
    mutate(flow = round(flow)) %>% 
    pull(flow)
  if (length(lfalls.scalar) == 0) return(NULL)
  return(lfalls.scalar)
})
#----------------------------------------------------------------------------
output$sa_notification_1 <- renderText({
  if (is.null(lfalls.today.mgd()) && is.null(tot.withdrawal())) {
    paste("Today's flow at Little Falls flow",
          "and",
          "yesterday's total Potomac withdrawal",
          "cannot be calculated for the currently selected 'Todays Date'.")
  } else if (!is.null(lfalls.today.mgd()) && is.null(tot.withdrawal())) {
    paste("Today's flow at Little Falls flow is ",
          lfalls.today.mgd(),
          input$flow.units,
          " but",
          "yesterday's total Potomac withdrawal",
          "cannot be calculated for the currently selected 'Todays Date'.")
  } else if (is.null(lfalls.today.mgd()) && !is.null(tot.withdrawal())) {
    paste("Today's flow at Little Falls flow",
          "cannot be calculated for the currently selected 'Todays Date'",
          "but",
          "yesterday's total Potomac withdrawal was",
          tot.withdrawal(),
          " MGD.")
  } else if (!is.null(lfalls.today.mgd()) && !is.null(tot.withdrawal())) {
    paste("Today's flow at Little Falls flow is ",
          lfalls.today.mgd(), 
          input$flow.units,
          " , and yesterday's total Potomac withdrawal was ",
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
# Next the LFAA's threshold for the Alert Stage: LFAA pp. 11-12 gives the threshold 
# in terms of "adjusted flow": W > 0.5*Qadj (where Qadj = Qobs + W, 
# and W is total WMA Potomac withdrawals). Converting to observed flow, the threshold is:
# Qobs = W (both values from yesterday, calculated from midnight to midnight)
output$sa_notification_3 <- renderText({
  if (is.null(tot.withdrawal())) {
    paste("The threshold for the LFAA Alert Stage: observed flow at Little Falls",
          "cannot be calculated for the currently selected 'Todays Date'.")
  } else {
    paste("The threshold for the LFAA Alert Stage: observed flow at Little Falls = ",
          tot.withdrawal(),
          " MGD.")
  }
})
#----------------------------------------------------------------------------
# Next the LFAA's threshold for the Restriction Stage, 
# given in the Memorandum of Intent, p. 2, 3., is W + 100 > 0.8*Qadj (in mgd)
# or Qobs < W/4 + 125 mgd:

output$sa_notification_4 <- renderText({
  if (is.null(tot.withdrawal())) {
    paste("The threshold for the LFAA Restriction Stage",
          "cannot be calculated for the currently selected 'Todays Date'.")
  } else {
    paste("The threshold for the LFAA Restriction Stage is ",
          tot.withdrawal() * 0.25 + 125,
          " MGD.")
  }
})
#----------------------------------------------------------------------------