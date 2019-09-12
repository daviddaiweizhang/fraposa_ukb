#!/bin/bash
set -e

date

echo $SLURM_ARRAY_JOB_ID
echo $SLURM_ARRAY_TASK_ID

root=$1
refpref=$2
inpref=$3
method=$4
n=$5
i=$SLURM_ARRAY_TASK_ID
if [ -z "$i" ]; then
    i=$6
fi

fraposa="python $HOME/fraposa/fraposa_runner.py"
splitindiv="bash $HOME/fraposa/splitindiv.sh"
dim_ref=4
dim_spikes=$dim_ref

cd $root
stupref=${inpref}_parts$n/`printf "%04d\n" ${i}`
mkdir -p `dirname $stupref`
$splitindiv ${inpref} $n $i $stupref
$fraposa --method $method --dim_ref $dim_ref --dim_spikes $dim_spikes --out ${stupref}_$method $refpref $stupref

date
