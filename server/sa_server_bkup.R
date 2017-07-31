
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



output$constant_lagk <- renderPlot({
  #--------------------------------------------------------------------------
  todays.date <- as.Date(input$today.override.sa)
  start.date <- as.Date(input$date.range.sa[1])
  end.date <- as.Date(input$date.range.sa[2])
  #--------------------------------------------------------------------------
  # Add recessions and lags - want to do this using function in future!
  upstr.df <- daily.df %>% 
    select(date, lfalls, por, monocacy) %>% 
    dplyr::filter(date >= start.date - lubridate::days(3) &
                    date <= end.date + lubridate::days(1)) %>% 
    constant_lagk(por, todays.date, start.date, lag.days = 1)
  #--------------------------------------------------------------------------
  # recess and lag Monocacy flows
  upstr.df <- upstr.df %>% 
    constant_lagk(monocacy, todays.date, start.date, lag.days = 1) %>% 
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
  #--------------------------------------------------------------------------
    validate(
      need(nrow(sub.df) != 0,
           "No data available for the selected date range. Please select a new date range.")
    )
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
