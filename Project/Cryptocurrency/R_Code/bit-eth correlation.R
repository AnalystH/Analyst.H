install.packages("corrplot")
library(corrplot)
#install.packages("forecast")
library("forecast")
#install.packages("fpp")
library("fpp")


bit <- read.csv("bitcoin.csv",header=F,stringsAsFactors = F,fileEncoding = "utf-8")
eth <- read.csv("ethereum.csv",header=F,stringsAsFactors = F,fileEncoding = "utf-8")
str(eth)
par(mfrow=c(1,1))
ts.plot(rev(eth[,2]))
bit_data <- bit[1:814,c(1,2)]
length(bit_data)
bit_closed <- rev(bit[,5])
bit_closed2 <- (bit_closed - min(bit_closed)) / (max(bit_closed) - min((bit_closed)))
eth_closed <- rev(eth[,5])
eth_closed2 <- (eth_closed - min(eth_closed)) / (max(eth_closed) - min((eth_closed)))
cor(bit_closed[(1645-813+650):1645], eth_closed[651:814])
cor(bit_closed2[(1645-813):1645], eth_closed2)
ts.plot(bit_closed[(1645-813+650):1645], col = "red")
par(new=T)
ts.plot(eth_closed[651:814], col = "blue")


eth_data <- eth[,c(1,2)]
cor(rev(bit_data[,2]), rev(eth_data[,2]))

length(eth_data)
par(mfrow=c(1,2))
ts.plot(bit_data)
ts.plot(eth_data)
test1 <- eth_data[0:50]
test2 <- bit_data[0:50]
cor(test1,test2)
t1 <- ifelse(diff(test1) > 0 ,1,0)
t2 <- ifelse(diff(test2) > 0 ,1,0)
mean(t1==t2)

test_lm <- lm(bit_data ~ eth_data)
summary(test_lm)
ts.plot(test_lm$fitted.values)


cor(bit_data,eth_data)
bit_data
eth_data
ts.plot(eth_data)
b1 <- ifelse(diff(rev(bit[1:814,2]),1) > 0,1,0)
b2 <- ifelse(diff(rev(bit[2:815,2]),1) > 0,1,0)
b3 <- ifelse(diff(rev(bit[3:816,2]),1) > 0,1,0)
b4 <- ifelse(diff(rev(bit[4:817,2]),1) > 0,1,0)
b5 <- ifelse(diff(rev(bit[5:818,2]),1) > 0,1,0)
b6 <- ifelse(diff(rev(bit[6:819,2]),1) > 0,1,0)
e1 <- ifelse(diff(rev(eth[,2]),1) > 0,1,0)
ts.plot(rev(eth_data)[650:814])


mydata <- cbind(b1,b2,b3,b4,b5,b6,e1)
cor(mydata)

corrplot(cor(mydata))

### time series analysis
test <- rev(eth_data)[650:814]
test <- eth_data
par(mfrow=c(1,1))
d.test <- diff(test,1)
tsdisplay(test)
tsdisplay(d.test)

fit.1 <- Arima(test,order=c(1,0,1),seasonal=list(order=c(0,0,1),period=20))
par(mfrow=c(1,2))
acf(residuals(fit.1),ylim=c(-1,1))
pacf(residuals(fit.1),ylim=c(-1,1))
tsdiag(fit.1,gof.lag=60)
par(mfrow=c(1,1))
plot(forecast(fit.1,level=95,h=10))
forecast(fit.1,level=95,h=10)


fit.1 <- Arima(d.test,order=c(0,0,0),seasonal=list(order=c(0,0,1),period=20))
par(mfrow=c(1,2))
acf(residuals(fit.1),ylim=c(-1,1))
pacf(residuals(fit.1),ylim=c(-1,1))
tsdiag(fit.1,gof.lag=60)
par(mfrow=c(1,1))
plot(forecast(fit.1,level=95,h=2))
forecast(fit.1,level=95,h=10)
##### time series analysis end



a <- c(10,10,10,2,3,4,5,1,2,3,4,10,10,10,10,2,3,4,5,1,2,3,4,10,10,10,10,2,3,4,5,1,2,3,4,10)
a







