#!/bin/bash
set -e

root=$1
refpref=kgn
stupref=ukb_smaller

# run pca
bash pca.sh $root $refpref $stupref
