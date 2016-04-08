#function to aggregate by day
agg_by_day <- function(originaldata) {
  meanByDay <- function(x) c(mean = mean(x))
  originaldata$Date <- as.Date(originaldata$Date, "%d/%m/%Y")
  byDay <- aggregate(Global_active_power ~ Date, originaldata, meanByDay)
  return(byDay)
}

#function to aggregate by month
agg_by_month <- function(originaldata){
  
  agg_Month <- aggregate(originaldata,by=list(as.yearmon(tmp_data$Date,"%d/%m/%Y")), FUN=mean, na.rm=TRUE)
  byMonth <- agg_Month[,-2]
  byMonth <- byMonth[,-2]
  byMonth <- rename(byMonth, c("Group.1"="Month"))
  return(byMonth)
}