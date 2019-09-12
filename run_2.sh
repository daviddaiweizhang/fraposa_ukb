#!/bin/bash
set -e

root=data
home=`pwd`
mkdir -p $root

bash pca_post.sh $root kgn_EUR ukb_oadpEUR
bash pca_EUR_oadpEURsmall.sh $root $home
