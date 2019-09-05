#!/bin/bash
set -e

root=data
home=`pwd`
mkdir -p $root

bash post_pca.sh $root kgn ukb
bash post_pca.sh $root kgn_EUR ukb_oadpEUR
