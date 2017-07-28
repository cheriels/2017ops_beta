gen_plots <- function(data.df, start.date, end.date,
                      min.flow, max.flow = NA,
                      gages.checked,
                      labels.vec, linetype.vec, color.vec,
                      x.lab = "Date Time", y.lab = "Flow (CFS)") {
  #--------------------------------------------------------------------------
  #todays.date <- as.Date(input$today.override)
  start.date <- as.Date(start.date) %>% 
    paste("00:00:00") %>% 
    as.POSIXct()
  end.date <- as.Date(end.date) %>% 
    paste("00:00:00") %>% 
    as.POSIXct()
  #----------------------------------------------------------------------------
#  if (start.date > end.date) return(NULL)
#  if (max(hourly.df$date_time) < start.date - lubridate::days(3)) {
#    start.date <- max(hourly.df$date_time) - lubridate::days(3)
#  }
  #----------------------------------------------------------------------------
  if (is.null(data.df)) {
    sub.df <- NULL
  } else {
    sub.df <- dplyr::filter(data.df, gage %in% gages.checked,
                            date_time >= start.date  &
                              date_time <= end.date)
  }
  #----------------------------------------------------------------------------
  validate(
    need(nrow(sub.df) != 0,
         "No data available for the selected date range. Please select a new date range."),
    need(length(gages.checked) != 0,
         "No variables selected. Please check at least one checkbox.")
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
                          values = linetype.vec) +
    # Has to be in alphabetical order
    scale_colour_manual(name = "type",
                        labels = labels.vec,
                        values = color.vec) +
    
    theme_minimal() +
    xlab(x.lab) +
    ylab(y.lab) +
    theme(legend.title = element_blank(),
          legend.text = element_text(size = 15),
          axis.text = element_text(size = 15),
          axis.title = element_text(size = 15)) +
    scale_x_datetime(limits = c(start.date, end.date))
  if (!is.na(min.flow) || !is.na(max.flow)) {
    final.plot <- final.plot + ylim(min.flow, max.flow)
  }
  #----------------------------------------------------------------------------
  return(final.plot)
}


