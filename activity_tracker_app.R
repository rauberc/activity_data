# Load required libraries
library(shiny)
library(readxl)
library(tidyverse)
library(ggplot2)
library(DT)

# Define UI for application
ui <- fluidPage(
  
  # App title
  titlePanel("Exercise Data Analysis"),
  
  # Sidebar layout with input and output definitions
  sidebarLayout(
    sidebarPanel(
      fileInput("file1", "Choose Excel File", accept = ".xlsx"),
      hr(),
      helpText("Upload your exercise data in an Excel file with columns: 'day', 'minutes', and 'benchmark'.")
    ),
    
    # Main panel for displaying outputs
    mainPanel(
      tabsetPanel(
        tabPanel("Summary", 
                 tableOutput("summary_stats"),
                 tableOutput("benchmark_count"),
                 textOutput("longest_streak"),
                 textOutput("underperformance_days")),
        
        tabPanel("Visualizations",
                 plotOutput("time_series_plot"),
                 plotOutput("distribution_plot"),
                 plotOutput("weekday_analysis"),
                 plotOutput("cumulative_plot"),
        )
      )
    )
  )
)

# Define server logic for the app
server <- function(input, output) {
  
  # Reactive expression to read the uploaded file
  data <- reactive({
    req(input$file1)
    read_excel(input$file1$datapath)
  })
  
  # Summary Statistics
  output$summary_stats <- renderTable({
    df <- data()
    summary_stats <- df %>%
      summarise(
        mean_minutes = mean(minutes, na.rm = TRUE),
        median_minutes = median(minutes, na.rm = TRUE),
        sd_minutes = sd(minutes, na.rm = TRUE),
        max_minutes = max(minutes, na.rm = TRUE),
        min_minutes = min(minutes, na.rm = TRUE)
      )
    print(summary_stats)
  })

  # Benchmark count
  output$benchmark_count <- renderTable({
    df <- data() %>%
      mutate(meets_benchmark = if_else(minutes >= benchmark, TRUE, FALSE))

    benchmark_count <- df %>%
      summarise(
        days_meeting_benchmark = sum(meets_benchmark, na.rm = TRUE),
        days_not_meeting_benchmark = sum(!meets_benchmark, na.rm = TRUE)
      )
    print(benchmark_count)
  })
  
  
  # Longest streak of meeting benchmark
  output$longest_streak <- renderPrint({
    df <- data()
    df <- df %>%
      mutate(meets_benchmark = if_else(minutes >= benchmark, TRUE, FALSE))
    
    streaks <- rle(df$meets_benchmark)$lengths
    longest_streak <- max(streaks[rle(df$meets_benchmark)$values == TRUE], na.rm = TRUE)
    print(paste("Longest streak of meeting the benchmark:", longest_streak))
  })
  
  # Underperformed days
  output$underperformance_days <- renderPrint({
    df <- data()
    underperformance_days <- df %>%
      filter(minutes < (benchmark / 2)) %>%
      nrow()
    print(paste("Number of days with underperformance (<50% of benchmark):", underperformance_days))
  })
  
  # Time series plot
  output$time_series_plot <- renderPlot({
    df <- data()
    ggplot(df, aes(x = day, y = minutes)) +
      geom_line(color = "blue") +
      geom_hline(aes(yintercept = benchmark), color = "red", linetype = "dashed") +
      labs(
        title = "Exercise minutes over time",
        x = "Day",
        y = "Minutes of exercise"
      ) +
      theme_minimal()
  })
  
  # Distribution plot
  output$distribution_plot <- renderPlot({
    df <- data()
    ggplot(df, aes(x = minutes)) +
      geom_histogram(binwidth = 5, fill = "blue", color = "black", alpha = 0.7) +
      geom_vline(aes(xintercept = benchmark), color = "red", linetype = "dashed") +
      labs(
        title = "Distribution of exercise minutes",
        x = "Minutes",
        y = "Frequency"
      ) +
      theme_minimal()
  })
  
  # Weekday analysis plot
  output$weekday_analysis <- renderPlot({
    df <- data() %>%
      mutate(day_of_week = weekdays(as.Date(day)))
    
    avg_minutes_by_day <- df %>%
      group_by(day_of_week) %>%
      summarise(avg_minutes = mean(minutes, na.rm = TRUE))
    
    ggplot(avg_minutes_by_day, aes(x = reorder(day_of_week, avg_minutes), y = avg_minutes)) +
      geom_bar(stat = "identity", fill = "blue", alpha = 0.7) +
      labs(
        title = "Average minutes by day of the week",
        x = "Day of the week",
        y = "Average minutes"
      ) +
      theme_minimal()
  })
  
  # Cumulative plot
  output$cumulative_plot <- renderPlot({
    df <- data() %>%
      mutate(
        cumulative_minutes = cumsum(minutes),
        cumulative_benchmark = cumsum(benchmark)
      )
    
    ggplot(df, aes(x = day)) +
      geom_line(aes(y = cumulative_minutes, color = "Minutes")) +
      geom_line(aes(y = cumulative_benchmark, color = "Benchmark")) +
      labs(
        title = "Cumulative exercise minutes vs. benchmark",
        x = "Day",
        y = "Cumulative minutes"
      ) +
      scale_color_manual(values = c("Minutes" = "blue", "Benchmark" = "red"), 
                         name = NULL) +
      theme_minimal()
  })
}

# Run the application
shinyApp(ui = ui, server = server)
