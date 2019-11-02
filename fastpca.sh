#!/bin/bash
set -e

cd data
tail -n+2 kgnukb.evec | tr -s " " | sed 's/^ *//' | sed 's/ /\t/g' | sort -k1,1 > tmp
join -t $'\t' -a 2 -e "_UKB" <( sed 's/ /\t/g' kgn.panel | cut -f1,3 ) <( cut -f1-5 tmp ) -o 1.2,0,2.2,2.3,2.4,2.5 > kgnukb.pcs
