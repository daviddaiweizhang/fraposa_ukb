#!/bin/bash
set -e

root=data
home=`pwd`
mkdir -p $root

bash intersect.sh $root
bash pca_global_global_pre.sh $root
bash pca_EUR_oadpEUR_pre.sh $root
bash pca_globalnEUR_globalsmall.sh $root $home
bash pca_EUR_oadpEURsmall.sh $root $home
