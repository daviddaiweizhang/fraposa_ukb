#!/bin/bash
set -e

root=$1
refpref=kgn
stupref=ukb
panel=~/data/kgn/kgn_bial_childless.panel
n=100
method=oadp
popu=EUR
home=`pwd`

cd $root

# get EUR kgn samples
plink --bfile $refpref --keep-allele-order --keep-fam <( echo $popu ) --make-bed --out ${refpref}_$popu
# replace popu with subpopu
join -o 2.2,2.1,1.2,1.3,1.4,1.5 <( cut -d' ' -f2- ${refpref}_$popu.fam ) <( cut -d' ' -f1,2 $panel) > $refpref.tmp
cmp <( cut -d' ' -f2 ${refpref}_$popu.fam ) <( cut -d' ' -f2 $refpref.tmp )
mv $refpref.tmp ${refpref}_$popu.fam

# get the ukb samples predicted to be EUR
cat ${stupref}_$method.pcs | cut -f1 | paste - ${stupref}.fam | awk -v popu=$popu '$1 == popu {print $2 " " $3}' > ${stupref}_$method$popu.fiid
plink --bfile ${stupref} --keep-allele-order --keep ${stupref}_$method$popu.fiid --make-bed --out ${stupref}_$method$popu

cd $home
jobname=EUR_oadpEUR_parts${n}
output_dir=logs/${jobname}
mkdir -p $output_dir
sbatch --job-name=$jobname --array=1-$n --time=0-02:00:00 --nodes=2 --mem=8000 --output=$output_dir/%A_%4a.log pca.slurm $root ${refpref}_$popu ${stupref}_$method$popu $n
