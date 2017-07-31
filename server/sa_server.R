
#----------------------------------------------------------------------------
observeEvent(input$reset.sa, {
 updateCheckboxGroupInput(session, "gages.sa", 
                          selected = c("por", "lfalls", "lfalls_from_upstr"))
})
#----------------------------------------------------------------------------
observeEvent(input$clear.sa, {
  updateCheckboxGroupInput(session, "gages.sa", "Variables to show:",
                           c("Point of Rocks" = "por",
                             "Little Falls" = "lfalls",
                             "Little Falls (Predicted)" = "lfalls_from_upstr"),
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
  # recess and lag Monocacy flows
  final.df <- por.df %>% 
    constant_lagk(monocacy, todays.date, lag.days = 1) %>% 
    # Predict Little Falls from POR and Monocacy
    mutate(lfalls_from_upstr = por_recess_lag + monocacy_recess_lag) %>% 
    select(date_time, lfalls, por, lfalls_from_upstr) %>% 
    filter(date_time > start.date & date_time < end.date) %>% 
    tidyr::gather(gage, flow, lfalls:lfalls_from_upstr) %>% 
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
                           "por" = "Point of Rocks"),
            linetype.vec = c("lfalls" = "solid",
                             "lfalls_from_upstr" = "dashed",
                             "por" = "solid"),
            color.vec = c("lfalls" = "#0072B2",
                          "lfalls_from_upstr" = "#56B4E9",
                          "por" = "#E69F00"),
            x.class = "date",
            y.lab = y.units())
}) # End output$sa
