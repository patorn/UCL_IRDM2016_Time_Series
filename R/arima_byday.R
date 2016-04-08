
source("Utils.R")

#read dataset
data<-read.table("household_power_consumption.txt", header=T, sep=";")

#only use date, time and global_active_power
tmp_data<-data[,1:3] 

#replace nans
NAs <- tmp_data == "?"
is.na(tmp_data)[NAs] <- TRUE
tmp_data$Global_active_power <- na.locf(tmp_data$Global_active_power, fromLast = FALSE) 

#convert column to numeric
tmp_data$Global_active_power <- as.numeric(as.character(tmp_data$Global_active_power))

#aggregate data by month
data_byDay <- agg_by_day(tmp_data)

#create time series object
tsDay_test <- ts(data_byDay[1:1342,2],frequency=365, start=c(2006,12), end=c(2010,8))
tsDay_actual <- ts(data_byDay[1343:1442,2],frequency=365, start=c(2010,8))

#forecast and plot
fit <- auto.arima(tsDay_test)
pred <- forecast(fit, h=100)
plot(pred)
lines(fitted(fit), col="red")
lines(tsDay_actual, col="green")

#eval
eval <- accuracy(pred, tsDay_actual)

#copy actual and forecasted readings into data frame
actualValues <- tsDay_actual
actualValues <- data.frame(actualValues)
actualValues <- rename(actualValues, c("actualValues"="Actual Value"))

forecastValues <- pred
forecastValues <- data.frame(forecastValues)
forecastValues <- rename(forecastValues, c("Point.Forecast"="Forecasted Value"))




