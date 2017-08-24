#----------------------------------------------------------------------------
observeEvent(input$reset.nbr, {
  updateCheckboxGroupInput(session, "gages.nbr", 
                           selected = c("luke", "lfalls", "lfalls_lffs"))
})
#----------------------------------------------------------------------------
observeEvent(input$clear.nbr, {
  updateCheckboxGroupInput(session, "gages.nbr", "Variables to show:",
                           c("Luke" = "luke",
                             "Little Falls" = "lfalls",
                             "Little Falls (Low Flow Forecast System)" = "lfalls_lffs"),
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
    dplyr::filter(!is.na(sim)) %>% 
    tidyr::fill(obs) %>% 
    dplyr::mutate(lfalls_lffs = lfalls_sim - (sim - obs)) %>% 
    dplyr::select(date_time, lfalls_lffs) %>% 
    tidyr::gather(gage, flow, lfalls_lffs)
  
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
                           "lfalls_lffs" = "Little Falls (Low Flow Forecast System)",
                           "luke" = "Luke"),
            linesize.vec = c("lfalls" = 2,
                             "lfalls_lffs" = 1.5,
                             "luke" = 2),
            linetype.vec = c("lfalls" = "solid",
                             "lfalls_lffs" = "dashed",
                             "luke" = "solid"),
            color.vec = c("lfalls" = "#0072B2",
                          "lfalls_lffs" = "#56B4E9",
                          "luke" = "#009E73"),
            x.class = "datetime",
            y.lab = y.units(),
            nine_day.df = NULL#lfalls.natural.mgd()
            )
}) # End output$nbr
#------------------------------------------------------------------------------
# Adding our estimate of flow at Little Falls in 9 days

# First need to create Little Falls "natural" flow - without effects of JRR and Savage dams and withdrawals:
cfs_to_mgd <- 1.547
lfalls.natural.mgd <- reactive({
  daily.df %>%
    # First subtract off flow augmentation due to JR and Savage dams:
    mutate(lfalls_natural = round(lfalls/cfs_to_mgd),
           net_nbr_aug = (barnum - kitzmiller + bloomington - barton)/cfs_to_mgd,
           lfalls_natural = lfalls_natural - (lag(net_nbr_aug, n = 8) + lag(net_nbr_aug, n = 9) + lag(net_nbr_aug, n = 10))/3) %>% 
    left_join(withdrawals.df[, c("date_time", "potomac_total")], by = "date_time") %>% 
    # Then eliminate effect of WMA withdrawals:
    mutate(lfalls_natural = lfalls_natural + potomac_total,
           lfalls_9dayfc = 288.79 * exp(0.0009 * lfalls_natural) + luke - potomac_total,
           lfalls_9dayfc = dplyr::lead(lfalls_9dayfc, 9)) %>% 
    filter(date_time == todays.date() + 9) %>%
    select(date_time, lfalls_9dayfc)
})
# Zach: what I want to do is plot the ordered pair: (t = today + 9, flow = lfalls_9dayfc(today))


