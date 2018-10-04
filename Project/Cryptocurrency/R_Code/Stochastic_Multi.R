### 패키지 설치 후 library까지 사전 작업. 
install.packages("gtools")
install.packages("smooth")
library(gtools)
library(smooth)

### check data place
#coin_list <- read.csv("/Users/hsw/Desktop/개인파일/스터디/Coin_Project/Python_Code/get_coin_price_history2/coin_price_histories_with_ma7.csv.raw"
#                      , stringsAsFactors = F, header = F)
coin_list <- read.csv("[directory]/coin_price_histories_with_ma7.csv.raw"
                      , stringsAsFactors = F, header = F)

colnames(coin_list) <- c("Coin_name", "Date", "Closed_price", "Closed_price_MA7")
str(coin_list)

## label, allData는 half_and_half와 동일
label <- unique(coin_list[,1])
allData <- lapply(1:length(label), function(x) coin_list[(coin_list[,1] == label[x]),])

## sapply = simplify apply, 리스트(다른 것도 받을 수 있음)를 받아서 뒤에 있는 function을 각 리스트마다 실행시켜 준다.
## 각 리스트에 1행 2열의 원소는 각 코인 데이터의 최종 날짜
## table 함수를 쓴 것은, 모든 코인들이 데이터가 있는 마지막 날짜가 다 같은지 보려고 썼습니다.
table(sapply(allData, function(x) x[1,2]))

## 비트코인 데이터는 리스트에 6번째
bitcoin <- allData[[6]]
tail(bitcoin)
bitcoin_endPrice <- rev(bitcoin[,3])
ts.plot(bitcoin_endPrice)
##

# 아래 식은 tradingview에서 stochastic 지표 식을 그대로 R로 구현한 것.

## 숫자 셋팅
Length_FMS <- 93
SmoothK <- 50
SmoothD <- 50
U_LV <- 80
L_LV <- 20
Length_FMS_2 <- 28
SmoothK_2 <- 14
SmoothD_2 <- 14
##

stocha_data <- sapply(Length_FMS:length(bitcoin_endPrice), function(x) 100 * (bitcoin_endPrice[x] - min(bitcoin_endPrice[(x-(Length_FMS-1)):x])) 
                      / (max(bitcoin_endPrice[(x-(Length_FMS-1)):x]) - min(bitcoin_endPrice[(x-(Length_FMS-1)):x])))
SmoothK_data <- filter(stocha_data, rep(1/SmoothK, SmoothK), sides = 1) ## moving average를 구하기
SmoothD_data <- filter(SmoothK_data, rep(1/SmoothD, SmoothD), sides = 1)
ts.plot(bitcoin_endPrice[(1502-1410+1):1502] , lwd = 2) ## moving average를 구하려면 앞에 일정 기간이 필요하기 때문에 index 조정

##
stocha_data2 <- sapply(Length_FMS_2:length(bitcoin_endPrice), function(x) 100 * (bitcoin_endPrice[x] - min(bitcoin_endPrice[(x-(Length_FMS_2-1)):x])) 
                      / (max(bitcoin_endPrice[(x-(Length_FMS_2-1)):x]) - min(bitcoin_endPrice[(x-(Length_FMS_2-1)):x]))) 
SmoothK_data2 <- filter(stocha_data2[66:1475], rep(1/SmoothK_2, SmoothK_2), sides = 1)
SmoothD_data2 <- filter(SmoothK_data2, rep(1/SmoothD_2, SmoothD_2), sides = 1)
##
ts.plot(SmoothK_data, col = "darkgreen", lwd = 2)
lines(SmoothD_data, col = "red", lwd = 2)
lines(SmoothK_data2, col = "orange", lwd = 2)
lines(SmoothD_data2, col = "yellow", lwd = 2)
##
abline(h = U_LV, col = "red", lwd = 2)
abline(h = L_LV, col = "darkgreen", lwd = 2)



(600*840)^4 


0.6^4

