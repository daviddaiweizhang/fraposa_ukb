#!/bin/bash
set -e

root=$1
refpref=kgn
inpref=ukb
n=100
scriptargs="pca.slurm $root $refpref $inpref $n"
jobname=global_all_parts${n}

bash submitjobs.sh "$scriptargs" $jobname $n
