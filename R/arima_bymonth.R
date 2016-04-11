
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
data_byMonth <- agg_by_month(tmp_data)

#create time series object
tsMonth_test <- ts(data_byMonth[1:42,2],frequency=12, start=c(2006,12))
tsMonth_actual <- ts(data_byMonth[43:48,2],frequency=12, start=c(2010,6))

#forecast and plot
fit <- auto.arima(tsMonth_test)
pred <- forecast(fit, h=6)
plot(pred, main="ARIMA Monthly Forecast")
lines(fitted(fit), col="red")
lines(tsMonth_actual, col="green")

#eval
eval <- accuracy(pred, tsMonth_actual)

#copy actual and forecasted readings into data frame
actualValues <- data.frame(data_byMonth[,])

forecastValues <- fitted(fit)
forecastValues <- data.frame(forecastValues)
forecastValues <- rename(forecastValues, c("forecastValues"="Forecasted Value"))
forecastValues$"Forecasted Value" <- as.numeric(forecastValues$"Forecasted Value")

#copy each forecast
forecastValues[nrow(forecastValues) + 1,]<-c(pred$mean[1])
forecastValues[nrow(forecastValues) + 1,]<-c(pred$mean[2])
forecastValues[nrow(forecastValues) + 1,]<-c(pred$mean[3])
forecastValues[nrow(forecastValues) + 1,]<-c(pred$mean[4])
forecastValues[nrow(forecastValues) + 1,]<-c(pred$mean[5])
forecastValues[nrow(forecastValues) + 1,]<-c(pred$mean[6])
