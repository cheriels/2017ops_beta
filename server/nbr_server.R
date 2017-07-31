#----------------------------------------------------------------------------
observeEvent(input$reset.nbr, {
  updateCheckboxGroupInput(session, "gages.nbr", 
                           selected = c("luke", "lfalls"))
})
#----------------------------------------------------------------------------
observeEvent(input$clear.nbr, {
  updateCheckboxGroupInput(session, "gages.nbr", "Variables to show:",
                           c("Luke" = "luke",
                             "Little Falls" = "lfalls"),
                           selected = NULL)
})
#----------------------------------------------------------------------------
nbr.df <- reactive({
  todays.date <- todays.date()
  start.date <- start.date()
  end.date <- end.date()
  #----------------------------------------------------------------------------
  sub.df <- hourly.reac() %>% 
    dplyr::filter(date_time >= start.date - lubridate::days(3) &
                    date_time <= end.date + lubridate::days(1))
  #----------------------------------------------------------------------------
  if (nrow(sub.df) == 0 ) return(NULL)
  #----------------------------------------------------------------------------
  final.df <- sub.df
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
                           "luke" = "Luke"),
            linetype.vec = c("lfalls" = "solid",
                             "luke" = "solid"),
            color.vec = c("lfalls" = "#0072B2",
                          "luke" = "#009E73"),
            x.class = "datetime",
            y.lab = y.units())
}) # End output$nbr
#------------------------------------------------------------------------------


