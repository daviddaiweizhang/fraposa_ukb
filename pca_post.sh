#!/bin/bash
set -e

root=$1
refpref=$2
stupref=$3
studir=${stupref}_parts100
methods='sp ap oadp'
predpopu="python $HOME/fraposa/predstupopu.py"
home=`pwd`

cd $root
for method in $methods; do
    cat $studir/*_$method.pcs > ${stupref}_$method.pcs
    $predpopu $refpref ${stupref}_$method
    paste <( cut -f1 ${stupref}_$method.popu ) <( cut -f2- ${stupref}_$method.pcs ) > tmp
    mv tmp ${stupref}_$method.pcs
done

cd $home
Rscript plot.R $root/$refpref $root/$stupref
