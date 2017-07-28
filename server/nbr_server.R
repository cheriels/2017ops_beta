# Update the dateRangeInput if start date changes
observeEvent(input$date.range.nbr, {
  date_standards(name = "date.range.nbr",
                 session,
                 start.date = input$date.range.nbr[1],
                 end.date = input$date.range.nbr[2],
                 min.range = 1)
})
#----------------------------------------------------------------------------
observeEvent(input$reset.nbr, {
  updateCheckboxGroupInput(session, "gages.nbr", 
                           selected = c("luke", "lfalls"))
})
#----------------------------------------------------------------------------
observeEvent(input$clear.nbr, {
  updateCheckboxGroupInput(session, "gages.nbr", "Variables to show:",
                           c("Luke" = "luke",
                             "Little Falls" = "lfalls"),
                           selected = NULL)
})
#----------------------------------------------------------------------------
output$nbr <- renderPlot({
  #--------------------------------------------------------------------------
  #todays.date <- as.Date(input$today.override)
  start.date <- as.Date(input$date.range.nbr[1]) %>% 
    paste("00:00:00") %>% 
    as.POSIXct()
  end.date <- as.Date(input$date.range.nbr[2]) %>% 
    paste("00:00:00") %>% 
    as.POSIXct()
  #--------------------------------------------------------------------------
  sub.df <- hourly.df %>% 
    dplyr::select(date_time, luke, lfalls) %>% 
    dplyr::filter(date_time >= start.date - lubridate::days(3) &
                    date_time <= end.date + lubridate::days(1)) %>% 
    tidyr::gather(gage, flow, 2:ncol(.)) %>% 
    dplyr::filter(!is.na(flow))
  #--------------------------------------------------------------------------
  labels.vec <- c("lfalls" = "Little Falls",
                  "luke" = "Luke")
  #----------------------------------------------------------------------------
  sub.df <- dplyr::filter(sub.df, gage %in% input$gages.nbr,
                          date_time >= start.date  &
                            date_time <= end.date)
  #--------------------------------------------------------------------------
  validate(
    need(nrow(sub.df) != 0,
         "No data available for the selected date range. Please select a new date range.")
  )
  #----------------------------------------------------------------------------
  # plot flows
  final.plot <- ggplot(sub.df, aes(x = date_time, y = flow,
                                   color = gage,
                                   linetype = gage)) + 
    geom_line(size = 2) +
    # Has to be in alphabetical order
    scale_linetype_manual(name = "type",
                          labels = labels.vec,
                          values = c("lfalls" = "solid",
                                     "luke" = "solid")) +
    # Has to be in alphabetical order
    scale_colour_manual(name = "type",
                        labels = labels.vec,
                        values = c("lfalls" = "#0072B2",
                                   "luke" = "#009E73")) +
    
    theme_minimal() +
    xlab("Date Time") +
    ylab("Flow (CFS)") +
    theme(legend.title = element_blank(),
          legend.text = element_text(size = 15),
          axis.text = element_text(size = 15),
          axis.title = element_text(size = 15)) +
    scale_x_datetime(limits = c(start.date, end.date))
  if (!is.na(input$min.flow.nbr) || !is.na(input$max.flow.nbr)) {
    final.plot <- final.plot + ylim(input$min.flow.nbr, input$max.flow.nbr)
  }
  final.plot
}) # End output$marfc


