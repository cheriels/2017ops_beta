#------------------------------------------------------------------------------
# Conversion factor for CFS to MGD.
conversion.factor <- 1.5472286365101
#------------------------------------------------------------------------------
# Change the y-axis labels.
y.units <- reactive({
  final.vec <- ifelse(input$flow.units == "cfs",
                      "Flow (CFS)", "Flow (MGD)")
  return(final.vec)
})
#------------------------------------------------------------------------------
convert_flow <- function(data.df, org.units) {
  if (org.units == "cfs") {
    if (input$flow.units == "mgd") {
      final.df <- data.df %>% 
        mutate_at(vars(2:ncol(.)),
                  funs(. / conversion.factor))
    } else {
      final.df <- data.df
    }
  } else if (org.units == "mgd"){
    if (input$flow.units == "cfs") {
      final.df <- data.df %>% 
        mutate_at(vars(2:ncol(.)),
                  funs(. * conversion.factor))
    } else {
      final.df <- data.df
    }
  }
  return(final.df)
}
#------------------------------------------------------------------------------
daily.reac <-reactive({
  convert_flow(daily.df, org.units = "cfs")
})
#------------------------------------------------------------------------------
hourly.reac <-reactive({
  convert_flow(hourly.df, org.units = "cfs")
})
#------------------------------------------------------------------------------
withdrawals.reac <-reactive({
  convert_flow(withdrawals.df, org.units = "mgd")
})
#------------------------------------------------------------------------------
