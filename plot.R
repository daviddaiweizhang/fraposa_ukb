rm(list=ls())
set.seed(123)

args = commandArgs(trailingOnly=TRUE)
pref.ref = ifelse(length(args) >= 1, args[1], "data/kgn_EUR")
pref.stu = ifelse(length(args) >= 2, args[2], "data/ukb_oadpEURsmall")

# load ref samples
num.pcs = 4
pc.names = paste0("PC", 1:num.pcs)
center.names = paste0("C", 1:num.pcs)
x.colnames = c("fid", "iid", pc.names)
methods = c("sp", "ap", "oadp", "adp")
x.ref = read.table(paste0(pref.ref, ".pcs"), header=T)
colnames(x.ref) = x.colnames

# load ref singular values
s.ref = scan(paste0(pref.ref, "_s.dat"))

# get population centers
c.ref = aggregate(x.ref[,pc.names], by=list(x.ref$fid), FUN=mean)
colnames(c.ref) = c("fid", center.names)
x.ref = merge(x.ref, c.ref)

# plotting marker settings
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
        x.stu[[method]] = merge(x.stu[[method]], c.ref)
        x.stu[[method]]$col = as.integer(x.stu[[method]]$fid) + 1
        x.stu[[method]]$pch = as.integer(x.stu[[method]]$fid) + 1
    }
}
methods = names(x.stu)

PC1.lim = quantile(c(sapply(methods, function(method) x.stu[[method]]$PC1), x.ref$PC1), c(0,1))
PC2.lim = quantile(c(sapply(methods, function(method) x.stu[[method]]$PC2), x.ref$PC2), c(0,1))
PC3.lim = quantile(c(sapply(methods, function(method) x.stu[[method]]$PC3), x.ref$PC3), c(0,1))
PC4.lim = quantile(c(sapply(methods, function(method) x.stu[[method]]$PC4), x.ref$PC4), c(0,1))

# plot ref pcs
out.filename = paste0(pref.ref, ".png")
print(out.filename)
png(out.filename, 2000, 1000)
par(mfrow=c(1,2), cex=2)
pc.contrib = round(s.ref[1:4]^2 / sum(s.ref^2), 3)
main = "Reference samples"
xlab = paste0("PC1 (contribution=", pc.contrib[1], ")")
ylab = paste0("PC2 (contribution=", pc.contrib[2], ")")
plot(x.ref$PC1, x.ref$PC2, xlab=xlab, ylab=ylab, col=x.ref$col, pch=x.ref$pch, main=main, xlim=PC1.lim, ylim=PC2.lim)
main = paste0("(variation contributed from PC1-4: ", sum(pc.contrib), ")")
xlab = paste0("PC3 (contribution=", pc.contrib[3], ")")
ylab = paste0("PC4 (contribution=", pc.contrib[4], ")")
plot(x.ref$PC3, x.ref$PC4, xlab=xlab, ylab=ylab, col=x.ref$col, pch=x.ref$pch, main=main, xlim=PC3.lim, ylim=PC4.lim)
legend("topright", legend=paste("Ref.", unique(x.ref$fid)), col=unique(x.ref$col), pch=unique(x.ref$pch))
dev.off()

c.ref.scale = rowSums(as.matrix(c.ref[,c(center.names)])^2)
msd.all = list()
msd.nulldist.all = list()
for(method in methods){
    print(method)

    fun = function(fid){
        y = x.ref[x.ref$fid == fid,]
        nstu = sum(x.stu[[method]]$fid == fid)
        y = y[sample(nrow(y), nstu, replace=T),]
        center = c.ref[c.ref$fid == fid, center.names]
        center.hat = colMeans(y[,pc.names])
        sum((center.hat - center)^2)
    }

    nrep = 100
    msd.nulldist = sqrt(sapply(1:nrep, function(x) mean(sapply(c.ref$fid, fun) / c.ref.scale, na.rm=T)))
    msd.nulldist.all[[method]] = msd.nulldist
    print(paste("MSD null dist:", mean(msd.nulldist), sd(msd.nulldist)))

    c.stu = aggregate(x.stu[[method]][,pc.names], by = list(x.stu[[method]]$fid), FUN = mean)
    colnames(c.stu) = c("fid", center.names)
    c.refstu = merge(c.ref, c.stu, by="fid")
    msd = sqrt(mean(rowSums((c.refstu[,paste0(center.names, ".x")] - c.refstu[,paste0(center.names, ".y")])^2) / c.ref.scale))
    msd = round(msd, 3)
    print(paste("MSD:", msd))
    msd.all[[method]] = msd
}

# plot study pcs
for(method in methods){
    out.filename = paste0(pref.stu, "_", method, ".png")
    print(out.filename)
    png(out.filename, 2000, 1000)
    par(mfrow=c(1,2), cex=2)
    main = paste0("Study samples (method: ", method, ")")
    plot(x.ref$PC1, x.ref$PC2, xlab="PC1", ylab="PC2", col='grey', pch=x.ref$pch, main=main, xlim=PC1.lim, ylim=PC2.lim)
    points(x.stu[[method]]$PC1, x.stu[[method]]$PC2, col=x.stu[[method]]$col, pch=x.stu[[method]]$pch) 
    plot(x.ref$PC3, x.ref$PC4, xlab="PC3", ylab="PC4", col='grey', pch=x.ref$pch, main=main, xlim=PC3.lim, ylim=PC4.lim)
    points(x.stu[[method]]$PC3, x.stu[[method]]$PC4, col=x.stu[[method]]$col, pch=x.stu[[method]]$pch) 
    legend("topright", legend=paste("Ref.", unique(x.ref$fid)), col='grey', pch=unique(x.ref$pch))
    legend("bottomright", legend=paste("Stu.", unique(x.ref$fid)), col=unique(x.ref$col), pch=unique(x.ref$pch))
    legend("bottomleft", legend=paste("MSD:", msd.all[[method]]))
    legend("bottom", legend=paste("null MSD", c("mean:", "sd:"), round(c(mean(msd.nulldist.all[[method]]), sd(msd.nulldist.all[[method]])), 3)))

    dev.off()
}

out.filename = paste0(pref.stu, "_scatter.png")
print(out.filename)
png(out.filename, 2000, 3000)
pairs = cbind(c(4,4,4,3,3,2), c(3,2,1,2,1,1))
par(mfrow=c(nrow(pairs), num.pcs), cex=2)
for(i in 1:nrow(pairs)){
    pair = pairs[i,]
    method = c(methods[pair[1]], methods[pair[2]])
    msd = mean(as.matrix(x.stu[[method[1]]][, pc.names] - x.stu[[method[2]]][, pc.names])^2)
    msd = round(msd, 3)
    print(paste(method[1], method[2], msd))
    for(pc.name in pc.names){
        a = x.stu[[method[1]]][[pc.name]]
        b = x.stu[[method[2]]][[pc.name]]
        xlab = paste(method[1], pc.name)
        ylab = paste(method[2], pc.name)
        main = paste("MSD:", msd)
        plot(a, b, xlab=xlab, ylab=ylab, main=main)
        abline(0,1)
        abline(v=0)
        abline(h=0)
    }
}
dev.off()
