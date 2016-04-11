source("Utils.R")
library(xts, zoo, forecast)

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

#merge time and date
tmp_data$Tarikh<-as.POSIXct(paste(tmp_data$Date, tmp_data$Time), format="%d/%m/%Y %H:%M:%S")
tmp_data <- tmp_data[c(4,1,2,3)]
tmp_data <- tmp_data[,c(-2)]
tmp_data <- tmp_data[,c(-2)]

#create xts object
tmp_dataXTS <- xts(tmp_data$Global_active_power, as.POSIXct(tmp_data$Tarikh), order.by = tmp_data$Tarikh)

#aggregate hourly
data_byHour <- apply.hourly(tmp_dataXTS, sum)
data_byHour = align.time(data_byHour,60)

#split
xtsDay_test <- data_byHour[c(1:49),]
xtsDay_actual <- data_byHour[c(50:51),]


#forecast and plot
fit <- auto.arima(xtsDay_test)
pred <- forecast(fit, h=1)
plot(pred, main="ARIMA Hourly Forecast")
lines(fitted(fit), col="red")


#eval
eval <- accuracy(pred, xtsDay_actual)

#fitted values
forecastValues <- fitted(fit)
forecastValues <- data.frame(forecastValues)
forecastValues <- rename(forecastValues, c("forecastValues"="Forecasted Value"))
forecastValues$"Forecasted Value" <- as.numeric(forecastValues$"Forecasted Value")
forecastValues[nrow(forecastValues) + 1,]<-c(pred$mean[1])

actualValues <- data.frame(data_byHour[c(1:50),])
actualValues <- rename(actualValues, c("data_byHour.c.1.50...."="Actual Value"))
