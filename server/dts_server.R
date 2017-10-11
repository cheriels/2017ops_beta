
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
            labels.vec = c("WSSC Potomac River daily average withdrawals" = "WSSC Potomac River daily average withdrawals",
                           "WSSC Patuxent Reservoirs daily average withdrawals" = "WSSC Patuxent Reservoirs daily average withdrawals",
                           "WSSC Demand forecasted demand" = "WSSC Demand forecasted demand",
                           
                           "FW Potomac River daily average withdrawals" = "FW Potomac River daily average withdrawals",
                           "FW Occoquan Reservoir daily average withdrawals" = "FW Occoquan Reservoir daily average withdrawals",
                           "FW Demand forecasted demand" = "FW Demand forecasted demand",
                           
                           "WA Potomac River at Great Falls daily average withdrawals" = "WA Potomac River at Great Falls daily average withdrawals",
                           "WA Potomac River at Little Falls daily average withdrawals" = "WA Potomac River at Little Falls daily average withdrawals",
                           "WA Demand forecasted demand" = "WA Demand forecasted demand",
                           
                           "LW Broad Run daily discharge" = "LW Broad Run daily discharge",
                           "LW Broad Run estimated average discharge" = "LW Broad Run estimated average discharge",
                           
                           "potomac_total" = "potomac_total"),
            linesize.vec = c("WSSC Potomac River daily average withdrawals" = 2,
                             "WSSC Patuxent Reservoirs daily average withdrawals" = 2,
                             "WSSC Demand forecasted demand"  = 2,
                             
                             "FW Potomac River daily average withdrawals" = 	2,
                             "FW Occoquan Reservoir daily average withdrawals" = 2,
                             "FW Demand forecasted demand"  = 2,
                             
                             "WA Potomac River at Great Falls daily average withdrawals" = 2,
                             "WA Potomac River at Little Falls daily average withdrawals" = 2,
                             "WA Demand forecasted demand" = 	2,
                             
                             "LW Broad Run daily discharge" = 2,
                             "LW Broad Run estimated average discharge" = 2,
                             
                             "potomac_total" = 	2),
            linetype.vec = c("WSSC Potomac River daily average withdrawals" = "solid",
                             "WSSC Patuxent Reservoirs daily average withdrawals" = "solid",
                             "WSSC Demand forecasted demand"  = "solid",
                             
                             "FW Potomac River daily average withdrawals" = 	"solid",
                             "FW Occoquan Reservoir daily average withdrawals" = "solid",
                             "FW Demand forecasted demand"  = "solid",
                             
                             "WA Potomac River at Great Falls daily average withdrawals" = "solid",
                             "WA Potomac River at Little Falls daily average withdrawals" = "solid",
                             "WA Demand forecasted demand" = 	"solid",
                             
                             "LW Broad Run daily discharge" = "solid",
                             "LW Broad Run estimated average discharge" = "solid",
                             
                             "potomac_total" = 	"solid"),
            color.vec = c("WSSC Potomac River daily average withdrawals" = "#356478",
                          "WSSC Patuxent Reservoirs daily average withdrawals" = "#4d8fac",
                          "WSSC Demand forecasted demand"  = "#c9dde6",
                          
                          "FW Potomac River daily average withdrawals" = 	"#2e3967",
                          "FW Occoquan Reservoir daily average withdrawals" = "#4d60ac",
                          "FW Demand forecasted demand"  = "#b7bfdd",
                          
                          "WA Potomac River at Great Falls daily average withdrawals" = "#39672e",
                          "WA Potomac River at Little Falls daily average withdrawals" = "#8fac4d",
                          "WA Demand forecasted demand" = 	"#afd5a6",
                          
                          "LW Broad Run daily discharge" = "#783564",
                          "LW Broad Run estimated average discharge" = "#ddb7d2",
                          
                          "potomac_total" = 	"#AC4D60"),
            x.class = "date",
            y.lab = y.units())
}) # End output$dts


