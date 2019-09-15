#!/bin/bash
set -e

root=$1
refpref=kgn
inpref=ukb
n=100
methods="ap sp oadp"

for method in methods; do
    scriptargs="pca.slurm $root $refpref $inpref $method $n"
    jobname=global_global_parts${n}_${method}
    bash submitjobs.sh "$scriptargs" $jobname $n
done
