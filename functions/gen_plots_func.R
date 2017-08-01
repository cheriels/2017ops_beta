gen_plots <- function(data.df, start.date, end.date,
                      min.flow, max.flow = NA,
                      gages.checked,
                      labels.vec = NULL, linesize.vec = NULL,
                      linetype.vec = NULL, color.vec = NULL,
                      x.class,
                      x.lab = "Date Time", y.lab = "Flow (CFS)") {
  #--------------------------------------------------------------------------
  start.date <- as.Date(start.date)
  end.date <- as.Date(end.date)
  if (x.class == "datetime") {
    start.date <- start.date  %>% 
      paste("00:00:00") %>% 
      as.POSIXct()
    end.date <- end.date  %>% 
      paste("00:00:00") %>% 
      as.POSIXct()
  }
  #----------------------------------------------------------------------------
  #  if (start.date > end.date) return(NULL)
  #  if (max(hourly.df$date_time) < start.date - lubridate::days(3)) {
  #    start.date <- max(hourly.df$date_time) - lubridate::days(3)
  #  }
  validate(
    need(length(gages.checked) != 0,
         "No variables selected. Please check at least one checkbox.")
  )
  #----------------------------------------------------------------------------
  if (is.null(data.df)) {
    sub.df <- NULL
  } else {
    sub.df <- data.df %>% 
      dplyr::filter(gage %in% gages.checked,
                    date_time >= start.date  &
                      date_time <= end.date)
  }
  #----------------------------------------------------------------------------
  validate(
    need(nrow(sub.df) != 0,
         "No data available for the selected date range. Please select a new date range.")
    
  )
  #----------------------------------------------------------------------------
  gage.vec <- unique(sub.df$gage)
  if (is.null(labels.vec)) labels.vec <- gage.vec
  #----------------------------------------------------------------------------
  # plot flows
  final.plot <- ggplot(sub.df, aes(x = date_time, y = flow,
                                   color = gage,
                                   linetype = gage,
                                   size = gage)) + 
    geom_line() +
    theme_minimal() +
    xlab(x.lab) +
    ylab(y.lab) +
    theme(legend.title = element_blank(),
          legend.text = element_text(size = 15),
          axis.text = element_text(size = 15),
          axis.title = element_text(size = 15))
  if (is.null(labels.vec)) labels.vec <- unique(sub.df$gages)
  #----------------------------------------------------------------------------
  if (!is.null(linesize.vec)) {
    final.plot <- final.plot + scale_size_manual(name = "type",
                                                 labels = labels.vec,
                                                 values = linesize.vec)
  } else {
    final.plot <- final.plot + scale_size_manual(name = "type",
                                                 labels = labels.vec,
                                                 values = rep(2, length(labels.vec)))
  }
  #----------------------------------------------------------------------------
  if (!is.null(linetype.vec)) {
    final.plot <- final.plot + scale_linetype_manual(name = "type",
                                                     labels = labels.vec,
                                                     values = linetype.vec)
  } else {
    final.plot <- final.plot + scale_linetype_manual(name = "type",
                                                     labels = labels.vec,
                                                     values = rep("solid", length(labels.vec)))
  } 
  #----------------------------------------------------------------------------
  if (!is.null(color.vec)) {
    final.plot <- final.plot + scale_colour_manual(name = "type",
                                                   labels = labels.vec,
                                                   values = color.vec)
  } else {
    final.plot <- final.plot + scale_colour_manual(name = "type",
                                                   labels = labels.vec,
                                                   values = c("#b30000", "#b3b300",
                                                              "#00b300", "#0072b2",
                                                              "#8600b3", "#b30059"))
  }
  #----------------------------------------------------------------------------
  if (x.class == "date") {
    final.plot <- final.plot + scale_x_date(limits = c(start.date, end.date))
  } else if (x.class == "datetime") {
    final.plot <- final.plot + scale_x_datetime(limits = c(start.date, end.date))
  }
  
  if (!is.null(min.flow) || !is.null(max.flow)) {
    final.plot <- final.plot + ylim(min.flow, max.flow)
  }
  #----------------------------------------------------------------------------
  return(final.plot)
}


