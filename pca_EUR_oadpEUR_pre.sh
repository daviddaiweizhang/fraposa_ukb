#!/bin/bash
set -e

root=$1
refpref=kgn
stupref=ukb
panel=~/data/kgn/kgn_bial_childless.panel
n=100
predict=oadp
popu=EUR
methods="ap sp oadp"
home=`pwd`

cd $root

# get EUR kgn samples
plink --bfile $refpref --keep-allele-order --keep-fam <( echo $popu ) --make-bed --out ${refpref}_$popu
# replace popu with subpopu
join -o 2.2,2.1,1.2,1.3,1.4,1.5 <( cut -d' ' -f2- ${refpref}_$popu.fam ) <( cut -d' ' -f1,2 $panel) > $refpref.tmp
cmp <( cut -d' ' -f2 ${refpref}_$popu.fam ) <( cut -d' ' -f2 $refpref.tmp )
mv $refpref.tmp ${refpref}_$popu.fam

# get the ukb samples predicted to be EUR
cat ${stupref}_$predict.pcs | cut -f1 | paste - ${stupref}.fam | awk -v popu=$popu '$1 == popu {print $2 " " $3}' > ${stupref}_$predict$popu.fiid
plink --bfile ${stupref} --keep-allele-order --keep ${stupref}_$predict$popu.fiid --make-bed --out ${stupref}_$predict$popu

cd $home
bash submitjobs.sh "$scriptargs" $jobname $n

for method in methods; do
    scriptargs="pca.slurm $root ${refpref}_$popu ${stupref}_$predict$popu $method $n"
    jobname=${popu}_${predict}${popu}_parts${n}_${method}
    bash submitjobs.sh "$scriptargs" $jobname $n
done
