date_standards <- function(name, start.date, end.date, min.range, session) {
  start.date <- as.Date(start.date)
  end.date <- as.Date(end.date)
  # If end date is earlier than start date, update the end date to be the same as the new start date
  if (end.date < start.date | end.date - start.date < min.range) {
    end.date = start.date + min.range
  }
  updateDateRangeInput(session, "date.range.odo", start = start.date,
                       end = end.date)
}