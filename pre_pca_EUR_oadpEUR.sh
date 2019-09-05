#!/bin/bash
set -e

root=$1
refpref=kgn
stupref=ukb
n=100
method=oadp
popu=EUR
home=`pwd`

cd $root
cat ${stupref}_$method.pcs | cut -f1 | paste - ${stupref}.fam | awk -v popu=$popu '$1 == popu {print $2 " " $3}' > ${stupref}_$method$popu.fiid
plink --bfile ${stupref} --keep-allele-order --keep ${stupref}_$method$popu.fiid --make-bed --out ${stupref}_$method$popu

cd $home
jobname=EUR_oadpEUR_parts${n}
output_dir=logs/${jobname}
mkdir -p $output_dir
sbatch --job-name=$jobname --array=1-$n --time=0-02:00:00 --nodes=2 --mem=8000 --output=$output_dir/%A_%4a.log pca.slurm $root ${refpref}_$popu ${stupref}_$method$popu $n
