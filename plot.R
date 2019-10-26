rm(list=ls())
set.seed(123)

args = commandArgs(trailingOnly=TRUE)
pref.ref = ifelse(length(args) >= 1, args[1], "data/kgn_nEUR")
pref.stu = ifelse(length(args) >= 2, args[2], "data/ukb_small")

# load ref samples
num.pcs = 4
pc.names = paste0("PC", 1:num.pcs)
center.names = paste0("C", 1:num.pcs)
x.colnames = c("fid", "iid", pc.names)
methods = c("sp", "ap", "oadp", "adp")
x.ref = read.table(paste0(pref.ref, ".pcs"), header=F)
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
        x.stu[[method]] = x.stu[[method]][order(x.stu[[method]]$iid),]
        x.stu[[method]]$fid = factor(x.stu[[method]]$fid, levels=levels(x.ref$fid))
        x.stu[[method]] = merge(x.stu[[method]], c.ref)
        x.stu[[method]] = x.stu[[method]][order(x.stu[[method]]$iid),]
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
png(out.filename, 1000, 2000)
par(mfrow=c(2,1), cex=2, oma=c(0, 0, 2, 0))
pc.contrib = round(s.ref[1:4]^2 / sum(s.ref^2), 3)
xlab = paste0("PC1 (contribution=", pc.contrib[1], ")")
ylab = paste0("PC2 (contribution=", pc.contrib[2], ")")
main = paste0("Reference PC Scores (", nrow(x.ref), " 1000 Genomes samples)")
plot(x.ref$PC1, x.ref$PC2, xlab=xlab, ylab=ylab, main=main, col=x.ref$col, pch=x.ref$pch, xlim=PC1.lim, ylim=PC2.lim)
xlab = paste0("PC3 (contribution=", pc.contrib[3], ")")
ylab = paste0("PC4 (contribution=", pc.contrib[4], ")")
plot(x.ref$PC3, x.ref$PC4, xlab=xlab, ylab=ylab, col=x.ref$col, pch=x.ref$pch, xlim=PC3.lim, ylim=PC4.lim)
legend("bottomright", legend=paste("Ref.", unique(x.ref$fid)), col=unique(x.ref$col), pch=unique(x.ref$pch))
# supertitle = paste0("Reference PC Scores (", nrow(x.ref), " 1000 Genomes samples)")
# mtext(supertitle, outer = TRUE, cex=3)
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
    print(paste("sqrtMSD null dist:", mean(msd.nulldist), sd(msd.nulldist)))

    c.stu = aggregate(x.stu[[method]][,pc.names], by = list(x.stu[[method]]$fid), FUN = mean)
    colnames(c.stu) = c("fid", center.names)
    c.refstu = merge(c.ref, c.stu, by="fid")
    msd = sqrt(mean(rowSums((c.refstu[,paste0(center.names, ".x")] - c.refstu[,paste0(center.names, ".y")])^2) / c.ref.scale))
    msd = round(msd, 3)
    print(paste("sqrtMSD:", msd))
    msd.all[[method]] = msd
}

# plot study pcs
for(method in methods){
    out.filename = paste0(pref.stu, "_", method, ".png")
    print(out.filename)
    png(out.filename, 1000, 2000)
    par(mfrow=c(2,1), cex=2, oma=c(0, 0, 2, 0))
    main = paste0(toupper(method), " Study PC Scores (", nrow(x.stu[[method]]), " UKBiobank samples)")
    plot(x.ref$PC1, x.ref$PC2, xlab="PC1", ylab="PC2", main=main, col='grey', pch=x.ref$pch, xlim=PC1.lim, ylim=PC2.lim)
    points(x.stu[[method]]$PC1, x.stu[[method]]$PC2, col=x.stu[[method]]$col, pch=x.stu[[method]]$pch) 
    legend("bottomright", legend=c(paste0("null sqrtMSD mean: ", round(mean(msd.nulldist.all[[method]]), 3)),
                                   paste0("null sqrtMSD sd: ", round(sd(msd.nulldist.all[[method]]), 3)),
                                   paste0("sqrtMSD: ", msd.all[[method]])
                                   ))
    plot(x.ref$PC3, x.ref$PC4, xlab="PC3", ylab="PC4", col='grey', pch=x.ref$pch, xlim=PC3.lim, ylim=PC4.lim)
    points(x.stu[[method]]$PC3, x.stu[[method]]$PC4, col=x.stu[[method]]$col, pch=x.stu[[method]]$pch) 
    legend("bottomright", legend=paste("Ref.", unique(x.ref$fid)), col='grey', pch=unique(x.ref$pch))
    legend("bottomleft", legend=paste("Stu.", unique(x.ref$fid)), col=unique(x.ref$col), pch=unique(x.ref$pch))
    # supertitle = paste0(toupper(method), " Study PC Scores (", nrow(x.stu[[method]]), " UKBiobank samples)")
    # mtext(supertitle, outer = TRUE, cex=3)
    dev.off()
}

# scatter plot study pcs
pairs_all = list()
pairs_all[[1]] = cbind(
    c(4,4,4),
    c(3,2,1))
pairs_all[[2]] = cbind(
    c(3,3,2),
    c(2,1,1))
for(l in 1:2){
    pairs = pairs_all[[l]]
    out.filename = paste0(pref.stu, "_scatter_", l, ".png")
    print(out.filename)
    png(out.filename, 3000, 4000)
    par(mfcol=c(num.pcs, nrow(pairs)), cex=3, oma=c(4,0,0,0))
    for(i in 1:nrow(pairs)){
        pair = pairs[i,]
        method = c(methods[pair[1]], methods[pair[2]])
        msd = sqrt(mean(as.matrix(x.stu[[method[1]]][, pc.names] - x.stu[[method[2]]][, pc.names])^2))
        msd = round(msd, 3)
        print(paste(method[1], method[2], msd))
        for(j in 1:num.pcs){
            pc.name = pc.names[j]
            a = x.stu[[method[1]]][[pc.name]]
            b = x.stu[[method[2]]][[pc.name]]
            ab = sapply(methods, function(m) x.stu[[m]][[pc.name]])
            lim = c(min(ab), max(ab))
            xlab = paste(toupper(method[1]), pc.name)
            ylab = paste(toupper(method[2]), pc.name)
            col = x.stu[[method[1]]]$col
            pch = x.stu[[method[1]]]$pch
            main = ""
            if(j == 1) main = paste(toupper(method[1]), " vs ", toupper(method[2]), " (sqrtMSD: ", msd, ")")
            plot(a, b, xlab=xlab, ylab=ylab, xlim=lim, ylim=lim, col=col, pch=pch, main=main)
            abline(0,1)
            abline(v=0)
            abline(h=0)
        }
    }
    legend.x = -240
    legend.y = -130
    legend(legend.x, legend.y, xpd="NA", legend=unique(x.ref$fid), col=unique(x.ref$col), pch=unique(x.ref$pch), ncol=length(unique(x.ref$fid)))
    dev.off()
}

