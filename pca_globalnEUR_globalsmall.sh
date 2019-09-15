#!/bin/bash
set -e

root=$1
home=`pwd`
refpref=kgn_nEUR
stupref=ukb_small
small_n=500
seed=123

cd $root

# get a global subset of kgn with the same number as EUR
n_EUR=`cat kgn.fam | cut -d' ' -f1 | sort | uniq -c | grep EUR | awk '{ print $1 }'`
plink --bfile kgn --keep-allele-order --thin-indiv-count $n_EUR --seed $seed --make-bed --out $refpref

# get a small subset of ukb samples
plink --bfile ukb --keep-allele-order --thin-indiv-count $small_n --seed $seed --make-bed --out $stupref

cd $home

# run pca
bash pca.sh $root $refpref $stupref
