library(tidyverse)
library(caret)
library(forecast)

#Load the data
data <- read.csv("https://drive.google.com/uc?export=download&id=1OFklKBXOaVRr5a6rXiMLoY3wkZxDIHek")

#Format data
data <- data %>%
  mutate(date = as.Date(paste(year, qtr * 3, "01", sep = "-"), format = "%Y-%m-%d"))

#Split
set.seed(123)
train_index <- createDataPartition(data$gdp, p = 0.8, list = FALSE)
train_data <- data[train_index, ]
test_data <- data[-train_index, ]

#Timeline of major economic shocks
economic_shocks <- data.frame(
  event = c("2008 Financial Crisis", "Brexit Referendum", "COVID-19 Pandemic"),
  year = c(2008, 2016, 2020)
)

#MLR model
mlr_model <- lm(gdp ~ year + qtr, data = train_data)
mlr_predictions <- predict(mlr_model, newdata = test_data)

mlr_rmse <- sqrt(mean((test_data$gdp - mlr_predictions)^2))
cat("Multiple Linear Regression RMSE:", mlr_rmse, "\n")

#Plot economic shocks timeline
test_data <- test_data %>%
  mutate(mlr_predictions = mlr_predictions)

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

#GDP forecast
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
