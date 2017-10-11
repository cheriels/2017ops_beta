odo.df <- reactive({
  todays.date <- as.POSIXct("2017-09-11")
  start.date <- todays.date - lubridate::days(10)
  end.date <- todays.date + lubridate::days(100)
  
  start.date <- start.date - lubridate::days(7)
  date.temp <- date_frame(start.date,
                          end.date,
                          "hours")
  #----------------------------------------------------------------------------
  hourly.sub <- hourly.df %>% 
    dplyr::filter(date_time >= start.date  &
                    date_time <= todays.date)
  #----------------------------------------------------------------------------
  req(nrow(hourly.sub) > 0)
  #----------------------------------------------------------------------------
  
  variable_confluence <- function(long1.df, gage1, lag1,
                                  long2.df, gage2, lag2, klag.df) {
    g1.df <- variable_lagk(long1.df, gage1, lag1, klag.df)
    g2.df <- variable_lagk(long2.df, gage2, lag2, klag.df)
    final.df <- bind_rows(long2.df, g1.df, g2.df) %>% 
      group_by(date_time, site) %>% 
      summarize(flow = sum(flow)) %>% 
      ungroup()
    return(final.df)
  }
  
  conf.1 <- variable_confluence(hourly.sub, "por", "por_1", 
                                hourly.sub, "mon_jug", "mon_jug", klag.df)
  conf.2 <- variable_confluence(conf.1, "predicted", "por_2",
                                hourly.sub, "goose", "goose", klag.df)
  conf.3 <- variable_confluence(conf.2, "predicted", "por_3",
                                hourly.sub, "seneca", "seneca", klag.df)
  pred.df <- variable_lagk(conf.3, "predicted", "por_4", klag.df)
  lagk.df <- bind_rows(hourly.sub, pred.df)
  #----------------------------------------------------------------------------
  withdrawals.sub <- withdrawals.df %>% 
    # Yesterday or Today??????????????????????????????????????????????????????????????????????
    dplyr::filter(measurement == "daily average withdrawals",
                  day == "yesterday") %>% 
    dplyr::select(date_time, site, flow) %>% 
    tidyr::spread(site, flow) %>% 
    dplyr::mutate(withdrawals = rowSums(.[, c('WA Potomac River at Great Falls daily average withdrawals',
                                              'WA Potomac River at Little Falls daily average withdrawals',
                                              'FW Potomac River daily average withdrawals',
                                              'WSSC Potomac River daily average withdrawals')],
                                        na.rm = TRUE)) %>% 
    dplyr::select(date_time, withdrawals) %>% 
    dplyr::rename(date = date_time)
  #----------------------------------------------------------------------------
  final.df <- lagk.df %>% 
    tidyr::separate(date_time, into = c("date", "time"), convert = TRUE,
                    sep = " ", remove = FALSE) %>% 
    dplyr::mutate(date = as.Date(date)) %>% 
    dplyr::left_join(withdrawals.sub, by = "date") %>% 
    dplyr::select(-date, -time) %>% 
    dplyr::mutate(flow2 = if_else(site == "predicted" & !is.na(withdrawals),
                                  flow - withdrawals,
                                  flow)) %>% 
    dplyr::select(-withdrawals) %>% 
    dplyr::filter(!is.na(flow))
  
  #----------------------------------------------------------------------------
  return(final.df)
})
#----------------------------------------------------------------------------
output$odo <- renderPlot({
  
  #----------------------------------------------------------------------------
  gen_plots(odo.df(),
            start.date(),
            end.date(), 
            min.flow = input$min.flow,
            max.flow = input$max.flow,
            gages.checked = input$gages.odo,
            labels.vec = c("por" = "Point of Rocks",
                           "lfalls" = "Little Falls",
                           "predicted" = "Little Falls (Predicted)",
                           "marfc" = "MARFC Forecast"),
            linesize.vec = c("lfalls" = 2,
                             "marfc" = 1.5,
                             "por" = 2,
                             "predicted" = 1.5),
            linetype.vec = c("lfalls" = "solid",
                             "marfc" = "dashed",
                             "por" = "solid",
                             "predicted" = "dashed"),
            color.vec = c("lfalls" = "#0072B2",
                          "marfc" = "#009E73",
                          "por" = "#E69F00",
                          "predicted" = 	"#56B4E9"),
            x.class = "datetime",
            y.lab = y.units())
}) # End output$odo
