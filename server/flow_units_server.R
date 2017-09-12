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
  convert_flow_new(daily.df(), org.units = "cfs")
})
#------------------------------------------------------------------------------
hourly.reac <- reactive({
  convert_flow_new(hourly.df(), org.units = "cfs")
})
#------------------------------------------------------------------------------
withdrawals.reac <- reactive({
  convert_flow_new(withdrawals.df(), org.units = "mgd")
})
#------------------------------------------------------------------------------
lowflow.daily.reac <- reactive({
  convert_flow_new(lowflow.daily.df(), org.units = "cfs")
})
#------------------------------------------------------------------------------
lowflow.hourly.reac <- reactive({
  convert_flow_new(lowflow.hourly.df(), org.units = "cfs")
})
#------------------------------------------------------------------------------

