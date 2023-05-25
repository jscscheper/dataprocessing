args = commandArgs(trailingOnly=TRUE)
d <- as.matrix(read.csv(args[1], header=FALSE, sep=",")[-1,-1])
rownames(d) <- read.csv(args[1], header=FALSE, sep=",")[-1,1]
colnames(d) <- read.csv(args[1], header=FALSE, sep=",")[1,-1]
jpeg(args[2])
heatmap(d)
dev.off()
