#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
# Constant Lag-K
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
# Constant Lag-K function.
lag_k <- function(flow.df, gage, todays.date, start.date, lag.days = 1) {
  gage <- rlang::enquo(gage)
  gage.string <- rlang::quo_name(gage)
  if (gage.string == "por") gage.k <- 0.042
  if (gage.string == "monocacy") gage.k <- 0.050
  #----------------------------------------------------------------------------
  final.df <- flow.df %>% 
    # recess and lag POR flows
    mutate(flow1 = lag(rlang::UQ(gage), n = 1),
           flow2 = lag(rlang::UQ(gage), n = 2),
           recess_init = pmin(rlang::UQ(gage), flow1, flow2), # pmin gives minimums of each row
           recess_time = ifelse(date - todays.date < 0, 0, date - todays.date),
           #recess_time = case_when(
           #  date - todays.date < 0 ~ 0,
           #  TRUE ~ date - today.date
           #),
           recess = ifelse(date < todays.date, rlang::UQ(gage), 
#                           recess_init[todays.date - start.date + 1] * exp(-gage.k * recess_time)),
                           recess_init[todays.date] * exp(-gage.k * recess_time)),
           recess_lag = lag(recess, lag.days)) %>% 
    select(-flow1, -flow2, - recess_init, -recess_time, - recess)
  
  names(final.df)[names(final.df) %in% "recess_lag"] <- paste(gage.string, "recess_lag", sep = "_")
  return(final.df)
}
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
#----------------------------------------------------------------------------
output$constant_lagk <- renderPlot({
  #--------------------------------------------------------------------------
  todays.date <- as.Date(input$today.override)
  start.date <- as.Date(input$date.range.sa[1])
  end.date <- as.Date(input$date.range.sa[2])
  #--------------------------------------------------------------------------
  # Add recessions and lags - want to do this using function in future!
  upstr.df <- daily.df %>% 
    select(date, lfalls, por, monocacy) %>% 
    dplyr::filter(date >= start.date - lubridate::days(3) &
                    date <= end.date + lubridate::days(1)) %>% 
    lag_k(por, todays.date, start.date, lag.days = 1)
  #--------------------------------------------------------------------------
  
  #--------------------------------------------------------------------------
  # recess and lag Monocacy flows
  upstr.df <- upstr.df %>% 
    lag_k(monocacy, todays.date, start.date, lag.days = 1) %>% 
    # Predict Little Falls from POR and Monocacy
    mutate(lfalls_from_upstr = por_recess_lag + monocacy_recess_lag) %>% 
    select(date, lfalls, por, lfalls_from_upstr) %>% 
    filter(date > start.date & date < end.date) %>% 
    tidyr::gather(gage, flow, lfalls:lfalls_from_upstr) %>% 
    na.omit()
  #--------------------------------------------------------------------------
  labels.vec <- c("lfalls" = "Little Falls",
                  "lfalls_from_upstr" = "Little Falls (Predicted)",
                  "por" = "Point of Rocks")
  #--------------------------------------------------------------------------
  sub.df <- dplyr::filter(upstr.df, gage %in% input$gages.sa)
  if (nrow(sub.df) == 0) return(NULL)
  #----------------------------------------------------------------------------
  # plot flows
  final.plot <- ggplot(sub.df, aes(x = date, y = flow,
                       color = gage, size = gage,
                       linetype = gage)) + 
    geom_line() +
    # Has to be in alphabetical order
    scale_size_manual(name = "Station",
                      labels = labels.vec,
                      values = c("lfalls" = 2,
                                 "lfalls_from_upstr" = 1,
                                 "por" = 1)) + 
    # Has to be in alphabetical order
    scale_linetype_manual(name = "Station",
                          labels = labels.vec,
                          values = c("lfalls" = "solid",
                                     "lfalls_from_upstr" = "dashed",
                                     "por" = "solid")) +
    # Has to be in alphabetical order
    scale_colour_manual(name = "Station",
                        labels = labels.vec,
                        values = c("lfalls" = "#0072B2",
                                   "lfalls_from_upstr" = "#56B4E9",
                                   "por" = "#E69F00")) +
    theme_minimal() +
    xlab("Date") +
    ylab("Flow (CFS)") +
    geom_hline(yintercept = 2000, color = "red",
               linetype = "longdash", size = 0.7) +
    theme(legend.title = element_blank(),
          legend.text = element_text(size = 15),
          axis.text = element_text(size = 15),
          axis.title = element_text(size = 15)) +
          #panel.background = element_rect(fill = NA),
          #panel.grid.major = element_line(colour = "#D3D3D3"),
          #panel.grid.minor = element_line(colour = "#DCDCDC")) + 
    scale_x_date(limits = c(start.date, end.date))
  if (!is.na(input$min.flow.sa) || !is.na(input$max.flow.sa)) {
    final.plot <- final.plot + ylim(input$min.flow.sa, input$max.flow.sa)
  }
  #plotly::ggplotly(final.plot, width = 1200)
  final.plot
  #--------------------------------------------------------------------------
  
  # plot flows
  #    flows <- subset(flows, date > as.Date(input$daterange1[1]) & date < as.Date(input$daterange1[2]))
  #    ggplot(flows, aes(x=date)) + geom_line(aes(y=lfalls, color="Little Falls"), size=2) +
  #          geom_line(aes(y=por, color="Point of Rocks"), size=1) +
  #          geom_line(aes(y=monocacy, color="Monocacy"), size=1) +
  #          scale_colour_manual(name="Station", breaks = c("Little Falls","Point of Rocks", "Monocacy"), values=c("skyblue1","green","blue"))
  
  
  
}) # End output$plot
