#!/bin/bash
set -e

root=$1
refpref=kgn
inpref=ukb
scriptargs="pca.slurm $root $refpref $inpref $n"
n=100
jobname=global_all_parts${n}

bash submitjobs.sh $scriptargs $jobname $n
