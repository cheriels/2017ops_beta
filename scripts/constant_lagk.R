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
                           recess_init[todays.date - start.date + 1] * exp(-gage.k * recess_time)),
           recess_lag = lag(recess, lag.days)) %>% 
    select(-flow1, -flow2, - recess_init, -recess_time, - recess)
  
  names(final.df)[names(final.df) %in% "recess_lag"] <- paste(gage.string, "recess_lag", sep = "_")
  return(final.df)
}
#----------------------------------------------------------------------------
output$constant_lagk <- renderPlot({
  #--------------------------------------------------------------------------
  todays.date <- as.Date(input$today.override)
  start.date <- as.Date(input$date.range1[1])
  end.date <- as.Date(input$date.range1[2])
  #--------------------------------------------------------------------------
  # Add recessions and lags - want to do this using function in future!
  upstr.df <- flows.df %>% 
    select(date, lfalls, por, monocacy) %>% 
    lag_k(por, todays.date, start.date, lag.days = 1)
  #str(upstr)
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
  breaks.vec <- c("lfalls", "lfalls_from_upstr", "por")
  labels.vec <- c("Little Falls", "Little Falls (Predicted)", "Point of Rocks")
  #--------------------------------------------------------------------------
  
  # plot flows
  final.plot <- ggplot(upstr.df, aes(x = date, y = flow,
                       color = gage, size = gage,
                       linetype = gage)) + 
    geom_line() +
    # Has to be in alphabetical order
    scale_size_manual(name = "Station",
                      labels = labels.vec,
                      breaks = breaks.vec, 
                      values = c(2, 1, 1)) + 
    # Has to be in alphabetical order
    scale_linetype_manual(name = "Station",
                          labels = labels.vec,
                          breaks = breaks.vec, 
                          values = c("solid", "dashed", "solid")) +
    # Has to be in alphabetical order
    scale_colour_manual(name = "Station",
                        labels = labels.vec,
                        breaks = breaks.vec, 
                        values = c("#0072B2", "#56B4E9", "#E69F00")) +
    theme_minimal() +
    xlab("Date") +
    ylab("Flow (CFS)") +
    geom_hline(yintercept = 2000, color = "red",
               linetype = "longdash", size = 0.7) +
    theme(legend.title = element_blank(),
          legend.text = element_text(size = 15),
          axis.text = element_text(size = 15),
          axis.title = element_text(size = 15))
  if (!is.na(input$min.flow) || !is.na(input$max.flow)) {
    final.plot <- final.plot + ylim(input$min.flow, input$max.flow)
  }
  final.plot
  #--------------------------------------------------------------------------
  
  # plot flows
  #    flows <- subset(flows, date > as.Date(input$daterange1[1]) & date < as.Date(input$daterange1[2]))
  #    ggplot(flows, aes(x=date)) + geom_line(aes(y=lfalls, color="Little Falls"), size=2) +
  #          geom_line(aes(y=por, color="Point of Rocks"), size=1) +
  #          geom_line(aes(y=monocacy, color="Monocacy"), size=1) +
  #          scale_colour_manual(name="Station", breaks = c("Little Falls","Point of Rocks", "Monocacy"), values=c("skyblue1","green","blue"))
  
  
  
}) # End output$plot