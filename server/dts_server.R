
output$gages.dts <- renderUI({
  if (is.null(dts.df())) return(NULL)
  checkboxGroupInput("gages.dts", NULL,
                     unique(dts.df()$site),
                     selected = unique(dts.df()$site),
                     inline = FALSE)
})
#----------------------------------------------------------------------------
observeEvent(input$reset.dts, {
  updateCheckboxGroupInput(session, "gages.dts", 
                           selected = unique(dts.df()$site))
})
#----------------------------------------------------------------------------
observeEvent(input$clear.dts, {
  updateCheckboxGroupInput(session, "gages.dts", "Variables to show:",
                           unique(dts.df()$site),
                           selected = NULL)
})
#----------------------------------------------------------------------------
output$day.dd.dts <- renderUI({
  day.vector <- withdrawals.reac() %>% 
    dplyr::select(day) %>% 
    dplyr::distinct() %>% 
    dplyr::mutate(day = stringi::stri_trans_general(day, id = "Title")) %>% 
    dplyr::pull(day)
  
  selectInput("day.dd.dts", "Day:",
              day.vector,
              width = "250px")
})

#----------------------------------------------------------------------------
output$supplier.dd.dts <- renderUI({
  if (is.null(withdrawals.reac())) return(NULL)
  selectInput("supplier.dd.dts", "Supplier:",
              c("All Suppliers", unique(withdrawals.reac()$supplier)),
              width = "250px")
})

dts.df <- reactive({
  if (is.null(withdrawals.reac())) return(NULL)
  todays.date <- todays.date()
  start.date <- start.date()
  end.date <- end.date()
  #----------------------------------------------------------------------------
  final.df <- withdrawals.reac() %>% 
    #    dplyr::select(date_time, luke, lfalls) %>% 
    dplyr::filter(date_time >= start.date - lubridate::days(3),
                    date_time <= end.date + lubridate::days(1)) %>% 
#                  day %in% tolower(input$day.dd.dts)) %>% 
    dplyr::filter(!is.na(flow))
  
  if (!is.null(input$supplier.dd.dts) && input$supplier.dd.dts != "All Suppliers") {
    final.df <- final.df %>% 
      dplyr::filter(supplier %in% input$supplier.dd.dts)
  }
  
  if (nrow(final.df) == 0 ) return(NULL)

  return(final.df)
})
#----------------------------------------------------------------------------
output$dts <- renderPlot({
  start.date <- start.date()
  end.date <- end.date()
  #----------------------------------------------------------------------------
  gen_plots(dts.df(),
            start.date,
            end.date, 
            min.flow = input$min.flow,
            max.flow = input$max.flow,
            gages.checked = input$gages.dts,
            labels.vec = NULL,
            linesize.vec = NULL,
            linetype.vec = NULL,
            color.vec = NULL,
            x.class = "date",
            y.lab = y.units())
}) # End output$dts


