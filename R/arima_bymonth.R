
source("Utils.R")

#read aggregated dataset (monthly)
tmp_data<-read.table("household_power_consumption_monthly.csv", header=T, sep=";")

#replace nans
NAs <- tmp_data == "?"
is.na(tmp_data)[NAs] <- TRUE
tmp_data$Global_active_power <- na.locf(tmp_data$Global_active_power, fromLast = FALSE) 


#create time series object
tsMonth_test <- ts(tmp_data[1:42,2],frequency=12, start=c(2006,12))
tsMonth_actual <- ts(tmp_data[43:48,2],frequency=12, start=c(2010,6))

#forecast and plot
fit <- auto.arima(tsMonth_test)
pred <- forecast(fit, h=6)
plot(pred, main="ARIMA Monthly Forecast")
lines(fitted(fit), col="red")
lines(tsMonth_actual, col="green")

#eval
eval <- accuracy(pred, tsMonth_actual)

#copy actual and forecasted readings into data frame
actualValues <- tmp_data[1:48,]

forecastValues <- fitted(fit)
forecastValues <- data.frame(forecastValues)
forecastValues <- rename(forecastValues, c("forecastValues"="Forecasted_Value"))
forecastValues$Forecasted_Value <- as.numeric(forecastValues$Forecasted_Value)

#copy each forecast
forecastValues[nrow(forecastValues) + 1,]<-c(pred$mean[1])
forecastValues[nrow(forecastValues) + 1,]<-c(pred$mean[2])
forecastValues[nrow(forecastValues) + 1,]<-c(pred$mean[3])
forecastValues[nrow(forecastValues) + 1,]<-c(pred$mean[4])
forecastValues[nrow(forecastValues) + 1,]<-c(pred$mean[5])
forecastValues[nrow(forecastValues) + 1,]<-c(pred$mean[6])
