#!/bin/bash
set -e

root=data
home=`pwd`
mkdir -p $root

bash pca_post.sh $root kgn ukb
bash pca_EUR_oadpEUR_pre.sh $root
