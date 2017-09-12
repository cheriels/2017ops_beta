# Conversion factor for CFS to MGD.
conversion.factor <- 1.5472286365101
#------------------------------------------------------------------------------
convert_flow_new <- function(data.df, org.units) {
  if (org.units == "cfs") {
    if (input$flow.units == "mgd") {
      final.df <- data.df %>% 
        mutate(flow = flow / conversion.factor)
    } else {
      final.df <- data.df
    }
  } else if (org.units == "mgd"){
    if (input$flow.units == "cfs") {
      final.df <- data.df %>% 
        mutate(flow = flow * conversion.factor)
    } else {
      final.df <- data.df
    }
  }
  return(final.df)
}
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