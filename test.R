index <- as.factor(sample(c(1:k),size=nrow(qw),replace=T))
qw2 <- cbind(qw,q)
for(i in 1:k){
  w[[i]] <-  matrix(c(tapply(mat3[,1],q,mean)[[i]],tapply(mat3[,2],q,mean)[[i]]),ncol=2,nrow=nrow(qw),byrow=T)
}
distance <- sapply(1:k,function(x) rowSums((w[[x]]-qw[,1:2])^2))
index <- apply(distance,1,which.min)

k
kmeans.hand <- function(qw,k){
  set.seed(2)
  qw <- matrix(rnorm(1000),500,2)
  qw[1:250,1] <- qw[1:250,1]+4
  qw[1:250,2] <- qw[1:250,2]-3
  k <- 10
  q <- as.factor(sample(c(1:k),size=nrow(qw),replace=T))
  qw <- cbind(qw,q)
  w <- list()
  index <- list()
  index[[1]] <- qw[,3]
  j <- 1
  repeat {
    l <-length(table(index[[j]]))
    for(i in 1:l){
      w[[i]] <-  matrix(c(tapply(qw[,1],index[[j]],mean)[[i]],tapply(qw[,2],index[[j]],mean)[[i]]),ncol=2,nrow=nrow(qw),byrow=T)
    }
    distance <- sapply(1:k,function(x) rowSums((w[[x]]-qw[,1:2])^2))
    index[[j+1]] <- apply(distance,1,which.min)
    j <- j+1
    if (sum(index[[j]] != index[[j-1]]) == 0) break
  }
  j
  index[[2]]
  
  #return(index[[j]])
  plot(qw[,1:2],col=index[[j]]+1,pch=20, cex=2)
  
}
index[[j]]
par(mfrow=c(1,2))
tapply(qw[,1],index[[1]],mean)[[1]]
apply(distance,1,which.min)
distance
?which.min
aa <- rnorm(100)
order(distance[1,])
distance[1,]

a <- 0
repeat{
  a <- a+1
  print(a)
  if(a==10) break
}


#a <- mat2 %*% t(mat2)
#b <- t(mat2) %*% mat2
#val1 <- eigen(a)$values
#val2 <- eigen(b)$values
#val3 <- svd(mat2)$d
#val1;val2;val3^2

kmeans.hand.3 <- function(data,k){
  q <- as.factor(sample(c(1:k),size=nrow(data),replace=T))
  data <- cbind(data,q)
  w <- list()
  index <- list()
  index[[1]] <- data[,3]
  j <- 1
  repeat {
    if(length(table(index[[j]])) != k){
      index[[j]] <- as.factor(sample(c(1:k),size=nrow(data),replace=T))
    }
    j <- j+1
    for(i in 1:k){
      w[[i]] <-  matrix(c(tapply(data[,1],index[[j-1]],mean)[[i]],tapply(data[,2],index[[j-1]],mean)[[i]]),ncol=2,nrow=nrow(data),byrow=T)
    }
    distance <- sapply(1:k,function(x) rowSums((w[[x]]-data[,1:2])^2))
    index[[j]] <- apply(distance,1,which.min)
    print(j)
    if (sum(index[[j]] != index[[j-1]]) == 0) break
  }
  #return(index[[j]])
}


kmeans.hand.4 <- function(data,k){
  q <- as.factor(sample(c(1:k),size=nrow(data),replace=T))
  data <- cbind(data,q)
  w <- list()
  index <- list()
  index[[1]] <- data[,3]
  j <- 1
  repeat {
    if(length(table(index[[j]])) != k){
      index[[j]] <- as.factor(sample(c(1:k),size=nrow(data),replace=T))
    }
    j <- j+1
    w <- lapply(1:k,function(x) matrix(c(tapply(data[,1],index[[j-1]],mean)[[x]],tapply(data[,2],index[[j-1]],mean)[[x]]),ncol=2,nrow=nrow(data),byrow=T))
    distance <- sapply(1:k,function(x) rowSums((w[[x]]-data[,1:2])^2))
    index[[j]] <- apply(distance,1,which.min)
    print(j)
    if (sum(index[[j]] != index[[j-1]]) == 0) break
  }
  #return(index[[j]])
}
set.seed(5)
test.time <- proc.time()
kmeans.hand.3(mat,16)
proc.time() - test.time

set.seed(5)
test.time <- proc.time()
kmeans.hand.4(mat,16)
proc.time() - test.time

check1 <- kmeans.hand.4(mat,10)
plot(mat[,1:2],col=check1+1,pch=20, cex=2,main="K-Means Clustering by hand")
kmeans.hand.3(mat,5)

zz <- lapply(1:2,function(x) matrix(c(tapply(mat[,1],q,mean)[[x]],tapply(mat[,2],q,mean)[[x]]),ncol=2,nrow=nrow(mat),byrow=T))
?proc.time
