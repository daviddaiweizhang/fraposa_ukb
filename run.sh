#!/bin/bash
set -e

ukb=~/data/ukb/ukb
kgn=~/data/kgn/kgn_bial_childless
small_n=500
seed=123
mkdir -p data
cd data

# TODO: process kgn from original files

comm -12 <( cat $kgn.bim | cut -f2 | sort ) <( cat $ukb.bim | cut -f2 | sort ) > comm_rs
plink --bfile $kgn --extract comm_rs --make-bed --out kgn
plink --bfile $ukb --extract comm_rs --a1-allele kgn.bim 5 2 --make-bed --out ukb
plink --bfile ukb --keep-allele-order --thin-indiv-count $small_n --seed $seed --make-bed --out ukb_small
paste -d' ' <( cut -d' ' -f3 $kgn.popu ) <( cut -d' ' -f2- kgn.fam ) > tmp
mv tmp kgn.fam
n_EUR=`cat kgn.fam | cut -d' ' -f1 | sort | uniq -c | grep EUR | awk '{ print $1 }'`
plink --bfile kgn --keep-allele-order --thin-indiv-count $n_EUR --seed $seed --make-bed --out kgn_nEUR
