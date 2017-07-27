# Update the dateRangeInput if start date changes
observeEvent(input$date.range.odo, {
  start.date <- as.Date(input$date.range.odo[1])
  end.date <- as.Date(input$date.range.odo[2])
  # If end date is earlier than start date, update the end date to be the same as the new start date
  if (end.date < start.date) {
    end.date = start.date + 2
  }
  updateDateRangeInput(session, "date.range.odo", start = start.date,
                       end = end.date)
})
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
output$odo <- renderPlot({
  #--------------------------------------------------------------------------
  #todays.date <- as.Date(input$today.override)
  start.date <- as.Date(input$date.range.odo[1]) %>% 
    paste("00:00:00") %>% 
    as.POSIXct()
  end.date <- as.Date(input$date.range.odo[2]) %>% 
    paste("00:00:00") %>% 
    as.POSIXct()
  #--------------------------------------------------------------------------
  if (start.date > end.date) return(NULL)
  if (max(hourly.df$date_time) < start.date - lubridate::days(3)) {
    start.date <- max(hourly.df$date_time) - lubridate::days(3)
  }
  #--------------------------------------------------------------------------
  sub.df <- hourly.df %>% 
    dplyr::select(date_time, por, lfalls, marfc) %>% 
    dplyr::filter(date_time >= start.date - lubridate::days(3) &
                    date_time <= end.date + lubridate::days(1)) %>% 
    variable_lagk(por, "por_1", klag.df) %>% 
    tidyr::gather(gage, flow, 2:ncol(.)) %>% 
    dplyr::filter(!is.na(flow))
  #--------------------------------------------------------------------------
  labels.vec <- c("por" = "Point of Rocks",
                  "lfalls" = "Little Falls",
                  "predicted" = "Predicted",
                  "marfc" = "MARFC Forecast")
#  breaks.vec <- c("lfalls", "marfc", "por", "predicted")
  #----------------------------------------------------------------------------
  sub.df <- dplyr::filter(sub.df, gage %in% input$gages.odo,
                          date_time >= start.date  &
                            date_time <= end.date)
  if (nrow(sub.df) == 0) return(NULL)
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
                                     "marfc" = "dashed",
                                     "por" = "solid",
                                     "predicted" = "dashed")) +
    # Has to be in alphabetical order
    scale_colour_manual(name = "type",
                        labels = labels.vec,
                        values = c("lfalls" = "#0072B2",
                                   "marfc" = "#009E73",
                                   "por" = "#E69F00",
                                   "predicted" = "#56B4E9")) +
    
    theme_minimal() +
    xlab("Date Time") +
    ylab("Flow (CFS)") +
    theme(legend.title = element_blank(),
          legend.text = element_text(size = 15),
          axis.text = element_text(size = 15),
          axis.title = element_text(size = 15)) +
    scale_x_datetime(limits = c(start.date, end.date))
  if (!is.na(input$min.flow.odo) || !is.na(input$max.flow.odo)) {
    final.plot <- final.plot + ylim(input$min.flow.odo, input$max.flow.odo)
  }
  final.plot
}) # End output$marfc


