args = commandArgs(trailingOnly=TRUE)
data <-read.csv(file = args[1], header=FALSE, sep=";")
jpeg(args[2])
hist(x=data$V1,
     main="expression values of gene CCND3 Cyclin D3",
     ylab="count",
     xlab="gene CCND3 Cyclin D3 expression")
dev.off()