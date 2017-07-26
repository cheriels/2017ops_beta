org.df <- flow.df
gage <- "por_flow"
k.table <- k.lag
trib.gage <- "mon_jug_flow"
pot.lag <- "por_1"


org <- org.df
flow <- flow.df
gage.name <- rlang::quo(por_flow)
k.tbl <- k.pot


calc_lag <- function(org.df, gage, k.table, trib.gage, pot.lag) {
  #============================================================================
  # Calculate the lag of the instream Potomac River.
  k.pot <- k.table[k.table$GAGE %in% pot.lag, ]
  flow.pot <- lag_k(org.df, org.df, gage, k.pot)
  # Calculate the lag of a tributary to the Potomac River.
  trib.gage.name <- sub("^(.*)[_].*", "\\1", trib.gage)
  k.trib <- k.table[k.table$GAGE %in% trib.gage.name, ]
  flow.trib <- lag_k(org.df, flow.df, trib.gage, k.trib)
  #============================================================================
  confluence.df <- merge(flow.pot, flow.trib, by = "DATE_TIME", all = TRUE)
  confluence.df$SIM_FLOW <- rowSums(confluence.df[, 2:3], na.rm = TRUE)
  names(confluence.df)[4] <- pot.lag
  #============================================================================
  final.df <- merge(org.df, confluence.df, by = "DATE_TIME", all = TRUE)
  
  #names(org.df)[names(org.df) %in% "LAG"] <- paste(gage.name, "LAG", sep = "_")
  return(final.df)
}

gage.col <- pull(flow,!!gage.name)
lag1 <- 1
lag2 <- 2
int_lag <- function(k.tbl, lag1, lag2, gage.col) {
  
  
  return (k.tbl$LAG[lag1] + 
            ((k.tbl$LAG[lag2] - k.tbl$LAG[lag1]) * 
               (gage.col - k.tbl$FLOW[lag1]) / 
               (k.tbl$FLOW[lag2] - k.tbl$FLOW[lag1])))
}

nrow(k.tbl)

test <- flow %>% 
  mutate(LAG = case_when(
    between(rlang::UQ(gage.name), k.table
    ))
    
    test <- ifelse(flow[, gage.name] <= k.tbl$FLOW[1], k.tbl$LAG[1],)
    
    
    var_lagk <- function(org, flow, gage.name, k.tbl) {
      gage.name <- rlang::enquo(gage.name)
      #----------------------------------------------------------------------------
      flow <- flow %>% 
        dplyr::mutate(lag = dplyr::case_when(
          rlang::UQ(gage.name) <= k.tbl$FLOW[1] ~ k.tbl$LAG[1],
          rlang::UQ(gage.name) >= k.tbl$FLOW[nrow(k.tbl)] ~ as.double(k.tbl$FLOW[nrow(k.tbl)]),
          TRUE ~ as.double(NA)))
      
      for (i in 2:nrow(k.tbl)) {
        if (is.na(k.tbl$FLOW[i]) == FALSE) {
          flow$LAG <- flow %>% 
            mutate(ifelse(gage.name > k.tbl$FLOW[i - 1] & gage.name <= k.tbl$FLOW[i],
                          int_lag(k.tbl, i - 1, i, gage.name), lag))
        }
      }
      
      test <- sapply(2:nrow(k.tbl), function(row.i) {
        flow %>% 
          mutate(test = ifelse(gage.name > k.tbl$FLOW[row.i - 1] & gage.name <= k.tbl$FLOW[row.i],
                               (k.tbl$LAG[row.i - 1] + 
                                  ((k.tbl$LAG[row.i] - k.tbl$LAG[row.i - 1]) * 
                                     (gage.col - k.tbl$FLOW[row.i - 1]) / 
                                     (k.tbl$FLOW[row.i] - k.tbl$FLOW[row.i - 1]))), lag)) %>% 
          pull(test)
      }) 
      test <- dplyr::bind_rows(lag.list)
      int_lag(k.tbl, row.i - 1, row.i, gage.name)
      
      max.klag <- max(k.tbl$FLOW, na.rm = TRUE)
      flow$LAG <- ifelse(flow[, gage.name] >= max.klag,
                         k.tbl[k.tbl$FLOW == max.klag, "LAG"],
                         flow$LAG)
      flow$LAG <- flow$DATE_TIME + flow$LAG * 3600
      
      lag.name <- paste(gage.name, "LAG", sep = "_")
      
      lag.df <- flow[, c("LAG", gage.name)]
      names(lag.df) <- c("DATE_TIME", lag.name)
      lag.df <- lag.df[complete.cases(lag.df), ]
      lag.df$DATE_TIME <- as.POSIXct(round(lag.df$DATE_TIME, units = "hours")) 
      #lag.df$DATE_TIME <- as.POSIXct(ceiling_date(lag.df$DATE_TIME, unit = "hours")) 
      lag.df <- aggregate(. ~ DATE_TIME, data = lag.df, FUN = mean)
      merged1 <- plyr::join_all(list(org, lag.df), by = "DATE_TIME")
      mt <- merged1[duplicated(merged1$DATE_TIME), ]
      # Need to solve Daylight savings time issue to incorporate Nov.
      interp.df <- data.frame(na.approx(zoo(x = merged1[, paste(gage.name, "LAG", sep = "_")],
                                            order.by = merged1$DATE_TIME)))
      interp.df$DATE_TIME <- row.names(interp.df)
      names(interp.df) <- c(lag.name, "DATE_TIME")
      interp.df$DATE_TIME <- as.POSIXct(interp.df$DATE_TIME)
      return(interp.df)
    }
    