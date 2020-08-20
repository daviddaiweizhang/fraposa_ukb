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

# cd $root

# # get POPU kgn samples
# if [[ "$popu" != mix ]]; then
#     plink --bfile $refpref --keep-allele-order --keep-fam <( echo $popu ) --make-bed --out ${refpref}_$popu
# # replace popu with subpopu
#     join -o 2.2,2.1,1.2,1.3,1.4,1.5 <( cut -d' ' -f2- ${refpref}_$popu.fam ) <( cut -d' ' -f1,2 $panel) > $refpref.tmp
#     cmp <( cut -d' ' -f2 ${refpref}_$popu.fam ) <( cut -d' ' -f2 $refpref.tmp )
#     mv $refpref.tmp ${refpref}_$popu.fam
# fi
# 
# # get the ukb samples predicted to be POPU
# cat ${stupref}_$predict.pcs | cut -f1 | paste - ${stupref}.fam | awk -v popu=$popu '$1 == popu {print $2 " " $3}' > ${stupref}_$predict$popu.fiid
# plink --bfile ${stupref} --keep-allele-order --keep ${stupref}_$predict$popu.fiid --make-bed --out ${stupref}_$predict$popu

if [[ "$popu" =~ ^(EUR|AFR|SAS)$ ]]; then
    for method in $methods; do
        cd $root
        # reference pca
        base=${refpref}_${popu}_$method
        mkdir -p $base
        rm -f $base/*.dat
        cp ${refpref}_${popu}.{bed,bim,fam} $base
        $fraposa --method $method --dim_ref $dim_ref --dim_spikes $dim_spikes $base/${refpref}_$popu

        # study pca
        cd $home
        scriptargs="pca.slurm $root $base/${refpref}_$popu ${stupref}_$predict$popu $method $n"
        jobname=${popu}_${predict}${popu}_${method}_parts${n}
        bash submitjobs.sh "$scriptargs" $jobname $n
    done
else
    cd $home
    refpref_popu=${refpref}_$popu
    if [[ "$popu" == mix ]]; then
        refpref_popu=${refpref}
    fi
    bash pca.sh $root $refpref_popu ${stupref}_$predict$popu
fi
