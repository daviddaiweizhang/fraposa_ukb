#!/bin/bash
set -e

root=$1
refpref=kgn
inpref=ukb
n=100
methods="ap sp oadp"

fraposa="python $HOME/fraposa/fraposa_runner.py"
dim_ref=4
dim_spikes=$dim_ref
methods='sp ap oadp'

# reference pca
for method in $methods; do
    base=${refpref}_$method
    mkdir -p $root/$base
    rm -f $root/$base/*.dat
    cp $root/$refpref.{bed,bim,fam} $root/$base
    $fraposa --method $method --dim_ref $dim_ref --dim_spikes $dim_spikes $root/$base/$refpref
    scriptargs="pca.slurm $root $base/$refpref $inpref $method $n"
    jobname=global_global_${method}_parts${n}
    bash submitjobs.sh "$scriptargs" $jobname $n
done
