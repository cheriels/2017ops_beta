date_standards <- function(name, session, start.date, end.date, min.range) {
  start.date <- as.Date(start.date)
  end.date <- as.Date(end.date)
  # If end date is earlier than start date, update the end date to be the same as the new start date
  if (end.date < start.date | end.date - start.date < min.range) {
    end.date = start.date + min.range
  }
  updateDateRangeInput(session, name, start = start.date, end = end.date)
}
#------------------------------------------------------------------------------
date_frame <- function(start.date, end.date, seq.by = "hour") {
    
  data.frame(date_time = seq.POSIXt(start.date, end.date, by = seq.by))
}
#------------------------------------------------------------------------------
