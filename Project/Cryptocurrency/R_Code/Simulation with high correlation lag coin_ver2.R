require(gtools)
#coin_list <- read.csv("coin_handling.csv", stringsAsFactors = F)
coin_list <- read.csv("coin_price_histories_with_ma7.csv.raw", header = F, stringsAsFactors = F)
colnames(coin_list) <- c("Coin_name", "Date", "Closed_price", "Closed_price_MA7")
str(coin_list)

dataHandle_with_raw <- function(mdata, label_index, target_index, date_index, dataNum, past_days = 1){
  label <- unique(mdata[,label_index])
  mdata2 <- lapply(1:length(label), function(x) mdata[(mdata[,label_index] == label[x]),])
  check_dim <- sapply(mdata2,function(x) nrow(x))
  mdata3 <- lapply(which(check_dim > dataNum), function(x) mdata[(mdata[,label_index] == label[x]),])
  check_dim2 <- sapply(mdata3,function(x) nrow(x))
  mdata4 <- lapply(mdata3, function(x) x[past_days:(past_days + dataNum - 1), target_index])
  mdata5 <- do.call(cbind, mdata4)
  colnames(mdata5) <- sapply(mdata3, function(x) x[1,label_index])
  rownames(mdata5) <- mdata3[[1]][past_days:(past_days + dataNum - 1),2]
  return(mdata5)
}

dataHandle_with_raw_fixedNum <- function(mdata, label_index, target_index, date_index, dataNum, past_days = 1){
#  mdata <- coin_list
#  label_index <- 1
#  target_index <- 3
#  date_index <- 2
#  dataNum <- 60
#  past_days <- 101
  label <- unique(mdata[,label_index])
  mdata2 <- lapply(1:length(label), function(x) mdata[(mdata[,label_index] == label[x]),])
  check_dim <- sapply(mdata2,function(x) nrow(x))
  mdata3 <- lapply(which(check_dim > (past_days + dataNum - 1)), function(x) mdata[(mdata[,label_index] == label[x]),])
  mdata4 <- lapply(mdata3, function(x) x[past_days:(past_days + dataNum - 1), target_index])
  mdata5 <- do.call(cbind, mdata4)
  colnames(mdata5) <- sapply(mdata3, function(x) x[1,label_index])
  rownames(mdata5) <- mdata3[[1]][past_days:(past_days + dataNum - 1),2]
  return(mdata5)
}



find_corr_afterHandle_raw_MA7 <- function(mdata, choose_lag){
  possibleNum <- permutations(n = ncol(mdata), r = 2)
  coin_name <- colnames(mdata)
  result <- cbind(possibleNum[,1], rep(0, nrow(possibleNum)), possibleNum[,2], rep(0, nrow(possibleNum)), rep(0, nrow(possibleNum)), rep(0, nrow(possibleNum)))
  colnames(result) <- c("fixedCoin","fixedCoinName", "lagCoin", "lagCoinName", "lag", "cor")
  for(i in 1:nrow(possibleNum)){
    coin <- mdata[,possibleNum[i,]]
    result[i,2] <- coin_name[possibleNum[i,1]]
    result[i,4] <- coin_name[possibleNum[i,2]]
    corr_data <- sapply(0:choose_lag, function(x) cor(coin[1:(nrow(coin)-x),1], coin[(x+1):nrow(coin),2]))
    if(which.max(abs(corr_data)) == 1){
      max_index <- order(abs(corr_data), decreasing = T)[2]
    }else{
      max_index <- which.max(abs(corr_data))
    }
    result[i,5] <- (max_index - 1)
    result[i,6] <- corr_data[max_index]
  }
  return(result)
}

find_corr_afterHandle_raw_MA7_up10 <- function(mdata, choose_lag){
  possibleNum <- permutations(n = ncol(mdata), r = 2)
  coin_name <- colnames(mdata)
  result <- cbind(possibleNum[,1], rep(0, nrow(possibleNum)), possibleNum[,2], rep(0, nrow(possibleNum)), rep(0, nrow(possibleNum)), rep(0, nrow(possibleNum)))
  colnames(result) <- c("fixedCoin","fixedCoinName", "lagCoin", "lagCoinName", "lag", "cor")
  for(i in 1:nrow(possibleNum)){
    coin <- mdata[,possibleNum[i,]]
    result[i,2] <- coin_name[possibleNum[i,1]]
    result[i,4] <- coin_name[possibleNum[i,2]]
    corr_data <- sapply(0:choose_lag, function(x) cor(coin[1:(nrow(coin)-x),1], coin[(x+1):nrow(coin),2]))
    j <- 1
    while(order(abs(corr_data), decreasing = T)[j] <= 10){
      j <- j+1
    }
    max_index <- order(abs(corr_data), decreasing = T)[j]
    result[i,5] <- (max_index - 1)
    result[i,6] <- corr_data[max_index]
  }
  return(result)
}

sort_corr_result[54,]
meanEarningRatio <- function(lag_MA7, follow_closed, lagNum, cumNum = 10, buyidx = 8, corr){
  #lag_MA7 <- rev(coin_list_MA7[,51])
  #follow_closed <- rev(coin_list_closed[,56])
  #lagNum <- 15
  #cumNum <- 10
  #buyidx <- 8
  #corr <- 0.9645
  lag_MA7 <- rev(lag_MA7)
  follow_closed <- rev(follow_closed)
  if(corr >= 0){
    UD <- ifelse(diff(lag_MA7) > 0 ,1,0)
  }else{
    UD <- ifelse(diff(lag_MA7) < 0 ,1,0)
  }
  as.numeric(UD)
  cumUD <- c(rep(0,(cumNum-1)),sapply(1:(length(UD)-(cumNum-1)), function(x) sum(UD[x:(x+(cumNum-1))])))
  series <- lapply(1:(length(cumUD)-2), function(x) cumUD[x:(x+2)])
  buy_idx <- (which(sapply(series, function(x) (x[3] == buyidx) & (x[2] == (buyidx-1)))) + 2) + (lagNum - cumNum)
  sell_idx <- which(sapply(series, function(x) (x[3] == round(cumNum * (2/3)))))
  sell_idx2 <- sapply(1:length(buy_idx), function(x) sell_idx[which(buy_idx[x] < sell_idx)][1]) + 2 + (lagNum - cumNum)
  if((sum(is.na(buy_idx)) == 0) && (length(buy_idx) == 1)){
    return(list("EarningRatioSum" = 'no_buy', "Buy & Sell Num" = 'no_buy'))
  }else if(is.na(sell_idx2[1] > length(follow_closed))){
    return(list("EarningRatioSum" = 'no_sell', "Buy & Sell Num" = 'no_sell'))
  }else if((sum(is.na(sell_idx2)) != 0) && (length(sell_idx2) == 1)){
    return(list("EarningRatioSum" = 'no_sell', "Buy & Sell Num" = 'no_sell'))
  }else if((sum(is.na(sell_idx2)) != 0)){
    idx <- na.replace(sell_idx2, -1)
    buy_idx <- buy_idx[which(idx != -1)]
    sell_idx2 <- idx[which(idx != -1)]
    buy_price <- follow_closed[buy_idx]
    sell_price <- follow_closed[sell_idx2]
    EarningRatioSum <- cumsum(sapply(1:length(buy_price), function(x) ((sell_price[x] - buy_price[x]) / buy_price[x]) * 100))[length(buy_price)]
    return(list("EarningRatioSum" = EarningRatioSum, "Buy & Sell Num" = length(buy_price)))
  }else{
    buy_price <- follow_closed[buy_idx]
    sell_price <- follow_closed[sell_idx2]
    EarningRatioSum <- cumsum(sapply(1:length(buy_price), function(x) ((sell_price[x] - buy_price[x]) / buy_price[x]) * 100))[length(buy_price)]
    return(list("EarningRatioSum" = EarningRatioSum, "Buy & Sell Num" = length(buy_price)))
  }
}

coin_list_MA7 <- dataHandle_with_raw_fixedNum(coin_list, 1, 3, 2, 100)
dim(coin_list_MA7)
tail(coin_list_MA7)
coin_list_MA7_past_101 <- dataHandle_with_raw_fixedNum(coin_list, 1, 3, 2, 100, 101)
diff_coin_list_MA7_past_101 <- apply(coin_list_MA7_past_101, 2, function(x) diff(x))
UD_coin_list_MA7_past_101 <- apply(diff_coin_list_MA7_past_101, 2, function(x) ifelse(x > 0, 0, 1))
sum_UD_coin_list_MA7_past_101 <- as.numeric(apply(UD_coin_list_MA7_past_101, 1, function(x) sum(x)))
summary(sum_UD_coin_list_MA7_past_101)
take_idx <- which((sum_UD_coin_list_MA7_past_101 <= 70) * (sum_UD_coin_list_MA7_past_101 >= 19) == 1)
sum_UD_coin_list_MA7_past_101[take_idx]
coin_list_MA7_past_101_take_idx <- coin_list_MA7_past_101[take_idx,]


coin_list_closed <- dataHandle_with_raw_fixedNum(coin_list, 1, 4, 2, 100)
coin_list_closed_past_101 <- dataHandle_with_raw_fixedNum(coin_list, 1, 4, 2, 100, 101)
coin_list_closed[,c(1,46)]
colnames(coin_list_closed)

corr_result <- find_corr_afterHandle_raw_MA7_up10(coin_list_MA7_past_101_take_idx, 30)
corr_result2 <- find_corr_afterHandle_raw_MA7_up10(coin_list_MA7, 30)
colnames(coin_list_MA7_past_101[,c(46,51)])
sort_corr_result <- corr_result[order(abs(as.numeric(corr_result[,6])), decreasing = T),]
sort_corr_result2 <- corr_result2[order(abs(as.numeric(corr_result2[,6])), decreasing = T),]
head(sort_corr_result2[which(sort_corr_result2[,2] == 'steem'),],20)
uk_coin <- unique(coin_list[,1])
korea_coin <- uk_coin[c(2,7,21,29,33,34,49,50,53,54,58,64,75,78,86,87,88,97,100)]

### Coins which can buy in Korea
korea_coin_idx <- c()
for(i in 1:length(korea_coin)){
  korea_coin_idx <- c(korea_coin_idx, which(sort_corr_result[,2] == korea_coin[i] | sort_corr_result[,4] == korea_coin[i]))
}
korea_coin_result <- sort_corr_result[korea_coin_idx,]
korea_coin_result


###### Mean Earning Ratio
allER <- matrix(rep(0,dim(sort_corr_result)[1]*2), dim(sort_corr_result)[1],2)
j <- 0
for(i in 1:dim(sort_corr_result)[1]){
  j <- j+1
  mydata <- sort_corr_result[i,]
  result_set <- meanEarningRatio(coin_list_MA7[,which(colnames(coin_list_MA7) == mydata[4])], 
                                 coin_list_closed[,which(colnames(coin_list_closed) == mydata[2])], 
                                 as.numeric(mydata[5]), corr = as.numeric(mydata[6]))
  allER[i,1] <- result_set$EarningRatioSum
  allER[i,2] <- result_set$`Buy & Sell Num`
}
allER_result <- allER[(is.na(as.numeric(allER[,1])) == F),]
summary(as.numeric(allER_result[,1])) ## 전체
###
sort_corr_result[960,]
ER960 <- matrix(rep(0,960*2), 960,2)
j <- 0
for(i in 1:960){
  j <- j+1
  mydata <- sort_corr_result[i,]
  result_set <- meanEarningRatio(coin_list_MA7[,which(colnames(coin_list_MA7) == mydata[4])], 
                                 coin_list_closed[,which(colnames(coin_list_closed) == mydata[2])], 
                                 as.numeric(mydata[5]), corr = as.numeric(mydata[6]))
  ER960[i,1] <- result_set$EarningRatioSum
  ER960[i,2] <- result_set$`Buy & Sell Num`
}
meanER960 <- ER960[(is.na(as.numeric(ER960[,1])) == F),]
summary(as.numeric(meanER960[,1])) ## 960개 cor 0.8 up

###
sort_corr_result[130,]
ER130 <- matrix(rep(0,130*2), 130,2)
j <- 0
for(i in 1:130){
  j <- j+1
  mydata <- sort_corr_result[i,]
  result_set <- meanEarningRatio(coin_list_MA7[,which(colnames(coin_list_MA7) == mydata[4])], 
                                 coin_list_closed[,which(colnames(coin_list_closed) == mydata[2])], 
                                 as.numeric(mydata[5]), corr = as.numeric(mydata[6]))
  ER130[i,1] <- result_set$EarningRatioSum
  ER130[i,2] <- result_set$`Buy & Sell Num`
}
meanER130 <- ER130[(is.na(as.numeric(ER130[,1])) == F),]
summary(as.numeric(meanER130[,1])) ## 130개(0.9이상)


t.test(as.numeric(meanER40[,1]), as.numeric(allER_result[,1]), alternative = "greater")
t.test(as.numeric(meanER40[,1]), as.numeric(meanER400[,1]), alternative = "greater")
t.test(as.numeric(meanER400[,1]), as.numeric(allER_result[,1]), alternative = "greater")
sort_corr_result[40,]

#### backtesting day by day
coin_list_closed <- dataHandle_with_raw_fixedNum(coin_list, 1, 4, 2, 130)
coin_list_MA7 <- dataHandle_with_raw_fixedNum(coin_list, 1, 3, 2, 130)
backtesting_result <- matrix(rep(0,60),30,2)
for(k in 1:30){
  coin_list_MA7_past_101 <- dataHandle_with_raw_fixedNum(coin_list, 1, 3, 2, 100, (101 + k))
  diff_coin_list_MA7_past_101 <- apply(coin_list_MA7_past_101, 2, function(x) diff(x))
  UD_coin_list_MA7_past_101 <- apply(diff_coin_list_MA7_past_101, 2, function(x) ifelse(x > 0, 0, 1))
  sum_UD_coin_list_MA7_past_101 <- as.numeric(apply(UD_coin_list_MA7_past_101, 1, function(x) sum(x)))
  summary(sum_UD_coin_list_MA7_past_101)
  take_idx <- which((sum_UD_coin_list_MA7_past_101 <= 70) * (sum_UD_coin_list_MA7_past_101 >= 19) == 1)
  sum_UD_coin_list_MA7_past_101[take_idx]
  coin_list_MA7_past_101_take_idx <- coin_list_MA7_past_101[take_idx,]
  corr_result <- find_corr_afterHandle_raw_MA7_up10(coin_list_MA7_past_101_take_idx, 30)
  sort_corr_result <- corr_result[order(abs(as.numeric(corr_result[,6])), decreasing = T),]
  coin_list_closed_2 <- coin_list_closed[1:(100 + k),]
  coin_list_MA7_2 <- coin_list_MA7[1:(100 + k),]
  ER130 <- matrix(rep(0,130*2), 130,2)
  j <- 0
  for(i in 1:130){
    j <- j+1
    mydata <- sort_corr_result[i,]
    result_set <- meanEarningRatio(coin_list_MA7_2[,which(colnames(coin_list_MA7_2) == mydata[4])], 
                                   coin_list_closed_2[,which(colnames(coin_list_closed_2) == mydata[2])], 
                                   as.numeric(mydata[5]), corr = as.numeric(mydata[6]))
    ER130[i,1] <- result_set$EarningRatioSum
    ER130[i,2] <- result_set$`Buy & Sell Num`
  }
  meanER130 <- ER130[(is.na(as.numeric(ER130[,1])) == F),]
  backtesting_result[k,1] <- k
  backtesting_result[k,2] <- mean(as.numeric(meanER130[,1]))
}
summary(backtesting_result[,2])

coin_list_MA7_past_101
coin_list_MA7_past_101_2 <- dataHandle_with_raw_fixedNum(coin_list, 1, 3, 2, 100, (101 + 2))
tail(coin_list_closed)
dim(coin_list_closed)
tail(coin_list_closed[1:102,])

ER130 <- matrix(rep(0,130*2), 130,2)
j <- 0
for(i in 1:130){
  j <- j+1
  mydata <- sort_corr_result[i,]
  result_set <- meanEarningRatio(coin_list_MA7[,which(colnames(coin_list_MA7) == mydata[4])], 
                                 coin_list_closed[,which(colnames(coin_list_closed) == mydata[2])], 
                                 as.numeric(mydata[5]), corr = as.numeric(mydata[6]))
  ER130[i,1] <- result_set$EarningRatioSum
  ER130[i,2] <- result_set$`Buy & Sell Num`
}
meanER130 <- ER130[(is.na(as.numeric(ER130[,1])) == F),]
summary(as.numeric(meanER130[,1])) ## 130개(0.9이상)
#### ark & blocknet - blocknet 12 lag, cor = 0.9752
coin_list_MA7
ark_MA7 <- rev(coin_list_MA7[,2])
blocknet_MA7 <- rev(coin_list_MA7[,10])
ark_closed <- rev(coin_list_closed[,2])
blocknet_closed <- rev(coin_list_closed[,10])

#
par(mfrow=c(2,2))
ts.plot(ark_MA7, col = "red", lwd = 2)
par(new=T)
ts.plot(blocknet_MA7, col = "blue", lwd = 2)
#
ts.plot(ark_closed, col = "red", lwd = 2)
par(new=T)
ts.plot(blocknet_closed, col = "blue", lwd = 2)
#
ts.plot(ark[13:(201)], col = "red", lwd = 2)
par(new=T)
ts.plot(blocknet[1:(201-12)], col = "blue", lwd = 2)
##
#
ts.plot(ark_closed[13:201], col = "red", lwd = 2)
par(new=T)
ts.plot(blocknet_closed[1:(201-12)], col = "blue", lwd = 2)
###
b <- ifelse(diff(blocknet) > 0 ,1,0)
b2 <- c(rep(0,11),sapply(1:(length(b)-11), function(x) sum(b[x:(x+11)])))
b2
which(b2 == 10)
#
ark_closed[27]
ark_closed[54]
#
ark_closed[68]
ark_closed[75]
#
ark_closed[96]
ark_closed[121]
#
ark_closed[135]
ark_closed[138]
######
colnames(coin_list_closed)
ripple_MA7 <- rev(coin_list_MA7[,75])
litecoin_MA7 <- rev(coin_list_MA7[,52])
ripple_closed <- rev(coin_list_closed[,75])
litecoin_closed <- rev(coin_list_closed[,52])

#
par(mfrow=c(2,2))
ts.plot(ripple_MA7, col = "red", lwd = 2)
par(new=T)
ts.plot(litecoin_MA7, col = "blue", lwd = 2)
#
ts.plot(ripple_closed, col = "red", lwd = 2)
par(new=T)
ts.plot(litecoin_closed, col = "blue", lwd = 2)
#
ts.plot(ark[13:(201)], col = "red", lwd = 2)
par(new=T)
ts.plot(blocknet[1:(201-12)], col = "blue", lwd = 2)
##
#
ts.plot(ark_closed[13:201], col = "red", lwd = 2)
par(new=T)
ts.plot(blocknet_closed[1:(201-12)], col = "blue", lwd = 2)
###
