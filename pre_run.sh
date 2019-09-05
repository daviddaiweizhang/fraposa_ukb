#!/bin/bash
set -e

root=data
home=`pwd`
mkdir -p $root

# bash intersect.sh $root
bash pre_pca_global_all.sh $root
# bash pre_pca_EUR_oadpEUR.sh $root
# bash pca_nEUR_small.sh $root $home
