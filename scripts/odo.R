
#----------------------------------------------------------------------------
output$odo<- renderPlot({
  #--------------------------------------------------------------------------
  #todays.date <- as.Date(input$today.override)
  start.date <- as.Date(input$date.range.odo[1]) %>% 
    paste("00:00:00") %>% 
    as.POSIXct()
  end.date <- as.Date(input$date.range.odo[2]) %>% 
    paste("00:00:00") %>% 
    as.POSIXct()
  #--------------------------------------------------------------------------
  sub.df <- marfc.df %>% 
    dplyr::filter(date_time >= start.date & date_time <= end.date)
  #--------------------------------------------------------------------------
  labels.vec <- c("Forecast", "Observed")
  breaks.vec <- c("forecast", "observed")
  #----------------------------------------------------------------------------
  # plot flows
  final.plot <- ggplot(sub.df, aes(x = date_time, y = flow,
                                     color = type,
                                     linetype = type)) + 
    geom_line(size = 2) +
    # Has to be in alphabetical order
    scale_linetype_manual(name = "type",
                          labels = labels.vec,
                          breaks = breaks.vec, 
                          values = c("dashed", "solid")) +
    # Has to be in alphabetical order
    scale_colour_manual(name = "type",
                        labels = labels.vec,
                        breaks = breaks.vec, 
                        values = c("#56B4E9", "#0072B2")) +
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


