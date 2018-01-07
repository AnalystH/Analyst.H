## 참고
# https://gist.github.com/rwalk/64f1365f7a2470c498a4
##

install.packages("kernlab")
install.packages("e1071")
library("kernlab")
library("e1071")

set.seed(1)
x <- matrix(rnorm(100*2), ncol=2)
y <- c(rep(-1,50), rep(1,50))
x[y==1,] <- x[y==1,] + 3
plot(x, col=(3-y))
dat <- data.frame(x=x, y=as.factor(y))

##

library(e1071)
sv <- svm(y~., data=dat, kernel="linear", cost=5, scale=FALSE)
sv$decision.values
sv$index


W <- t(sv$coefs) %*% sv$SV
W.y <- rowSums(sapply(1:length(sv$coefs), function(i) sv$coefs[i]*sv$SV[i,]*y[i]))


mean(sapply(sv$index, function(i) x[i,] %*% W.y - y[i]))
sv$rho # negative intercept
svmline <-  c(sv$rho/W[2], -W[1]/W[2]) # find c(intercept, slope)
svmline
plot(sv,dat)



##
decision.val1 <- t(W %*% t(x)- sv$rho)
decision.val2 <- sv$decision.values
sum(round(decision.val1,5) != round(decision.val2,5))

##
#############
# min(c'*x + 1/2 * x' * H * x)
# subject to: 
# b <= A * x <= b + r
# l <= x <= u

library("kernlab")
mat <- x*y
n <- nrow(x)
uu <- 5    # Cost
eps <- 1e-11    
b <- 0
r <- 0
A2 <- t(y)
newmat <- mat %*% t(mat) + eps*diag(n)
dvec <- matrix(1, nrow=n)
l <- matrix(0, nrow=n, ncol=1)
u <- matrix(uu, nrow=n, ncol=1)
sol2 <- ipop(-dvec, newmat, A2, b, l, u, r, margin=1e-4) # toggle margin and sigf if fails to converge.
ipopsol <- primal(sol2)
sv$index
which(abs(ipopsol)>0.0001)

findLine <- function(sol, y, x){
  nonzero <-  abs(sol) > 0.0001
  index <- which(nonzero)
  W <- rowSums(sapply(index, function(i) sol[i]*y[i]*x[i,]))
  b <- mean(sapply(index, function(i) x[i,] %*% W - y[i]))
  slope <- -W[1]/W[2]
  intercept <- b/W[2]
  return(c(intercept,slope))
}

ipopline <- findLine(ipopsol, y, x)
ipopline
svmline
plot(sv,dat)


##

nonzero <-  abs(ipopsol) > 0.0001
index <- which(nonzero)
coefs.hand <- ipopsol[index] * y[index]
coefs.package <- sv$coefs
coefs.hand
coefs.package
coefs.hand + coefs.package

##

sv$SV
x[index,]

##
W <- t(sv$coefs) %*% sv$SV
W2 <- rowSums(sapply(index, function(i) ipopsol[i]*y[i]*x[i,]))
W
W2

##########
## 커널트릭은 support vector 찾는 데만 우선 중점.
## 커널트릭을 쓰면 decision Boundary가 비선형이므로, 앞에 선형처럼 기울기랑 절편을 구할 수 없다. ##

sv2 <- svm(y~., data=dat, kernel="polynomial",coef0=4,degree=2,gamma=3, cost=0.0001, scale=FALSE)
sv2$index


n <- nrow(x)
uu <- 0.0001    # Cost
eps <- 1e-11   
b <- 0
r <- 0
A2 <- t(y)
newmat2 <- (4+3*x %*% t(x))^2*(y%*%t(y)) + eps*diag(n) ## 바뀐점.
dvec <- matrix(1, nrow=n)
l <- matrix(0, nrow=n, ncol=1)
u <- matrix(uu, nrow=n, ncol=1)
sol2 <- ipop(-dvec, newmat2, A2, b, l, u, r, sigf=4,margin=1e-5)
ipopsol2 <- primal(sol2)

sv2$index
which(abs(ipopsol2)>0.00003) ## 타협점이 필요. 어느점부터 0보다 크다고 볼 것인가.
