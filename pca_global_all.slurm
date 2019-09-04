#!/bin/bash
set -e

echo $SLURM_ARRAY_JOB_ID
echo $SLURM_ARRAY_TASK_ID

root=$1
refpref=$2
inpref=$3
n=$4
fraposa="python $HOME/fraposa/fraposa_runner.py"
splitindiv="bash $HOME/fraposa/splitindiv.sh"
dim_ref=4
cd $root

i=$SLURM_ARRAY_TASK_ID
stupref=${inpref}_parts$n/`printf "%04d\n" ${i}`
mkdir -p `dirname $stupref`
$splitindiv ${inpref} $n $i $stupref
for method in sp ap oadp; do
    $fraposa --method $method --dim_ref $dim_ref --out ${stupref}_$method $refpref $stupref
done
