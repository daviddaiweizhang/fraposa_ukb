#!/bin/bash
set -e

root=data
home=`pwd`
mkdir -p $root

bash pca_post.sh $root kgn_EUR ukb_oadpEUR ukb_oadpEUR_parts100
bash pca_post.sh $root kgn_AFR ukb_oadpAFR ukb_oadpAFR_parts100
bash pca_post.sh $root kgn_SAS ukb_oadpSAS ukb_oadpSAS_parts100

bash pca_globalnEUR_globalsmall.sh $root $home
bash pca_EUR_oadpEURsmall.sh $root $home
