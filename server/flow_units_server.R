#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Change the y-axis labels.
y.units <- reactive({
  final.vec <- ifelse(input$flow.units == "cfs",
                      "Flow (CFS)", "Flow (MGD)")
  return(final.vec)
})
#------------------------------------------------------------------------------
daily.reac <- reactive({
  convert_flow(daily.df(), org.units = "cfs", flow.units = input$flow.units)
})
#------------------------------------------------------------------------------
hourly.reac <- reactive({
  convert_flow(hourly.df(), org.units = "cfs", flow.units = input$flow.units)
})
#------------------------------------------------------------------------------
withdrawals.reac <- reactive({
  convert_flow(withdrawals.df(), org.units = "mgd", flow.units = input$flow.units)
})
#------------------------------------------------------------------------------
lowflow.daily.reac <- reactive({
  convert_flow(lowflow.daily.df(), org.units = "cfs", flow.units = input$flow.units)
})
#------------------------------------------------------------------------------
lowflow.hourly.reac <- reactive({
  convert_flow(lowflow.hourly.df(), org.units = "cfs", flow.units = input$flow.units)
})
#------------------------------------------------------------------------------

