
source("Utils.R")
library(xts, zoo, forecast)

#read dataset
tmp_data<-read.table("household_power_consumption_daily.csv", header=T, sep=";")

#replace nans
NAs <- tmp_data == "?"
is.na(tmp_data)[NAs] <- TRUE
tmp_data$Global_active_power <- na.locf(tmp_data$Global_active_power, fromLast = FALSE) 


#create time series object
tsDay_test <- ts(tmp_data[1:1400,2],frequency=350, start=c(2006,12), end=c(2010,10))
tsDay_actual <- ts(tmp_data[1401:1442,2],frequency=28, start=c(2010,10))

#forecast and plot
fit <- auto.arima(tsDay_test)
pred <- forecast(fit, h=42)
plot(pred, main="ARIMA Daily Forecast")
lines(fitted(fit), col="red")

#eval
eval <- accuracy(pred, tsDay_actual[1:42])

#copy actual and forecasted readings into data frame
actualValues <- data.frame(tmp_data[c(1:1442),])

forecastValues <- fitted(fit)
forecastValues <- data.frame(forecastValues)
forecastValues <- rename(forecastValues, c("forecastValues"="Forecasted_Value"))
forecastValues$Forecasted_Value <- as.numeric(forecastValues$Forecasted_Value)

i = 1
while(i < 43){
  forecastValues[nrow(forecastValues) + 1,]<-c(pred$mean[i]);
  if( i == 42){
    forecastValues[nrow(forecastValues) + 1,]<-c(pred$mean[i]);
  }
  i = i + 1
}





