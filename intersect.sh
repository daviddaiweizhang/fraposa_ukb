#!/bin/bash
set -e

root=$1
ukb=~/data/ukb/ukb
kgn=~/data/kgn/kgn_bial_childless
panel_url=ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/integrated_call_samples_v3.20130502.ALL.panel
thindivcount=20000
numpcs=4
seed=123
mkdir -p $root
cd $root

echo 'produce popu file'
wget --quiet -O ${kgn}_tmp $panel_url 
join -1 2 -2 1 -o 2.1,2.2,2.3 <( sed 's/ /\t/g' $kgn.fam ) <( tail -n+2 ${kgn}_tmp ) > $kgn.panel
cmp <( cut -d' ' -f2 $kgn.fam ) <( cut -d' ' -f1 $kgn.panel )
rm ${kgn}_tmp

# TODO: process kgn from original files
echo 'get common marker rsids'
comm -12 <( cat $kgn.bim | cut -f2 | sort ) <( cat $ukb.bim | cut -f2 | sort ) > comm_rs

# extract commons variants from kgn
plink --bfile $kgn --extract comm_rs --make-bed --out kgn
# replace fid with population
paste -d' ' <( cut -d' ' -f3 $kgn.panel ) <( cut -d' ' -f2- kgn.fam ) > tmp
mv tmp kgn.fam

# extract commons variants from ukb
plink --bfile $ukb --extract comm_rs --a1-allele kgn.bim 5 2 --make-bed --out ukb

# merge ref and stu samples and do pca
plink --keep-allele-order --bfile ukb --thin-indiv-count $thindivcount --make-bed --out ukb_thindiv
plink --keep-allele-order --bfile kgn --bmerge ukb_thindiv --make-bed --out kgn_ukb_thindiv
plink --bfile kgn_ukb_thindiv --pca $numpcs --seed $seed --out kgn_ukb_thindiv
