#!/bin/bash
set -e

root=$1
home=`pwd`
seed=123
small_n=500
fraposa="python $HOME/fraposa/fraposa_runner.py"
predpopu="python $HOME/fraposa/predstupopu.py"
trace="bash $HOME/fraposa_simulation/trace.sh"
dim_ref=4
let "dim_stu = 2 * $dim_ref"
dim_spikes=$dim_ref
refpref=kgn_nEUR
stupref=ukb_small
cd $root

# get a global subset of kgn with the same number as EUR
n_EUR=`cat kgn.fam | cut -d' ' -f1 | sort | uniq -c | grep EUR | awk '{ print $1 }'`
plink --bfile kgn --keep-allele-order --thin-indiv-count $n_EUR --seed $seed --make-bed --out $refpref
# get a small subset of ukb samples
plink --bfile ukb --keep-allele-order --thin-indiv-count $small_n --seed $seed --make-bed --out $stupref

# pca on global (small) samples
for method in sp ap oadp; do
    $fraposa --method $method --dim_ref $dim_ref --dim_spikes $dim_spikes --out ${stupref}_$method $refpref $stupref
done
$trace $refpref $stupref $dim_stu $dim_ref ${stupref}_adp $refpref

for method in sp ap oadp adp; do
    $predpopu $refpref ${stupref}_$method
    paste <( cut -f1 ${stupref}_$method.popu ) <( cut -f2- ${stupref}_$method.pcs ) > tmp
    mv tmp ${stupref}_$method.pcs
done

cd $home
for method in sp ap oadp adp; do
    Rscript plot.R $root/$refpref $root/${stupref}_$method
done
