#### half and half


# 파일 불러올 때
# 1. Working directory 설정 후 그 디렉토리 안에 있는 파일명으로 불러오기
# 2. 애초에 절대경로로 파일이 위치한 곳의 경로를 다 입력하기
# 아래 [directory]는 파일이 위치한 곳으로 입력하셔도 되고, 아니면 1번 방법처럼 working directory를 해당 데이터 파일에 있는 곳으로 설정 후 파일 이름만 쓰시면 됩니다.
# stringAsFactors - 파일을 불러올 때 default로 문자열은 factor변수로 가져오는데, 핸들링하기에 어려움이 있어 저같은 경우는 문자열 변수는 그냥 문자열로 읽어오라고 False로 설정을 합니다. 

coin_list <- read.csv("[directory]/coin_price_histories_with_ma7.csv.raw"
                      , stringsAsFactors = F, header = F)

label <- unique(coin_list[,1]) ## 고유한 코인이름 가져오기

## lapply = list apply, 위에서 정의한 label별로 리스트를 만들고, 각 리스트마다 각 코인들 데이터 집어넣기. ex. 1번째 리스트에는 aeon 데이터, 2번째 리스트에는 ark 데이터
allData <- lapply(1:length(label), function(x) coin_list[(coin_list[,1] == label[x]),])

## pdf파일을 만들어서 아래 "dev.off()"가 나올때 까지 그린 plot들을 저장. 이 때 working directory를 설정해주시지 않았다면 home에 생성이 될 거에요.
pdf("coin_half_log_scale_percent.pdf")


 
#  (리스트는 [[]] 대괄호를 이렇게 2개 써야 가져와져요.)
# for 루프는 위에서 정의한 리스트에서 3번째 열이 종가 데이터 인데, 그 데이터로 log10을 취하면 로그데이터가 되고 그걸 가지고 그리는 작업을 취했습니다.

for(i in 1:length(label)){
  price <- log10(rev(allData[[i]][,3]))  
#  price <- (max(price)-price)/price ## 최댓값 대비 percent
  ts.plot(price, lwd = 1.5, main = allData[[i]][1,1]) ## 선그래프 그리기, main - 그림 제목을 각 리스트의 [1,1] 데이터로. [1,1] 데이터 = 코인명
  min_val <- rep(0,10)
  max_val <- rep(0,10)
  min_val[1] <- min(price)
  max_val[1] <- max(price)
  m <- rep(0,10)
  m[1] <- (min_val[1] + max_val[1]) / 2
  abline(h = min_val[1], col = "red") ## 그래프 그린 거 위에 추가로 선을 그려주는 함수. h <- 수평선
  abline(h = m[1], col = "red")
  abline(h = max_val[1], col = "red")
  min_val[2] <- m[1]
  max_val[2] <- m[1]
  m[2] <- (min_val[2] + max_val[1]) / 2
  m[3] <- (min_val[1] + max_val[2]) / 2
  abline(h = m[2], col = "red")
  abline(h = m[3], col = "red")
  abline(h = (m[2] + max_val[1]) / 2, col = "red")
  abline(h = (m[3] + max_val[1]) / 2, col = "red")
  abline(h = (m[2] + min_val[1]) / 2, col = "red")
  abline(h = (m[3] + min_val[1]) / 2, col = "red")
  m[4] <- (m[2] + max_val[1]) / 2
  m[5] <- (m[3] + max_val[1]) / 2
  m[6] <- (m[2] + min_val[1]) / 2
  m[7] <- (m[3] + min_val[1]) / 2
  abline(h = (m[4] + max_val[1]) / 2, col = "red")
  abline(h = (m[4] + m[2]) / 2, col = "red")
  abline(h = (m[4] + m[2]) / 2, col = "red")
  abline(h = (m[5] + m[2]) / 2, col = "red")
  abline(h = (m[5] + m[1]) / 2, col = "red")
  abline(h = (m[6] + m[1]) / 2, col = "red")
  abline(h = (m[6] + m[3]) / 2, col = "red")
  abline(h = (m[6] + m[3]) / 2, col = "red")
  abline(h = (m[7] + m[3]) / 2, col = "red")
  abline(h = (m[7] + min_val[1]) / 2, col = "red")
}
dev.off()


