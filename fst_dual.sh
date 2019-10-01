#!/bin/bash
set -e

root=data
pref=kgn
popu_a=$1
popu_b=$2
subpref=${pref}_${popu_a}_${popu_b}

cd $root

cmp <( cut -d' ' -f2 $pref.fam ) <( cut -d' ' -f1 $pref.panel )
paste -d' ' <( cut -d' ' -f1-2 $pref.fam ) <( cut -d' ' -f2-3 $pref.panel ) > $pref.clst
plink --bfile $pref --within $pref.clst --fst --out ${pref}_global_subpopu

cmp <( cut -d' ' -f2 ${pref}_EUR.fam ) <( grep EUR $pref.panel | cut -d' ' -f1 | sort )
paste -d' ' <( cut -d' ' -f1 ${pref}_EUR.fam ) <( grep EUR $pref.panel | sort -k1 | cut -d' ' -f1-2 ) > ${pref}_EUR.clst
plink --bfile ${pref}_EUR --within ${pref}_EUR.clst --fst --out ${pref}_EUR_subpopu
 
grep $popu_a $pref.panel | cut -d' ' -f1 | grep -f - $pref.fam > tmp_a
grep $popu_b $pref.panel | cut -d' ' -f1 | grep -f - $pref.fam > tmp_b
cat tmp_a tmp_b > tmp_c
plink --bfile $pref --keep tmp_c --make-bed --out $subpref

cat <( grep $popu_a $pref.clst ) <( grep $popu_b $pref.clst ) | sort > $subpref.clst
cmp <( cut -d' ' -f2 $subpref.fam ) <( cut -d' ' -f2 $subpref.clst )
plink --bfile $subpref --within ${pref}_${popu_a}_${popu_b}.clst --fst --out $subpref

grep 'Weighted Fst' ${pref}_*_*.log
