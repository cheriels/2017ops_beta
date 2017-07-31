#----------------------------------------------------------------------------
observeEvent(input$reset.nbr, {
  updateCheckboxGroupInput(session, "gages.nbr", 
                           selected = c("luke", "lfalls", "lfalls_pred"))
})
#----------------------------------------------------------------------------
observeEvent(input$clear.nbr, {
  updateCheckboxGroupInput(session, "gages.nbr", "Variables to show:",
                           c("Luke" = "luke",
                             "Little Falls" = "lfalls",
                             "Little Falls (Low Flow Prediction)" = "lfalls_pred"),
                           selected = NULL)
})
#----------------------------------------------------------------------------
nbr.df <- reactive({
  todays.date <- todays.date()
  start.date <- start.date()
  end.date <- end.date()
  #----------------------------------------------------------------------------
  sub.df <- hourly.reac() #%>% 
#    dplyr::filter(date_time >= start.date - lubridate::days(3) &
#                    date_time <= end.date + lubridate::days(1))
  #----------------------------------------------------------------------------
  if (nrow(sub.df) == 0 ) return(NULL)
  #----------------------------------------------------------------------------
  lfalls.obs <- sub.df %>% 
    dplyr::filter(gage == "lfalls") %>% 
    rolling_min(flow, 240, "obs") %>% 
    dplyr::filter(gage == "obs")
  
  lfalls.pred <- lowflow.hourly.reac() %>% 
    dplyr::filter(gage == "lfalls_sim") %>% 
    rolling_min(flow, 240, "sim")
  
  lfalls.df <- dplyr::bind_rows(lfalls.obs, lfalls.pred) %>% 
    tidyr::spread(gage, flow) %>% 
    dplyr::filter(!is.na(obs)) %>% 
    dplyr::mutate(lfalls_pred = lfalls_sim - (sim - obs)) %>% 
    dplyr::select(date_time, lfalls_pred) %>% 
    tidyr::gather(gage, flow, lfalls_pred)

  #----------------------------------------------------------------------------
  final.df <- dplyr::bind_rows(sub.df, lfalls.df)
  #----------------------------------------------------------------------------
  return(final.df)
})
#------------------------------------------------------------------------------
output$nbr <- renderPlot({
  start.date <- start.date()
  end.date <- end.date()
  #----------------------------------------------------------------------------
  gen_plots(nbr.df(),
            start.date,
            end.date, 
            min.flow = input$min.flow,
            max.flow = input$max.flow,
            gages.checked = input$gages.nbr,
            labels.vec = c("lfalls" = "Little Falls",
                           "lfalls_pred" = "Little Falls (Low Flow Prediction)",
                           "luke" = "Luke"),
            linetype.vec = c("lfalls" = "solid",
                             "lfalls_pred" = "dashed",
                             "luke" = "solid"),
            color.vec = c("lfalls" = "#0072B2",
                          "lfalls_pred" = "#56B4E9",
                          "luke" = "#009E73"),
            x.class = "datetime",
            y.lab = y.units())
}) # End output$nbr
#------------------------------------------------------------------------------


