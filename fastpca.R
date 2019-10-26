infile = "data/kgnukb.pcs"
x.colnames = c("popu", paste0("PC", 1:4))
x = read.table(infile, row.names=2)
colnames(x) = x.colnames
x$col = as.integer(x$popu)
x$pch = as.integer(x$popu)
x.legend = unique(x[,c("popu", "col", "pch")])
m = length(unique(x$popu))
png("data/kgnukb.png", 2000, 1000)
par(mfrow=c(1,2), oma=c(0,0,4,0), cex=2)
is.ukb = x$popu == "_UKB"
plot(x$PC1[is.ukb], x$PC2[is.ukb], col=x$popu[is.ukb], pch=as.integer(x$popu[is.ukb]), xlab="PC1", ylab="PC2")
points(x$PC1[!is.ukb], x$PC2[!is.ukb], col=x$popu[!is.ukb], pch=as.integer(x$popu[!is.ukb]))
plot(x$PC3[is.ukb], x$PC4[is.ukb], col=x$popu[is.ukb], pch=as.integer(x$popu[is.ukb]), xlab="PC3", ylab="PC4")
points(x$PC3[!is.ukb], x$PC4[!is.ukb], col=x$popu[!is.ukb], pch=as.integer(x$popu[!is.ukb]))
legend("bottomright", legend=x.legend$popu, col=x.legend$col, pch=x.legend$pch)
mtext("PCA of UKBiobank and 1000 Genomes Combined", outer = TRUE, cex=3)
dev.off()



