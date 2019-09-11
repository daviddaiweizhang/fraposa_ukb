#!/bin/bash
set -e

root=$1
home=`pwd`
refpref=kgn_EUR
stupref=ukb_oadpEURsmall

cd $root

# get a small subset of ukb samples
plink --bfile ukb_oadpEUR --keep-allele-order --thin-indiv-count $small_n --seed $seed --make-bed --out $stupref

cd $home

# run pca
bash pca_all.sh $root $refpref $stupref
