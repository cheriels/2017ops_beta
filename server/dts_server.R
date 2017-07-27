#----------------------------------------------------------------------------
observeEvent(input$reset.dts, {
  updateCheckboxGroupInput(session, "gages.dts", 
                           selected = c("wa_greatfalls", "wa_littlefalls", 
                                        "fw_potomac_prod", "fw_griffith_prod",  
                                        "wssc_potomac_prod", "wssc_patuxent_prod"))
})
#----------------------------------------------------------------------------
observeEvent(input$clear.dts, {
  updateCheckboxGroupInput(session, "gages.dts", "Variables to show:",
                           c("wa_greatfalls" = "wa_greatfalls",
                             "wa_littlefalls" = "wa_littlefalls",
                             "fw_potomac_prod" = "fw_potomac_prod",
                             "fw_griffith_prod" = "fw_griffith_prod",
                             "wssc_potomac_prod" = "wssc_potomac_prod",
                             "wssc_patuxent_prod" = "wssc_patuxent_prod"),
                           selected = NULL)
})
#----------------------------------------------------------------------------
output$dts <- renderPlot({
  #--------------------------------------------------------------------------
  #todays.date <- as.Date(input$today.override)
  start.date <- as.Date(input$date.range.dts[1])# %>% 
#    paste("00:00:00") %>% 
#    as.POSIXct()
  end.date <- as.Date(input$date.range.dts[2])# %>% 
#    paste("00:00:00") %>% 
#    as.POSIXct()
  #--------------------------------------------------------------------------
  sub.df <- withdrawals.df %>% 
#    dplyr::select(date_time, luke, lfalls) %>% 
    dplyr::filter(date_time >= start.date - lubridate::days(3) &
                    date_time <= end.date + lubridate::days(1)) %>% 
    tidyr::gather(gage, flow, 2:ncol(.)) %>% 
    dplyr::filter(!is.na(flow))
  #----------------------------------------------------------------------------
#  labels.vec <- c("Little Falls", "Luke")
  #----------------------------------------------------------------------------
  sub.df <- dplyr::filter(sub.df, gage %in% input$gages.dts,
                          date_time >= start.date  &
                            date_time <= end.date)
  if (nrow(sub.df) == 0) return(NULL)
  #----------------------------------------------------------------------------
  # plot flows
  final.plot <- ggplot(sub.df, aes(x = date_time, y = flow,
                                   color = gage)) + 
    geom_line(size = 2) +
    # Has to be in alphabetical order
#    scale_linetype_manual(name = "type",
#                          labels = labels.vec,
#                          values = c("lfalls" = "solid",
#                                     "luke" = "solid")) +
    # Has to be in alphabetical order
#    scale_colour_manual(name = "type",
#                        labels = labels.vec,
#                        values = c("lfalls" = "#0072B2",
#                                   "luke" = "#009E73")) +
    
    theme_minimal() +
    xlab("Date") +
    ylab("Flow (MGD)") +
    theme(legend.title = element_blank(),
          legend.text = element_text(size = 15),
          axis.text = element_text(size = 15),
          axis.title = element_text(size = 15)) +
    scale_x_date(limits = c(start.date, end.date))
  if (!is.na(input$min.flow.dts) || !is.na(input$max.flow.dts)) {
    final.plot <- final.plot + ylim(input$min.flow.dts, input$max.flow.dts)
  }
  final.plot
}) # End output$marfc

