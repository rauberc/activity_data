# Load required libraries
library(readxl)
library(tidyverse)

# Load data from Excel
file_path <- "activity_data_r.xlsx" # Replace with your file path
data <- read_excel(file_path)

# Summary statistics
summary_stats <- data %>%
  summarise(
    mean_minutes = mean(minutes, na.rm = TRUE),
    median_minutes = median(minutes, na.rm = TRUE),
    sd_minutes = sd(minutes, na.rm = TRUE),
    max_minutes = max(minutes, na.rm = TRUE),
    min_minutes = min(minutes, na.rm = TRUE)
  )
print("Summary statistics:")
print(summary_stats)

# Benchmark count
benchmark_count <- data %>%
  mutate(meets_benchmark = if_else(minutes >= benchmark, TRUE, FALSE)) %>%
  summarise(
    days_meeting_benchmark = sum(meets_benchmark, na.rm = TRUE),
    days_not_meeting_benchmark = sum(!meets_benchmark, na.rm = TRUE)
  )
print("Benchmark count:")
print(benchmark_count)

# Longest streak of meeting benchmark
data <- data %>%
  mutate(meets_benchmark = if_else(minutes >= benchmark, TRUE, FALSE))

streaks <- rle(data$meets_benchmark)$lengths
longest_streak <- max(streaks[rle(data$meets_benchmark)$values == TRUE], na.rm = TRUE)
cat("Longest streak of meeting the benchmark:", longest_streak, "\n")

# Underperformed days
underperformance_days <- data %>%
  filter(minutes < (benchmark / 2)) %>%
  nrow()
cat("Number of days with underperformance (<50% of benchmark):", underperformance_days, "\n")

# Time series plot
ggplot(data, aes(x = day, y = minutes)) +
  geom_line(color = "blue") +
  geom_hline(aes(yintercept = benchmark), color = "red", linetype = "dashed") +
  labs(
    title = "Exercise minutes over time",
    x = "Day",
    y = "Minutes of exercise"
  ) +
  theme_minimal()

# Distribution plot
ggplot(data, aes(x = minutes)) +
  geom_histogram(binwidth = 5, fill = "blue", color = "black", alpha = 0.7) +
  geom_vline(aes(xintercept = benchmark), color = "red", linetype = "dashed") +
  labs(
    title = "Distribution of exercise minutes",
    x = "Minutes",
    y = "Frequency"
  ) +
  theme_minimal()

# Weekday analysis plot
data <- data %>%
  mutate(day_of_week = weekdays(as.Date(day)))

avg_minutes_by_day <- data %>%
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

# Cumulative plot
data <- data %>%
  mutate(
    cumulative_minutes = cumsum(minutes),
    cumulative_benchmark = cumsum(benchmark)
  )

ggplot(data, aes(x = day)) +
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
