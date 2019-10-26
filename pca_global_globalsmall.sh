#!/bin/bash
set -e

root=$1
refpref=kgn
stupref=ukb_small

# run pca
bash pca.sh $root $refpref $stupref
