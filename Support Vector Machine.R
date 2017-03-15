set.seed(100)
x <- matrix(rnorm(20*2), ncol=2)
x <- round(x * 10)
y <- c(rep(-1,10), rep(1,10))
x[y==1,] <- x[y==1,] + 15
plot(x,type='n')
points(x[y==1,])
points(x[y==-1,],pch=2)

library(e1071)
mydat <- data.frame(x=x,y=as.factor(y))
fit.1 <- svm(y~., data=mydat, kernel="linear", cost=1,scale=FALSE)
plot(fit.1, mydat)

abline(a=10,b=-1)
fit.1$index ## support vector
x[fit.1$index,]
summary(fit.1)

?svm
fit.2 <- svm(y~., data=mydat, kernel="linear", cost=0.001,scale=FALSE)
plot(fit.2, mydat)
fit.2$index ## support vector
x[fit.2$index,]
summary(fit.2)


x <- matrix(c(-1,1,-1,3,-2,-2,-2,1),4,2)
y <- as.factor(c(-1,-1,1,1))
mydat2 <- data.frame(x=x,y=y)
fit.3 <- svm(y~., data= mydat2, kernel="linear", cost=0.01, scale=F)
plot(fit.3,mydat2)

t.x <- matrix(c(1,-1,-1,2,2,-2),3,2)
t.y <- c(-1,-1,1)
z <- t.x * t.y
z%*%t(z)

install.packages("quadprog")

?solve.QP


#############


set.seed(1)
x <- matrix(rnorm(20*2), ncol=2)
y <- c(rep(-1,10), rep(1,10))
x[y==1,] <- x[y==1,] + 3
plot(x, col=(3-y))
dat <- data.frame(x=x, y=as.factor(y))

##
library(e1071)
sv <- svm(y~., data=dat, kernel="linear", cost=0.05, scale=FALSE)
sv$decision.values
sv$index


##
nonzero <-  abs(qpsol) > 0.00001
index <- which(nonzero)
qpsol[index] * y[index]
sv$coefs
#
sv$SV
x[index,]
##

W <- t(sv$coefs) %*% sv$SV
W2 <- rowSums(sapply(index, function(i) qpsol[i]*y[i]*x[i,]))
W.y <- rowSums(sapply(1:length(sv$coefs), function(i) sv$coefs[i]*sv$SV[i,]*y[i]))

mean(sapply(sv$index, function(i) x[i,] %*% W.y - y[i]))
sv$rho # negative intercept
svmline <-  c(sv$rho/W[2], -W[1]/W[2])
plot(sv,dat)

W %*%t(x) - sv$rho
##
decision.val1 <- t(W %*% t(x)- sv$rho)
decision.val2 <- sv$decision.values
sum(round(decision.val1,5) != round(decision.val2,5))
##
#############

mat <- x*y
newmat <- mat %*% t(mat)
uu <- 0.01     # C
eps <- 1e-11    
b <- 0
r <- 0
A2 <- t(y)
l <- matrix(0, nrow=n, ncol=1)
u <- matrix(uu, nrow=n, ncol=1)
sol2 <- ipop(-dvec, newmat, A2, b, l, u, r, margin=1e-10) # toggle margin and sigf if fails to converge.
ipopsol <- primal(sol2)
sv$index
ipopsol
which(abs(ipopsol)>0.001)

findLine <- function(sol, y, x){
  nonzero <-  abs(sol) > 0.001
  index <- which(nonzero)
  W <- rowSums(sapply(index, function(i) sol[i]*y[i]*x[i,]))
  b <- mean(sapply(index, function(i) x[i,] %*% W - y[i]))
  slope <- -W[1]/W[2]
  intercept <- b/W[2]
  return(c(intercept,slope))
}

ipopline <- findLine(ipopsol, y, x)
ipopline

W <- rowSums(sapply(1:length(sv$coefs), function(i) sv$coefs[i]*sv$SV[i,]))
svmline <- c(sv$rho/W[2], -W[1]/W[2])
svmline
