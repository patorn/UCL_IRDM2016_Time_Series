
source("Utils.R")
library(xts, zoo, forecast)

#read dataset
tmp_data<-read.table("household_power_consumption_daily.csv", header=T, sep=";")

#replace nans
NAs <- tmp_data == "?"
is.na(tmp_data)[NAs] <- TRUE
tmp_data$Global_active_power <- na.locf(tmp_data$Global_active_power, fromLast = FALSE) 


#create time series object
tsDay_test <- ts(tmp_data[1:49,2],frequency=58, start=c(2006,12), end=c(2007,2))
tsDay_actual <- ts(tmp_data[50:51,2],frequency=7, start=c(2007,2))

#forecast and plot
fit <- auto.arima(tsDay_test)
pred <- forecast(fit, h=1)
plot(pred, main="ARIMA Daily Forecast")
lines(fitted(fit), col="red")

#eval
eval <- accuracy(pred, tsDay_actual[1])

#copy actual and forecasted readings into data frame
actualValues <- data.frame(data_byDay[c(1:50),])

forecastValues <- fitted(fit)
forecastValues <- data.frame(forecastValues)
forecastValues <- rename(forecastValues, c("forecastValues"="Forecasted_Value"))
forecastValues$Forecasted_Value <- as.numeric(forecastValues$Forecasted_Value)
forecastValues[nrow(forecastValues) + 1,]<-c(pred$mean[1])




