
#----------------------------------------------------------------------------
output$marfc <- renderPlot({
  labels.vec <- c("Forecast", "Observed")
  breaks.vec <- c("forecast", "observed")
  #----------------------------------------------------------------------------
  # plot flows
  final.plot <- ggplot(marfc.df, aes(x = date_time, y = flow,
                                     color = type,
                                     linetype = type)) + 
    geom_line(size = 2) +
    # Has to be in alphabetical order
    scale_linetype_manual(name = "type",
                          labels = labels.vec,
                          breaks = breaks.vec, 
                          values = c("dashed", "solid")) +
    # Has to be in alphabetical order
    scale_colour_manual(name = "type",
                        labels = labels.vec,
                        breaks = breaks.vec, 
                        values = c("#56B4E9", "#0072B2")) +
    theme_minimal() +
    xlab("Date Time") +
    ylab("Flow (CFS)") +
    theme(legend.title = element_blank(),
          legend.text = element_text(size = 15),
          axis.text = element_text(size = 15),
          axis.title = element_text(size = 15))
  if (!is.na(input$min.flow) || !is.na(input$max.flow)) {
    final.plot <- final.plot + ylim(input$min.flow, input$max.flow)
  }
  final.plot
}) # End output$marfc


