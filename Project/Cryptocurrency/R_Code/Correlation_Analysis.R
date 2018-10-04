require(gtools)
### check data place
coin_list <- read.csv("/Users/hsw/Desktop/개인파일/스터디/Coin_Project/Python_Code/get_coin_price_history2/coin_price_histories_with_ma7.csv.raw"
                      , stringsAsFactors = F, header = F)
colnames(coin_list) <- c("Coin_name", "Date", "Closed_price", "Closed_price_MA7")
str(coin_list)
print("Data Read Finished")

dataHandle_with_raw_fixedNum <- function(mdata, label_index, target_index, date_index, dataNum, past_days = 1){
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


meanEarningRatio <- function(lag_MA7, follow_closed, lagNum, cumNum = 10, buyidx = 8, corr){
  lag_MA7 <- rev(lag_MA7)
  follow_closed <- rev(follow_closed)
  if(corr >= 0){
    UD <- ifelse(diff(lag_MA7) > 0 ,1,0)
  }else{
    UD <- ifelse(diff(lag_MA7) < 0 ,1,0)
  }
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
coin_list_MA7_past_101 <- dataHandle_with_raw_fixedNum(coin_list, 1, 3, 2, 100, 101)
coin_list_closed <- dataHandle_with_raw_fixedNum(coin_list, 1, 4, 2, 100)
print("Data Handling Finished")

corr_result <- find_corr_afterHandle_raw_MA7_up10(coin_list_MA7_past_101, 30)

print("Correlation Analysis Finished")

sort_corr_result <- corr_result[order(abs(as.numeric(corr_result[,6])), decreasing = T),]
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
###
ER400 <- matrix(rep(0,400*2), 400,2)
j <- 0
for(i in 1:400){
  j <- j+1
  mydata <- sort_corr_result[i,]
  result_set <- meanEarningRatio(coin_list_MA7[,which(colnames(coin_list_MA7) == mydata[4])], 
                                 coin_list_closed[,which(colnames(coin_list_closed) == mydata[2])], 
                                 as.numeric(mydata[5]), corr = as.numeric(mydata[6]))
  ER400[i,1] <- result_set$EarningRatioSum
  ER400[i,2] <- result_set$`Buy & Sell Num`
}
meanER400 <- ER400[(is.na(as.numeric(ER400[,1])) == F),]
###
ER40 <- matrix(rep(0,40*2), 40,2)
j <- 0
for(i in 1:40){
  j <- j+1
  mydata <- sort_corr_result[i,]
  result_set <- meanEarningRatio(coin_list_MA7[,which(colnames(coin_list_MA7) == mydata[4])], 
                                 coin_list_closed[,which(colnames(coin_list_closed) == mydata[2])], 
                                 as.numeric(mydata[5]), corr = as.numeric(mydata[6]))
  ER40[i,1] <- result_set$EarningRatioSum
  ER40[i,2] <- result_set$`Buy & Sell Num`
}
meanER40 <- ER40[(is.na(as.numeric(ER40[,1])) == F),]

print("---- All mean Earning Ratio ----")
summary(as.numeric(allER_result[,1])) ## 전체
print("---- Up 400(order by Correlation desc) mean Earning Ratio ----")
summary(as.numeric(meanER400[,1])) ## 400개
print("---- Up 40(order by Correlation desc) mean Earning Ratio ----")
summary(as.numeric(meanER40[,1])) ## 40개(0.9이상)
