# Conversion factor for CFS to MGD.
conversion.factor <- 1.5472286365101
#------------------------------------------------------------------------------
convert_flow <- function(data.df, org.units, flow.units) {
  if (is.null(data.df)) return(NULL)
  if (org.units == "cfs") {
    if (flow.units == "mgd") {
      final.df <- data.df %>% 
        mutate(flow = flow / conversion.factor)
    } else {
      final.df <- data.df
    }
  } else if (org.units == "mgd"){
    if (flow.units == "cfs") {
      final.df <- data.df %>% 
        mutate(flow = flow * conversion.factor)
    } else {
      final.df <- data.df
    }
  }
  return(final.df)
}
