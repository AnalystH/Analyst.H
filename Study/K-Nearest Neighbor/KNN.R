#iris <- read.csv(url("http://archive.ics.uci.edu/ml/machine-learning-databases/iris/iris.data"), header = F)
#names(iris) <- c("Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width", "Species")
head(iris)
install.packages("class")
any(grepl("class", installed.packages())) ## package checking

boxplot(iris)

iris
set.seed(1234)

ind <- sample(1:nrow(iris), nrow(iris), replace=TRUE)

iris.training <- iris[ifelse(ind%%5!=0,ind,0), 1:4]
iris.test <- iris[ifelse(ind%%5==0,ind,0), 1:4]
dim(iris.training)
dim(iris.test)
iris.test[1,]

iris.trainLabels <- iris[ifelse(ind%%5!=0,ind,0), 5]
iris.testLabels <- iris[ifelse(ind%%5==0,ind,0), 5]

############# 패키지 없이 ##################
# 
guess.knn <- function(x, train, trainlabels, k){
  # Calculate the euclidean distance from x to all training set observations:
  xmatrix <- matrix(as.numeric(x), nrow=nrow(train), ncol=length(x), byrow=T)
  xmatrix <- (as.matrix(train)-xmatrix)^2
  diffs <- sqrt(rowSums(xmatrix))
  # Sort the category labels by their euclidean distances:
  diffs <- data.frame(dist=diffs,label=trainlabels)
  diffs <- (diffs[order(diffs$dist),])
  diffs <- diffs[1:k,]
  # Find the most commonly-matched category among the top k results:
  guess <- names(sort(-table(diffs$label)))[1]
  return(guess)
}

##
xmatrix <- matrix(as.numeric(iris.test[1,]), nrow=nrow(iris.training), ncol=length(iris.test[1,]), byrow=T)
xmatrix <- (as.matrix(iris.training)-xmatrix)^2
diffs <- sqrt(rowSums(xmatrix))
diffs <- data.frame(dist=diffs,label=iris.trainLabels)
diffs <- (diffs[order(diffs$dist),])
diffs <- diffs[1:3,]
guess <- names(sort(-table(diffs$label)))[1]
guess
##


knn2 <- function(train, test, trainlabels, k)
{
  results <- apply(test, 1, function(x) guess.knn(x, train, trainlabels, k))
  return(results)
}


result <- knn2(iris.training,iris.test,iris.trainLabels,k=10)
result2 <- c(rep(0,length(result)))

for(i in 1:length(result)){
  result2[i] <- result[[i]]
}

result2

###
#
#
#############################################


library("class")
iris_pred <- knn(train = iris.training, test = iris.test, cl = iris.trainLabels, k=10)
summary(iris_pred)
getAnywhere('knn')

check <- data.frame(pred1 = iris_pred, pred2 = result2, real = iris.testLabels)
check
mean(check[,1] == check[,3])
sum(check[,1] != check[,2])

#######
#
#
#
#
## Choose k with bootstrap idea ##
set.seed(123)

B <- 1000
mat <- matrix(c(rep(0,80)),40,2)
n.set <- lapply(1:B,function(i) sample(1:nrow(iris),nrow(iris),replace=T))
for(z in 1:40){
  d.tr.r <- 0
  d.tr2 <- 0
  boot.data <- function(x){
    d.tr <- iris[ifelse(x%%5 !=0,x,0),1:4]
    d.te <- iris[ifelse(x%%5 ==0,x,0),1:4]
    d.tr.l <- iris[ifelse(x%%5 !=0,x,0),5]
    d.te.l <- iris[ifelse(x%%5 ==0,x,0),5]
    pred <- knn(train = d.tr, test = d.te, cl = d.tr.l, k=z)
    two <- data.frame(pred = pred, real = d.te.l)
    fittness <- mean(two[,1] == two[,2])
    return(fittness)
  }
  d.tr2 <- sapply(n.set,boot.data)
  d.tr.r <- c(mean(d.tr2),var(d.tr2))
  mat[z,] <- d.tr.r
}
mat

