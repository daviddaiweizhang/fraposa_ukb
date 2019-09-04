#!/bin/bash
set -e

root=$1
ukb=~/data/ukb/ukb
kgn=~/data/kgn/kgn_bial_childless
mkdir -p $root
cd $root

# TODO: process kgn from original files
# get common marker rsids
comm -12 <( cat $kgn.bim | cut -f2 | sort ) <( cat $ukb.bim | cut -f2 | sort ) > comm_rs

# extract commons variants from kgn
plink --bfile $kgn --extract comm_rs --make-bed --out kgn
# replace fid with population
paste -d' ' <( cut -d' ' -f3 $kgn.popu ) <( cut -d' ' -f2- kgn.fam ) > tmp
mv tmp kgn.fam

# extract commons variants from ukb
plink --bfile $ukb --extract comm_rs --a1-allele kgn.bim 5 2 --make-bed --out ukb
