library(forecast)
library(fpp)

mydata <- read.csv("semifinal.csv", header = T, fileEncoding = 'euc-kr', stringsAsFactors = F)
str(mydata)
unique(mydata[,2])
colnames(mydata)

1/sqrt(5)*(((1+sqrt(5))/2)^1 - ((1-sqrt(5))/2)^1 )


fibonacci_hsw <- function(n){
  if(is.numeric(n) == F){
    stop("Variable Must be Numeric")
  }else if(n <= 0){
    stop("Variable Must be at least One")
  }else{
    fibo <- sapply(1:n, function(x) 1/sqrt(5)*(((1+sqrt(5))/2)^x - ((1-sqrt(5))/2)^x))
    return(fibo)
  }
}
fibonacci_hsw(100)[100]

test_mat <- matrix(c(1,1,1,1,1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1),4,5)
eigen(t(test_mat) %*% test_mat)$values


####
str(coin_list)
coin_list_closed <- dataHandle_with_raw_fixedNum(coin_list, 1, 4, 2, 800)
colnames(coin_list_closed)
bitcoin <- log(as.numeric(rev(coin_list_closed[,2])))
eth <- as.numeric(rev(coin_list_closed[,21]))
rev(coin_list_closed[,2])[720]

var_cor <- rep(0,60)
for(i in 21:80){
  data1 <- lapply(1:(round(length(eth)/i)-1), function(x) eth[(i*(x-1)+1):(i*x)])
  possibleNum <- combinations(n = (round(length(eth)/i)-1), r = 2)
  all_cor <- sapply(1:dim(possibleNum), function(x) cor(data1[[possibleNum[x,][2]]], data1[[possibleNum[x,][1]]]))
  var_cor[i-20] <- var(all_cor)
}
which.min(var_cor)


?plot


