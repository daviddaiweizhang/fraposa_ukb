#!/bin/bash
set -e

echo "$*"
root=$1
refpref=$2
stupref=$3
home=`pwd`
seed=123
fraposa="python $HOME/fraposa/fraposa_runner.py"
predpopu="python $HOME/fraposa/predstupopu.py"
trace="bash $HOME/fraposa_simulation/trace.sh"
dim_ref=4
let "dim_stu = 2 * $dim_ref"
dim_spikes=$dim_ref
cd $root

# run pca
for method in sp ap oadp; do
    $fraposa --method $method --dim_ref $dim_ref --dim_spikes $dim_spikes --out ${stupref}_$method --stu_filepref $stupref $refpref 
done
$trace $refpref $stupref $dim_stu $dim_ref ${stupref}_adp $refpref

for method in sp ap oadp adp; do
    $predpopu $refpref ${stupref}_$method
    paste <( cut -f1 ${stupref}_$method.popu ) <( cut -f2- ${stupref}_$method.pcs ) > tmp
    mv tmp ${stupref}_$method.pcs
done

cd $home
bash fst.sh $root/$refpref
Rscript plot.R $root/$refpref $root/${stupref}
