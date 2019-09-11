rm(list=ls())
args = commandArgs(trailingOnly=TRUE)
pref.ref = ifelse(length(args) >= 1, args[1], "data/kgn_EUR")
pref.stu = ifelse(length(args) >= 2, args[2], "data/ukb_oadpEUR")

# load ref samples
x.colnames = c("fid", "iid", paste0("PC", 1:4))
methods = c("sp", "ap", "oadp", "adp")
x.ref = read.table(paste0(pref.ref, ".pcs"), header=T)
colnames(x.ref) = x.colnames
x.ref$col = as.integer(x.ref$fid) + 1
x.ref$pch = as.integer(x.ref$fid) + 1

# load study samples
x.stu = list()
for(method in methods){
    infile = paste0(pref.stu, "_", method, ".pcs")
    if(file.exists(infile)){
        x.stu[[method]] = read.table(infile, header=F)
        colnames(x.stu[[method]]) = x.colnames
        x.stu[[method]]$fid = factor(x.stu[[method]]$fid, levels=levels(x.ref$fid))
        x.stu[[method]]$col = as.integer(x.stu[[method]]$fid) + 1
        x.stu[[method]]$pch = as.integer(x.stu[[method]]$fid) + 1
    }
}
methods = names(x.stu)

browser()
PC1.lim = quantile(c(sapply(methods, function(method) x.stu[[method]]$PC1), x.ref$PC1), c(0,1))
PC2.lim = quantile(c(sapply(methods, function(method) x.stu[[method]]$PC2), x.ref$PC2), c(0,1))
PC3.lim = quantile(c(sapply(methods, function(method) x.stu[[method]]$PC3), x.ref$PC3), c(0,1))
PC4.lim = quantile(c(sapply(methods, function(method) x.stu[[method]]$PC4), x.ref$PC4), c(0,1))

# plot ref pcs
out.filename = paste0(pref.ref, ".png")
print(out.filename)
png(out.filename, 2000, 1000)
par(mfrow=c(1,2), cex=2)
main = "Reference samples"
plot(x.ref$PC1, x.ref$PC2, xlab="PC1", ylab="PC2", col=x.ref$col, pch=x.ref$pch, main=main, xlim=PC1.lim, ylim=PC2.lim)
plot(x.ref$PC3, x.ref$PC4, xlab="PC3", ylab="PC4", col=x.ref$col, pch=x.ref$pch, main=main, xlim=PC3.lim, ylim=PC4.lim)
legend("topright", legend=paste("Ref.", unique(x.ref$fid)), col=unique(x.ref$col), pch=unique(x.ref$pch))
dev.off()

# plot study pcs
for(method in methods){
    out.filename = paste0(pref.stu, "_", method, ".png")
    print(out.filename)
    png(out.filename, 2000, 1000)
    par(mfrow=c(1,2), cex=2)
    main = paste0("Study samples (method: ", method, ")")
    plot(x.stu[[method]]$PC1, x.stu[[method]]$PC2, xlab="PC1", ylab="PC2", col=x.stu[[method]]$col, pch=x.stu[[method]]$pch, main=main, xlim=PC1.lim, ylim=PC2.lim)
    plot(x.stu[[method]]$PC3, x.stu[[method]]$PC4, xlab="PC3", ylab="PC4", col=x.stu[[method]]$col, pch=x.stu[[method]]$pch, main=main, xlim=PC3.lim, ylim=PC4.lim)
    legend("topright", legend=paste("Stu.", unique(x.ref$fid)), col=unique(x.ref$col), pch=unique(x.ref$pch))
    dev.off()
}
