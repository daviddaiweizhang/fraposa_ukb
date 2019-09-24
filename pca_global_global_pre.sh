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
    $fraposa --method $method --dim_ref $dim_ref --dim_spikes $dim_spikes $refpref
done

for method in methods; do
    scriptargs="pca.slurm $root $refpref $inpref $method $n"
    jobname=global_global_parts${n}_${method}
    bash submitjobs.sh "$scriptargs" $jobname $n
done
