#!/bin/bash
set -e

root=data
home=`pwd`
mkdir -p $root

bash intersect.sh $root
bash pca_global_global_pre.sh $root
