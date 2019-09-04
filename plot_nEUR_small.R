rm(list=ls())
args = commandArgs(trailingOnly=TRUE)
pref.ref = ifelse(length(args) >= 1, args[1], "data/kgn_nEUR")
pref.stu = ifelse(length(args) >= 2, args[2], "data/ukb_small")
x.ref = read.table(paste0(pref.ref, ".pcs"), header=T)
x.stu = read.table(paste0(pref.stu, ".pcs"), header=T)
x.colnames = c("fid", "iid", paste0("PC", 1:4))
colnames(x.ref) = x.colnames
colnames(x.stu) = x.colnames
x.stu$fid = factor(x.stu$fid, levels=levels(x.ref$fid))
col.ref = as.integer(x.ref$fid) + 1
pch.stu = as.integer(x.stu$fid) + 1

out.filename = paste0(pref.stu, ".png")
png(out.filename, 2000, 1000)
par(mfrow=c(1,2), cex=2)
plot(x.ref$PC1, x.ref$PC2, col=col.ref)
points(x.stu$PC1, x.stu$PC2, pch=pch.stu)
plot(x.ref$PC3, x.ref$PC4, col=col.ref)
points(x.stu$PC3, x.stu$PC4, pch=pch.stu)
legend("topright", legend=paste("Ref.", levels(x.ref$fid)), col=(1:length(levels(x.ref$fid)))+1, pch=1)
legend("bottomright", legend=paste("Stu.", levels(x.ref$fid)), pch=(1:length(levels(x.stu$fid)))+1)
dev.off()
