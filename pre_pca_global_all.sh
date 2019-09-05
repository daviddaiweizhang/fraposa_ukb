#!/bin/bash
set -e

root=$1
refpref=kgn
inpref=ukb
n=100

jobname=global_all_parts${n}
output_dir=logs/${jobname}
mkdir -p $output_dir
sbatch --job-name=$jobname --array=1-$n --time=0-01:00:00 --nodes=1 --mem=8000 --output=$output_dir/%A_%4a.log pca.slurm $root $refpref $inpref $n
