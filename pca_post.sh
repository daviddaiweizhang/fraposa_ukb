#!/bin/bash
set -e

root=$1
refpref=$2
stupref=$3
studir=$4
methods='sp ap oadp adp'
predpopu="python $HOME/fraposa/predstupopu.py"
home=`pwd`

cd $root

if [ ! -z "$studir" ]; then
    echo 'merging parts...'
    for method in $methods; do
        cat $studir/*_$method.pcs > ${stupref}_$method.pcs
    done
fi

for method in $methods; do
    if [ -f ${stupref}_$method.pcs ]; then
        $predpopu $refpref ${stupref}_$method
        if [[ "$stupref" =~ ^(ukb|ukb_small)$ ]]; then
            awk '{ if ( $2 > 0.875 ) {print $1} else {print "mix"} }' ${stupref}_$method.popu > tmp_popu_$method
        else
            cut -f1 ${stupref}_$method.popu > tmp_popu_$method 
        fi
        paste <( cat tmp_popu_$method ) <( cut -f2- ${stupref}_$method.pcs ) > tmp
        mv tmp ${stupref}_$method.pcs
        cat tmp_popu_$method | sort | uniq -c
    fi
done

cd $home
Rscript plot.R $root/$refpref $root/$stupref
