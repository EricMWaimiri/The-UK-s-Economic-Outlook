### Overview
This R script performs an analysis and forecasting of the UK's GDP using Multiple Linear Regression (MLR). The script:
1. Loads and formats GDP data.
2. Splits the data into training and test sets.
3. Creates an MLR model to predict GDP.
4. Visualizes the predictions alongside actual GDP data.
5. Forecasts future GDP values.

### Dependencies
Ensure you have the following R packages installed:
- `tidyverse`
- `caret`
- `forecast`

You can install these packages using the following commands:
```R
install.packages("tidyverse")
install.packages("caret")
install.packages("forecast")
```

### Data Source
The data used in this script is loaded from a CSV file hosted on Google Drive.
This data is also available in main:
```R
data <- read.csv("https://drive.google.com/uc?export=download&id=1OFklKBXOaVRr5a6rXiMLoY3wkZxDIHek")
```

### Steps in the Script

1. **Load and Format Data:**
    - The data is loaded from a CSV file and formatted to include a date column.
    ```R
    data <- data %>%
      mutate(date = as.Date(paste(year, qtr * 3, "01", sep = "-"), format = "%Y-%m-%d"))
    ```

2. **Split Data:**
    - The data is split into training and test sets with an 80-20 split.
    ```R
    set.seed(123)
    train_index <- createDataPartition(data$gdp, p = 0.8, list = FALSE)
    train_data <- data[train_index, ]
    test_data <- data[-train_index, ]
    ```

3. **Economic Shocks Timeline:**
    - Major economic events are recorded for reference in visualizations.
    ```R
    economic_shocks <- data.frame(
      event = c("2008 Financial Crisis", "Brexit Referendum", "COVID-19 Pandemic"),
      year = c(2008, 2016, 2020)
    )
    ```

4. **MLR Model:**
    - A Multiple Linear Regression model is created using the training data, and predictions are made on the test data.
    ```R
    mlr_model <- lm(gdp ~ year + qtr, data = train_data)
    mlr_predictions <- predict(mlr_model, newdata = test_data)
    ```

5. **Evaluate Model:**
    - The Root Mean Square Error (RMSE) of the model's predictions is calculated.
    ```R
    mlr_rmse <- sqrt(mean((test_data$gdp - mlr_predictions)^2))
    cat("Multiple Linear Regression RMSE:", mlr_rmse, "\n")
    ```

6. **Visualization:**
    - A plot is generated showing actual GDP vs. MLR predictions, including major economic shocks.
    ```R
    ggplot(test_data, aes(x = date)) +
      geom_line(aes(y = gdp, color = "Actual GDP")) +
      geom_line(aes(y = mlr_predictions, color = "MLR Predictions")) +
      labs(title = "GDP Predictions using Multiple Linear Regression",
           x = "Date",
           y = "GDP",
           color = "Legend") +
      theme_minimal() +
      geom_vline(data = economic_shocks, aes(xintercept = as.numeric(as.Date(paste(year, "01", "01", sep = "-"))), linetype = event), color = "red") +
      scale_linetype_manual(values = c(2, 2, 2))
    ```

7. **Forecast Future GDP:**
    - The model is used to forecast GDP for future years, and the results are visualized.
    ```R
    future_years <- data.frame(year = rep(2024:2025, each = 4), qtr = rep(1:4, 2))
    future_predictions <- predict(mlr_model, newdata = future_years)
    
    future_gdp <- data.frame(
      date = as.Date(paste(future_years$year, future_years$qtr * 3, "01", sep = "-"), format = "%Y-%m-%d"),
      gdp = future_predictions
    )
    
    ggplot() +
      geom_line(data = data, aes(x = date, y = gdp, color = "Actual GDP")) +
      geom_line(data = future_gdp, aes(x = date, y = gdp, color = "Forecasted GDP")) +
      labs(title = "GDP Forecast using Multiple Linear Regression",
           x = "Date",
           y = "GDP",
           color = "Legend") +
      theme_minimal() +
      geom_vline(data = economic_shocks, aes(xintercept = as.numeric(as.Date(paste(year, "01", "01", sep = "-"))), linetype = event), color = "red") +
      scale_linetype_manual(values = c(2, 2, 2))
    ```

### Running the Script
To run the script, simply execute it in your R environment. Ensure all dependencies are installed and that you have internet access to download the data file. The script will output RMSE for the MLR model and generate visualizations for both historical GDP data with predictions and future GDP forecasts.
