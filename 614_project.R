
##########################  Impoarting data ##########################

library(readxl)
library(ggplot2)
library(MSQC)
library(factoextra)
library(qcc)

data <- read_xlsx("Project_dataset.xlsx", col_names = FALSE)


df1 <- as.matrix.data.frame(data)
df2 <- as.matrix.data.frame(df1)

##########################  Initialize variables ##########################

UCL<- NULL
LCL<- NULL
y<- NULL
out_up<-NULL
out_low<-NULL

S <- cov(df2)
n <- nrow(df2)
p <- ncol(df2)
mu <-colMeans((df2))

################### Decide number of Principle components ##################
#methods used are Scree plot and Minimum Desciption Length Analysis

pcaCharts <- function(x) {
  x.var <- x$sdev ^ 2
  x.pvar <- x.var/sum(x.var)
  print("cumulitive proportions of variance:")
  print(cumsum(x.pvar[1:35]))
  
  par(mfrow=c(2,2))
  plot(x.pvar[1:20],xlab="Principal component", ylab="Proportion of variance explained", ylim=c(0,1), type='b')
  plot(cumsum(x.pvar[1:20]),xlab="Principal component", ylab="Cumulative Proportion of variance explained", ylim=c(0,1), type='b')
  screeplot(x)
  screeplot(x,type="l")
  par(mfrow=c(1,1))
}



### Screeplot
pdf(file= "PC Analysis - screeplot.pdf" )

df2.PCA <- prcomp(df2)
var_explained = df2.PCA$sdev^2 / sum(df2.PCA$sdev^2)
pcaCharts(df2.PCA)

dev.off() 

### MDL Analysis

pdf(file= "PC Analysis - MDL.pdf" )

eigen_values <- eigen(S)$values
MDL<-c(rep(0,250))
l<- c(1:250)
for (k in 1:250) {
  
  al<- mean(eigen_values[(k+1):251]) 
  gl<- exp(mean(log(eigen_values[(k+1):251])))
  MDL[k]<- n*(251-k)*log(al/gl)+k*(2*251-k)*log(n)/2
  
}
plot(l,MDL, xlab = "l", ylab = "MDL", col="red",)
optimum_MDL<-which.min(MDL)
optimum_MDL

dev.off()

#---- PCA Analysis using Covariance ----
#The loop is used to create a monitoring chart untill all outliers are removed. The control charts are saved in pdf file

pdf(file= "PCA Cov1.pdf" )

par(mfrow=c(2,2))


p <- 5  #no of PC used


for (j in 1:10){
  
  n<- nrow(df2)        # no of rows
  S = cov(df2)
  x1<- matrix(1:n,nrow = 1,byrow = TRUE)
  y<- prcomp(df2)$x
  
  for (i in 1:p){
    UCL[i]<- 3*sqrt(eigen(S)$values[i])
    LCL[i]<- -3*sqrt(eigen(S)$values[i])
    out_up[i]<-list(which(t(y[,i])>UCL[i]))
    out_low[i]<-list(which(t(y[,i])<LCL[i]))
    plot(x1,y[,i], col="blue", main = paste("Iteration J = ",j), xlab = "X", ylab =paste("PC",i))
    lines(x1, rep(UCL[[i]],n), col="red",lty=2)
    lines(x1,rep(LCL[[i]],n),col="red",lty=2)
  }
  
  outliers <- unlist(c(out_up,out_low))
  list(outliers)
  if (is.null(outliers) | length(outliers)==0)
    break
  df2<-df2[-outliers,]
  print(outliers)
}

dim(df2)
df2.PCA2 <- prcomp(df2)
var_explained2 = df2.PCA2$sdev^2 / sum(df2.PCA2$sdev^2)
sum(var_explained2[1:p])
sum(var_explained[1:p])

dev.off()

#the pdf file will contain all univariate control charts based on number of PC selected 

#mCUSUM chart for detecting sustained mean shift
#---- mCUSUM Analysis ---- 

### Choose k and h
###
pdf(file= "mCUSUM.pdf" )
par(mfrow=c(2,2))

k <- list(0.5,0.7,1.0,1.2,1.5, 1.7, 2)  # various values of k tested.

#for (j in 1:7){

df3 <- as.matrix.data.frame(df1)
df3.centered <- scale(df3, scale = F, center = T)
df3.PCA <- prcomp(df3.centered)


for (i in 1:10){
  
  df3.PCA <- prcomp(df3.centered)
  df.pca <- df3.PCA$x[,1:p]
  df.pca <- as.data.frame(df.pca)
  mcusum <- mult.chart(x = df.pca, type = "mcusum2", alpha=0.0027, k = 1, h = 20, method = "sw")
  outliers.cusum <- which(mcusum$t2 > mcusum$ucl)
  if (is.null(outliers.cusum) | length(outliers.cusum)==0)
    break
  df3.centered <- df3.centered[-outliers.cusum,]
  #print(outliers.cusum)
}
var_explained.cusum = df3.PCA$sdev^2 / sum(df3.PCA$sdev^2)
#print("iteration = ", j)
print(dim(df3.centered))
print(sum(var_explained.cusum[1:p]))
#}
dev.off()
####### Performace