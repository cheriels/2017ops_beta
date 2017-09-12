#----------------------------------------------------------------------------
observeEvent(input$reset.sa, {
  updateCheckboxGroupInput(session, "gages.sa", 
                           selected = c("por", "mon_jug", "lfalls",
                                        "lfalls_from_upstr", "lfalls_trigger"))
})
#----------------------------------------------------------------------------
observeEvent(input$clear.sa, {
  updateCheckboxGroupInput(session, "gages.sa", "Variables to show:",
                           c("Point of Rocks" = "por",
                             "Monacacy" = "mon_jug",
                             "Little Falls" = "lfalls",
                             "Little Falls (Predicted from upstream gages)" = "lfalls_from_upstr",
                             "Little Falls trigger for drought ops" = "lfalls_trigger"),
                           selected = NULL)
})
#------------------------------------------------------------------------------
sa.df <- reactive({
  if (is.null(daily.reac())) return(NULL)
  todays.date <- todays.date()
  start.date <- start.date()
  end.date <- end.date()
  #----------------------------------------------------------------------------
  sub.df <- daily.reac() %>% 
    #select(date_time, lfalls, por, monocacy) %>% 
    select(date_time, site, flow) %>% 
    dplyr::filter(date_time >= start.date - lubridate::days(3),
                  date_time <= end.date + lubridate::days(1),
                  site %in% c("lfalls", "por", "mon_jug"))
  if (nrow(sub.df) == 0 ) return(NULL)
  #----------------------------------------------------------------------------
  # recess and lag POR flows
  por.df <- sub.df %>% 
    constant_lagk(por, todays.date, lag.days = 1)
  #----------------------------------------------------------------------------
  # recess and lag Monocacy flows
  mon.df <- por.df %>% 
    constant_lagk(mon_jug, todays.date, lag.days = 1)
  #----------------------------------------------------------------------------
  pot_withdrawals.sub <- withdrawals.reac() %>% 
    dplyr::filter(site == "potomac_total") %>% 
    dplyr::mutate(flow = flow + 100,
                  site = "lfalls_trigger") %>% 
    dplyr::select(site, date_time, flow) %>% 
    dplyr::rename(site = site,
                  flow = flow)
  #----------------------------------------------------------------------------
  final.df <- dplyr::bind_rows(mon.df, pot_withdrawals.sub) %>% 
    tidyr::spread(site, flow) %>% 
    dplyr::mutate(lfalls_from_upstr = por_recess_lag + mon_jug_recess_lag) %>% 
    dplyr::select(date_time, lfalls, por, mon_jug,
                  lfalls_from_upstr, lfalls_trigger) %>% 
    tidyr::gather(site, flow, lfalls:lfalls_trigger)
  
  return(final.df)
})
#----------------------------------------------------------------------------
output$sa <- renderPlot({
  start.date <- start.date()
  end.date <- end.date()
  #----------------------------------------------------------------------------
  gen_plots(sa.df(),
            start.date,
            end.date, 
            min.flow = input$min.flow,
            max.flow = input$max.flow,
            gages.checked = input$gages.sa,
            labels.vec = c("lfalls" = "Little Falls",
                           "lfalls_from_upstr" = "Little Falls (Predicted from upstream gages)",
                           "por" = "Point of Rocks",
                           "mon_jug" = "Monacacy",
                           "lfalls_trigger" = "Little Falls trigger for drought ops"),
            linesize.vec = c("lfalls" = 2,
                             "lfalls_from_upstr" = 1.5,
                             "por" = 2,
                             "mon_jug" = 2,
                             "lfalls_trigger" = 1.5),
            linetype.vec = c("lfalls" = "solid",
                             "lfalls_from_upstr" = "dashed",
                             "por" = "solid",
                             "mon_jug" = "solid",
                             "lfalls_trigger" = "dashed"),
            color.vec = c("lfalls" = "#0072B2",
                          "lfalls_from_upstr" = "#56B4E9",
                          "por" = "#E69F00",
                          "mon_jug" = "#9f00e6",
                          "lfalls_trigger" = "#FF0000"),
            x.class = "date",
            y.lab = y.units())
}) # End output$sa
#------------------------------------------------------------------------------
source("server/sa/sa_notifications.R", local = TRUE)
#------------------------------------------------------------------------------

