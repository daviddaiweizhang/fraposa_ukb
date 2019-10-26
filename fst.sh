#!/bin/bash
set -e

inpref=$1

plink --bfile ${inpref} --family --write-cluster --out ${inpref}
plink --bfile ${inpref} --within ${inpref}.clst --fst --out ${inpref}
