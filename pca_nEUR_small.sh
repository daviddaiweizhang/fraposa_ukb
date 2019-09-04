#!/bin/bash
set -e

root=$1
home=$2
seed=123
small_n=500
fraposa="python $HOME/fraposa/fraposa_runner.py"
predpopu="python $HOME/fraposa/predstupopu.py"
cd $root

# get a global subset of kgn with the same number as EUR
n_EUR=`cat kgn.fam | cut -d' ' -f1 | sort | uniq -c | grep EUR | awk '{ print $1 }'`
plink --bfile kgn --keep-allele-order --thin-indiv-count $n_EUR --seed $seed --make-bed --out kgn_nEUR
# get a small subset of ukb samples
plink --bfile ukb --keep-allele-order --thin-indiv-count $small_n --seed $seed --make-bed --out ukb_small

# pca on global (small) samples
$fraposa --dim_ref 4 --method ap kgn_nEUR ukb_small
$predpopu kgn_nEUR ukb_small
paste <( cut -f1 ukb_small.popu ) <( cut -f2- ukb_small.pcs ) > tmp
mv tmp ukb_small.pcs
Rscript $home/pca_nEUR_small.R kgn_nEUR ukb_small
