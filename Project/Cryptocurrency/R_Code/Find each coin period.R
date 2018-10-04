library("forecast")
library("fpp")
require(gtools)

mydata <- read.csv("CoinPriceHistory.csv_mod2",header=F,stringsAsFactors = F)
colnames(mydata) <- c("coin_name","yyyymmdd","price_at_open","price_at_high","price_at_low","price_at_close","volume","marketcap")
str(mydata)
coin_name <- unique(mydata[,1])
eachCoin <- lapply(1:94,function(x) mydata[(mydata[,1] == coin_name[x]),])

aeon <- eachCoin[[1]]
aeon_closed <- rev(aeon[,6])
ts.plot(log(aeon_closed[400:818]))
tsdisplay(log(aeon_closed[400:818]))
d <- log(aeon_closed[400:818])
tsdisplay(diff(d,2))
tsdisplay(diff(aeon_closed,2))

##
fit.1 <- Arima(d,order=c(0,2,2))
summary(fit.1)
par(mfrow=c(1,2))
acf(residuals(fit.1),ylim=c(-1,1))
pacf(residuals(fit.1),ylim=c(-1,1))
tsdiag(fit.1,gof.lag=60)
par(mfrow=c(1,1))
plot(forecast(fit.1,level=95,h=10))
forecast(fit.1,level=95,h=10)
exp(0.4157720)
cor(d[3:419], d[1:417])
##
fit.2 <- Arima(aeon_closed[400:818],order=c(0,2,2))
summary(fit.2)
par(mfrow=c(1,2))
acf(residuals(fit.2),ylim=c(-1,1))
pacf(residuals(fit.2),ylim=c(-1,1))
tsdiag(fit.2,gof.lag=60)
par(mfrow=c(1,1))
plot(forecast(fit.2,level=95,h=10))
forecast(fit.2,level=95,h=10)
exp(0.4157720)
cor(d[3:419], d[1:417])
###
aeon_data <- data.frame(y = d[3:419], x1 = d[2:418], x2 = d[1:417])

fit.lm <- lm(y ~ x1+x2, data = aeon_data)
exp(fit.lm$fitted.values)
exp(predict.lm(fit.lm, newdata = data.frame(x1 = log(1.45), x2 = log(1.5))))
coin_name
#################### syscoin & digitalnote
syscoin <- eachCoin[[84]]
digitalnote <- eachCoin[[24]]
syscoin_closed <- rev(syscoin[,6])
digitalnote_closed <- rev(digitalnote[,6])
par(mfrow=c(1,2))
ts.plot(syscoin_closed)
ts.plot(digitalnote_closed)
par(mfrow=c(1,1))
ts.plot(syscoin_closed[967:1167], col = "red", lwd = 2)
par(new=T)
ts.plot(digitalnote_closed[(1224-200-90):(1224-90)], col = "blue", lwd = 2)
#
cor(syscoin_closed[967:1167], digitalnote_closed[(1224-200):1224])

#################### ark & bitcoin
ark <- rev(eachCoin[[2]][,6])
bitcoin <- rev(eachCoin[[6]][,6])
ts.plot(ark[100:231], col = "red", lwd = 2)
par(new=T)
ts.plot(bitcoin[(1413-231+1) : (1413-25)], col = "blue", lwd = 2)
#
ts.plot(ark[25:231], col = "red", lwd = 2)
par(new=T)
ts.plot(bitcoin[(1413-231+1+12) : (1413-25+5)], col = "blue", lwd = 2)


d.ark <- diff(ark[100:231],1)
tsdisplay(diff(log(ark[100:231]),1))
tsdisplay(d.ark)
tsdisplay(diff(d.ark,11))
fit.ark <- Arima(ark[100:231],order=c(0,1,0), seasonal=list(order=c(0,0,1),period=11))
summary(fit.ark)
par(mfrow=c(1,2))
acf(residuals(fit.ark),ylim=c(-1,1))
pacf(residuals(fit.ark),ylim=c(-1,1))
tsdiag(fit.ark, gof.lag = 60)
par(mfrow=c(1,1))
plot(forecast(fit.ark,level=95,h=10))
forecast(fit.ark,level=95,h=10)
tsdisplay







