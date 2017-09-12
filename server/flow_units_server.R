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
  convert_flow(daily.df(), org.units = "cfs")
})
#------------------------------------------------------------------------------
hourly.reac <- reactive({
  convert_flow(hourly.df(), org.units = "cfs")
})
#------------------------------------------------------------------------------
withdrawals.reac <- reactive({
  convert_flow(withdrawals.df(), org.units = "mgd")
})
#------------------------------------------------------------------------------
lowflow.daily.reac <- reactive({
  convert_flow(lowflow.daily.df(), org.units = "cfs")
})
#------------------------------------------------------------------------------
lowflow.hourly.reac <- reactive({
  convert_flow(lowflow.hourly.df(), org.units = "cfs")
})
#------------------------------------------------------------------------------

