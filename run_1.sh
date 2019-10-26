#!/bin/bash
set -e

root=data
home=`pwd`
mkdir -p $root

bash pca_post.sh $root kgn ukb
bash pca_POPU_oadpPOPU.sh $root EUR
bash pca_POPU_oadpPOPU.sh $root AFR
bash pca_POPU_oadpPOPU.sh $root SAS
bash pca_POPU_oadpPOPU.sh $root AMR
bash pca_POPU_oadpPOPU.sh $root EAS
bash pca_POPU_oadpPOPU.sh $root mix
