set.seed(2)
mat <- matrix(rnorm(1000),500,2)
mat[1:250,1] <- mat[1:250,1]+4
mat[1:250,2] <- mat[1:250,2]-3

#
#set.seed(2)
#mat <- matrix(rnorm(10000),5000,2)
#mat[1:2500,1] <- mat[1:2500,1]+4
#mat[1:2500,2] <- mat[1:2500,2]-3
#

par(mfrow=c(1,1))
q <- as.factor(sample(c(1:2),size=500,replace=T))
mat2 <- cbind(mat,q)
mat2
plot(mat2,col=mat2[,3])
tapply(mat[,1],q,mean) 
tapply(mat[,2],q,mean)
w11 <- c(tapply(mat[,1],q,mean)[[1]],tapply(mat[,2],q,mean)[[1]])
w21 <- c(tapply(mat[,1],q,mean)[[2]],tapply(mat[,2],q,mean)[[2]])
mat.w1 <- matrix(w11,nrow=500,ncol=2,byrow=T)
mat.w2 <- matrix(w21,nrow=500,ncol=2,byrow=T)
d.mat.w1 <- rowSums((mat.w1 - mat2[,1:2])^2)
d.mat.w2 <- rowSums((mat.w2 - mat2[,1:2])^2)
color1 <- (d.mat.w1>d.mat.w2)+1
plot(mat2[,1:2],col=color1)



##

mat3 <- cbind(mat,color1)
w12 <- c(tapply(mat[,1],color1,mean)[[1]],tapply(mat[,2],color1,mean)[[1]])
w22 <- c(tapply(mat[,1],color1,mean)[[2]],tapply(mat[,2],color1,mean)[[2]])
mat.w12 <- matrix(w12,nrow=500,ncol=2,byrow=T)
mat.w22 <- matrix(w22,nrow=500,ncol=2,byrow=T)
d.mat.w12 <- rowSums((mat.w12 - mat)^2)
d.mat.w22 <- rowSums((mat.w22 - mat)^2)
color2 <- (d.mat.w12 > d.mat.w22)+1
plot(mat3[,1:2],col=color2)

par(mfrow=c(1,2))
plot(mat,col=color1)
plot(mat,col=color2)

##
par(mfrow=c(1,1))
mat4 <- cbind(mat,color2)
w13 <- c(tapply(mat[,1],color2,mean)[[1]],tapply(mat[,2],color2,mean)[[1]])
w23 <- c(tapply(mat[,1],color2,mean)[[2]],tapply(mat[,2],color2,mean)[[2]])
mat.w13 <- matrix(w13,nrow=500,ncol=2,byrow=T)
mat.w23 <- matrix(w23,nrow=500,ncol=2,byrow=T)
d.mat.w13 <- rowSums((mat.w13 - mat)^2)
d.mat.w23 <- rowSums((mat.w23 - mat)^2)
color3 <- (d.mat.w13 > d.mat.w23)+1
plot(mat,col=color3)

par(mfrow=c(1,3))
plot(mat,col=color1)
plot(mat,col=color2)
plot(mat,col=color3)

sum(color2 != color3)

###
## repeat 문
j <- 0
repeat{
  j <- j+1
  print(j)
  if(j == 10) break
}
##
###
par(mfrow=c(1,1))

kmeans.hand.1 <- function(data,k){
  q <- as.factor(sample(c(1:k),size=nrow(data),replace=T))
  data <- cbind(data,q)
  index <- list()
  index[[1]] <- data[,3]
  j <- 1
  repeat {
    j <- j+1
    w <- lapply(1:k,function(x) matrix(c(tapply(data[,1],index[[j-1]],mean)[[x]],tapply(data[,2],index[[j-1]],mean)[[x]]),ncol=2,nrow=nrow(data),byrow=T))
    distance <- sapply(w,function(x) rowSums((x-data[,1:2])^2))
    index[[j]] <- apply(distance,1,which.min)
    if (sum(index[[j]] != index[[j-1]]) == 0) break
  }
  plot(data[,1:2],col=index[[j]]+1,pch=20, cex=2,main="K-Means Clustering by hand")
}

##

kmeans.hand.2<- function(data,k){
  q <- as.factor(sample(c(1:k),size=nrow(data),replace=T))
  data <- cbind(data,q)
  index <- list()
  index[[1]] <- data[,3]
  j <- 1
  repeat {
    l <-length(table(index[[j]]))
    j <- j+1
    w <- lapply(1:l,function(x) matrix(c(tapply(data[,1],index[[j-1]],mean)[[x]],tapply(data[,2],index[[j-1]],mean)[[x]]),ncol=2,nrow=nrow(data),byrow=T))
    distance <- sapply(w,function(x) rowSums((x-data[,1:2])^2))
    index[[j]] <- apply(distance,1,which.min)
    if (sum(index[[j]] != index[[j-1]]) == 0) break
  }
  plot(data[,1:2],col=index[[j]]+1,pch=20, cex=2,main="K-Means Clustering by hand")
}

###

kmeans.hand.3 <- function(data,k){
  q <- as.factor(sample(c(1:k),size=nrow(data),replace=T))
  data <- cbind(data,q)
  index <- list()
  index[[1]] <- data[,3]
  j <- 1
  repeat {
    if(length(table(index[[j]])) != k){
      index[[j]] <- as.factor(sample(c(1:k),size=nrow(data),replace=T))
    }
    j <- j+1
    w <- lapply(1:k,function(x) matrix(c(tapply(data[,1],index[[j-1]],mean)[[x]],tapply(data[,2],index[[j-1]],mean)[[x]]),ncol=2,nrow=nrow(data),byrow=T))
    distance <- sapply(w,function(x) rowSums((x-data[,1:2])^2))
    index[[j]] <- apply(distance,1,which.min)
    if (sum(index[[j]] != index[[j-1]]) == 0) break
  }
  return(index[[j]])
}

##

par(mfrow=c(1,1))
kmeans.hand.1(mat,3)
kmeans.hand.2(mat,10)
km.out <- kmeans(mat,3)
plot(mat, col=(km.out$cluster+1), main="K-Means Clustering Results with package", xlab="", ylab="", pch=20, cex=2)
km.out$cluster

##

kmeans.hand.3(mat,10)
check1 <- kmeans.hand.3(mat,3)
plot(mat,col=check1+1,pch=20, cex=2,main="K-Means Clustering by hand")
check2 <- kmeans(mat,8)$cluster
plot(mat,col=check2+1,pch=20, cex=2,main="K-Means Clustering by hand")
