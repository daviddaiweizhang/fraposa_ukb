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
    if [[ "$stupref" == "ukb" ]]; then
        awk '{ if ( $2 > 0.875 ) {print $1} else {print "mix"} }' ${stupref}_$method.popu > tmp_popu_$method
    else
        cut -f1 ${stupref}_$method.popu > tmp_popu_$method 
    fi
    paste <( cat tmp_popu_$method ) <( cut -f2- ${stupref}_$method.pcs ) > tmp
    mv tmp ${stupref}_$method.pcs
done
cat tmp_popu_$method | sort | uniq -c


cd $home
Rscript plot.R $root/$refpref $root/$stupref
