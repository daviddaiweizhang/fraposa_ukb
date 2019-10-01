#!/bin/bash
set -e

root=data
home=`pwd`
mkdir -p $root

# bash pca_post.sh $root kgn_EUR ukb_oadpEUR
# bash pca_EUR_oadpEURsmall.sh $root $home

bash pca_post.sh $root kgn_AFR ukb_oadpAFR
bash pca_post.sh $root kgn_SAS ukb_oadpSAS
