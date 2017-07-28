observeEvent(input$date.range, {
  date_standards(name = "date.range",
                 session,
                 start.date = input$date.range[1],
                 end.date = input$date.range[2],
                 min.range = 3)
})
#------------------------------------------------------------------------------
todays.date <- reactive({
  todays.date <- as.Date(input$today.override) %>% 
    paste("00:00:00") %>% 
    as.POSIXct()
})
#------------------------------------------------------------------------------
start.date <- reactive({
  start.date <- as.Date(input$date.range[1]) %>% 
    paste("00:00:00") %>% 
    as.POSIXct()
})
#------------------------------------------------------------------------------
end.date <- reactive({
  end.date <- as.Date(input$date.range[2]) %>% 
    paste("00:00:00") %>% 
    as.POSIXct()
})
#------------------------------------------------------------------------------

