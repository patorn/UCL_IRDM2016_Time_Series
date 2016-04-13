rm(list = ls())
source("Utils.R")

arima_data <- read.table("Arima_Daily.csv", header = T, sep = ",")
linear_data <- read.table("linear_daily.csv", header = T, sep = ",")
real_data <- read.table("household_power_consumption_daily.csv", header = T, sep= ";")
dates <- format(as.Date(arima_data$Date, "%d/%m/%Y"), "%d/%m/%Y")
x=FALSE
trim_arima = c()
trim_dates = c()
for(i in 1:nrow(arima_data)){
	date<- arima_data[i,1]
	if(date == "04/02/2007"){
		x = TRUE
	}
	if(isTRUE(x)) {
		trim_arima <- c(trim_arima, arima_data[i,2])
		trim_dates <- c(trim_dates, dates[i])
	}
	if(date == "11/12/2010") {
		x = FALSE
	}
}

trim_linear = c()
for(i in 1:nrow(linear_data)) {
	date <- linear_data[i,1]
	if(date == "2007-02-04") {
		x = TRUE
	}
	if(isTRUE(x)) {
		trim_linear <- c(trim_linear,linear_data[i,2])
	}
	if(date == "2010-12-11") {
		x = FALSE
	}
}

trim_real = c()
for(i in 1:nrow(real_data)) {
	date <- real_data[i,1]
	if(date == "2007-02-04") {
		x= TRUE
	}
	if(isTRUE(x)) {
		trim_real <- c(trim_real, real_data[i,2])
	}
	if(date == "2010-12-11") {
		x = FALSE
	}
}

av = c()
for(i in 1:length(trim_arima)) {
	arima_value <- trim_arima[i]
	linear_value <- trim_linear[i]
	average_value <- (arima_value + linear_value) /2
	av <- c(av, average_value)
}
dateFrame <- data.frame(trim_dates)
plot(av,type = "o", col = "green", ylim = c(200,4000) ,xaxt = 'n',ann = FALSE)
lines(trim_real,type = "o", col = "blue")
axis(1, dateFrame$trim_dates, format(as.Date(dateFrame$trim_dates, "%d/%m/%Y"), "%d/%m/%Y"), cex.axis = 0.9)
title(main="Average Daily Forecast", col.main="red")
