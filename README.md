# Exercise data analysis

This repository contains two projects for analyzing exercise data. Both use R to perform data analysis and visualization. One is a standalone R script, and the other is an interactive Shiny app.

## Projects overview

### 1. **Standalone R script**
The standalone R script processes exercise data from an Excel file and generates the following outputs:

- **Summary statistics**: mean, median, standard deviation, maximum, and minimum of exercise minutes.
- **Benchmark count**: counts of days meeting or not meeting the benchmark.
- **Longest streak**: the longest streak of days meeting the benchmark.
- **Underperformed days**: days with exercise minutes less than 50% of the benchmark.
- **Visualizations**:
  - Time series plot of exercise minutes over time.
  - Histogram showing the distribution of exercise minutes.
  - Average exercise minutes by day of the week.
  - Cumulative exercise minutes versus cumulative benchmark.

#### How to run:
1. Install required packages:
   
```r
   install.packages(c("readxl", "tidyverse", "ggplot2"))
```

2. Update the file_path variable in the script with the path to your Excel file.
3. Run the script in R.

### 2. **Shiny app**
The Shiny app provides an interactive interface to analyze exercise data. It includes the same functionality as the script but allows users to upload their own Excel file and view results dynamically.

#### Features:
- **Upload Excel files**: accepts files with columns day, minutes, and benchmark.
- **Tab panels**:
  - **Summary**: displays summary statistics, benchmark counts, the longest streak, and underperformance days.
  - **Visualizations**: shows time series, distribution, weekday analysis, and cumulative plots.

#### How to run:
1. Install required packages:
   
```r
   install.packages(c("shiny", "readxl", "tidyverse", "ggplot2", "DT"))
```

2. Run the script in RStudio or R.


## Example data
Ensure your Excel file has the following structure:

| day       | minutes | benchmark |
|-----------|---------|-----------|
| 2025-01-01 | 30      | 40        |
| 2025-01-02 | 50      | 40        |
