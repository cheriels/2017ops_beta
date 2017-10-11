gen_plots <- function(data.df, start.date, end.date,
                      min.flow, max.flow = NA,
                      gages.checked,
                      labels.vec = NULL, linesize.vec = NULL,
                      linetype.vec = NULL, color.vec = NULL,
                      x.class,
                      x.lab = "Date Time", y.lab = "Flow (CFS)",
                      nine_day.df = NULL) {
  #--------------------------------------------------------------------------
  #  if (start.date > end.date) return(NULL)
  #  if (max(hourly.df$date_time) < start.date - lubridate::days(3)) {
  #    start.date <- max(hourly.df$date_time) - lubridate::days(3)
  #  }
  validate(
    need(length(gages.checked) != 0,
         "No variables selected. Please check at least one checkbox.")
  )
  #----------------------------------------------------------------------------
  validate(
    need(nrow(data.df) != 0 & !is.null(data.df),
         "No data available for the selected date range. Please select a new date range.")
  )
  #----------------------------------------------------------------------------
  start.date <- as.Date(start.date)%>% 
    paste("00:00:00") %>% 
    as.POSIXct()
  end.date <- as.Date(end.date)%>% 
    paste("00:00:00") %>% 
    as.POSIXct()
  period <- ifelse(x.class == "datetime", "hours", "days")
  
  #----------------------------------------------------------------------------
  sub.df <- data.df %>% 
    dplyr::filter(site %in% gages.checked) %>% 
    dplyr::mutate(date_time = as.POSIXct(date_time)) %>% 
    add_date_gaps(start.date, end.date, period)
  #,
  #                    date_time >= start.date - lubridate::days(3) &
  #                      date_time <= end.date + lubridate::days(1))
  #----------------------------------------------------------------------------
  site.vec <- unique(sub.df$site)
  if (is.null(labels.vec)) labels.vec <- site.vec
  #----------------------------------------------------------------------------
  # plot flows
  final.plot <- ggplot(sub.df, aes(x = date_time, y = flow,
                                   color = site,
                                   linetype = site,
                                   size = site)) + 
    geom_line(na.rm = TRUE) +
    theme_minimal() +
    xlab(x.lab) +
    ylab(y.lab) +
    theme(legend.title = element_blank(),
          legend.text = element_text(size = 15),
          axis.text = element_text(size = 15),
          axis.title = element_text(size = 15))
  if (is.null(labels.vec)) labels.vec <- unique(sub.df$site)
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
    final.plot <- final.plot + scale_colour_hue(name = "type",
                                                labels = labels.vec)
  }
  #----------------------------------------------------------------------------
  if (is.na(min.flow)) {
    min.flow <- sub.df %>% 
      dplyr::filter(date_time >= start.date,
                    date_time <= end.date) %>% 
      dplyr::mutate(min = min(flow, na.rm = TRUE)) %>% 
      dplyr::select(min) %>% 
      dplyr::distinct() %>% 
      dplyr::pull(min)
  } 
  if (is.na(max.flow)) {
    max.flow <- sub.df %>% 
      dplyr::filter(date_time >= start.date,
                    date_time <= end.date) %>% 
      dplyr::mutate(max = max(flow, na.rm = TRUE),
                    max = max * 0.05 + max) %>% 
      dplyr::select(max) %>% 
      dplyr::distinct() %>% 
      dplyr::pull(max)
  }
  #----------------------------------------------------------------------------   
  
  final.plot <- final.plot +
    coord_cartesian(xlim = c(start.date, end.date),
                    ylim = c(min.flow, max.flow),
                    expand = FALSE)
  if (!is.null(nine_day.df)) {
    nine_day.df <- nine_day.df %>% 
      mutate(date_time = date_time %>% 
               #as.Date() %>% 
               #paste("00:00:00") %>% 
               as.POSIXct())
    
    final.plot <- final.plot +
      geom_point(data = nine_day.df,
                 aes(x = date_time, y = lfalls_9dayfc),
                 inherit.aes = FALSE,
                 color = "black", 
                 shape = 1,
                 stroke = 2,
                 size = 10)
  }
  #----------------------------------------------------------------------------
  return(final.plot)
}


