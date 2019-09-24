#!/bin/bash
set -e

root=$1
popu=$2
refpref=kgn
stupref=ukb
panel=~/data/kgn/kgn_bial_childless.panel
n=100
predict=oadp
home=`pwd`

fraposa="python $HOME/fraposa/fraposa_runner.py"
dim_ref=4
dim_spikes=$dim_ref
methods='sp ap oadp'

cd $root

# get POPU kgn samples
plink --bfile $refpref --keep-allele-order --keep-fam <( echo $popu ) --make-bed --out ${refpref}_$popu
# replace popu with subpopu
join -o 2.2,2.1,1.2,1.3,1.4,1.5 <( cut -d' ' -f2- ${refpref}_$popu.fam ) <( cut -d' ' -f1,2 $panel) > $refpref.tmp
cmp <( cut -d' ' -f2 ${refpref}_$popu.fam ) <( cut -d' ' -f2 $refpref.tmp )
mv $refpref.tmp ${refpref}_$popu.fam

# get the ukb samples predicted to be POPU
cat ${stupref}_$predict.pcs | cut -f1 | paste - ${stupref}.fam | awk -v popu=$popu '$1 == popu {print $2 " " $3}' > ${stupref}_$predict$popu.fiid
plink --bfile ${stupref} --keep-allele-order --keep ${stupref}_$predict$popu.fiid --make-bed --out ${stupref}_$predict$popu

if [[ "$popu" =~ ^(EUR|AFR|SAS)$ ]]; then
    # reference pca
    for method in $methods; do
        $fraposa --method $method --dim_ref $dim_ref --dim_spikes $dim_spikes ${refpref}_$popu
    done

    # study pca
    cd $home
    scriptargs="pca.slurm $root ${refpref}_$popu ${stupref}_$predict$popu $n"
    jobname=${popu}_${predict}${popu}_parts${n}
    bash submitjobs.sh "$scriptargs" $jobname $n
else
    cd $home
    bash pca.sh $root ${refpref}_$popu ${stupref}_$predict$popu
fi
