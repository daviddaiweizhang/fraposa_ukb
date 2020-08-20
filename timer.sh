#!/bin/bash
set -e

root=$1
refpref=$2
stupref=$3

fraposa="python $HOME/fraposa/fraposa_runner.py"
trace="bash $HOME/fraposa_simulation/trace.sh"
dim_ref=4
let "dim_stu = 2 * $dim_ref"
dim_spikes=$dim_ref
methods='sp ap oadp'

id=`date +%s.%N`
base=$root/runtimes/$id
mkdir -p $base
cp $root/$refpref.{bed,bim,fam} $base
cp $root/$stupref.{bed,bim,fam} $base

for method in $methods; do
    rm -f $base/*.dat
    $fraposa --method $method --dim_ref $dim_ref --dim_spikes $dim_spikes --out $base/${stupref}_$method --stu_filepref $base/$stupref $base/$refpref 
done
$trace $base/$refpref $base/$stupref $dim_stu $dim_ref $base/${stupref}_adp $base/$refpref
