#!/bin/bash
set -e

scriptargs=$1
jobname=$2
n=$3

output_dir=logs/${jobname}
mkdir -p $output_dir
sbatch --job-name=$jobname --array=1-$n --time=0-02:00:00 --nodes=1 --mem=8000 --output=$output_dir/%A_%4a.log --account=leeshawn --partition=standard $scriptargs
