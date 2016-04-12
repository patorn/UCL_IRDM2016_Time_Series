rm(list = ls())
source("Utils.R")

arima_data <- read.table("Arima_monthly.csv", header = T, sep =  ",")
linear_data <- read.table("linear_monthly.csv", header = T, sep = ",")
real_data <- read.table("household_power_consumption_monthly.csv", header = T, sep = ";")
dates <- format(as.Date(as.yearmon(linear_data$Date,"%Y-%m")),"%Y-%m")

x = FALSE
trim_arima = c()
for(i in 1:nrow(arima_data)) {
	date <- arima_data[i,1]
	if(date == "2007-05") {
		start <- i
		print(i)
		x = TRUE
	}
	if(isTRUE(x)) {
		trim_arima <- c(trim_arima, arima_data[i,2])
	}
	if (date == "2010-11") {
		end <- i
		print(i)
		x = FALSE
	}
	
		
}
trim_dates = c()
trim_linear = c()
for(i in 1:nrow(linear_data)) {
	date <- linear_data[i,1]
	if(date == "2007-05") {
		x = TRUE
	}
	if(isTRUE(x)){
		trim_linear <- c(trim_linear, linear_data[i,2])
		trim_dates <- c(trim_dates, dates[i])
	}
	if(date == "2010-11") {
		x = FALSE
	}
}

trim_real = c()
for(i in 1:nrow(real_data)) {
	date <- real_data[i,1]
	if(date == "2007-05") {
		x = TRUE
	}
	if(isTRUE(x)){
		trim_real <- c(trim_real, real_data[i,2]) 
	}
	if(date == "2010-11") {
		x = FALSE
	}
}

av = c()
for(i in 1:length(trim_arima)) {
	arima_value <- trim_arima[i]
	linear_value <- trim_linear[i]
	average_value <- (arima_value + linear_value) / 2
	av <- c(av, average_value)
}
dateFrame <- data.frame(trim_dates)
plot(av,type= "o",col="green", ylim= c(20000,70000), xaxt='n', ann=FALSE)
lines(trim_real, type = "o", col = "blue")
title(main="Average Monthly Forecast", col.main="red")
axis(1, dateFrame$trim_dates, format(as.Date(as.yearmon(dateFrame$trim_dates,"%Y-%m")),"%Y-%m"),cex.axis = 0.9)
title(xlab="Dates", col.lab=rgb(0,0.5,0))
title(ylab="Global_active_power", col.lab=rgb(0,0.5,0))
g_range <- range(0,av,trim_real)
legend(1,70000,c("Average Model","Actual"),cex = 0.8, col=c("blue","green"),pch=21:22,lty=1:2)

