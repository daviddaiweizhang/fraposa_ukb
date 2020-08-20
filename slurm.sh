#!/bin/bash

#SBATCH --job-name=kgn_small
#SBATCH --array=1-1
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=8g

#SBATCH --account=leeshawn
#### #SBATCH --account=jiankang
#SBATCH --output=logs/%x-%A-%4a.log
#SBAtCH --partition=standard
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#### #SBATCH --mail-user=daiweiz@umich.edu
#### #SBATCH --mail-type=BEGIN,END,FAIL

hostname
echo $SLURM_ARRAY_JOB_ID
echo $SLURM_ARRAY_TASK_ID
mkdir -p logs
module load python R matlab
source $HOME/env/bin/activate
date

root=data
home=`pwd`
# bash timer.sh data kgn ukb_smaller
# bash timer.sh data kgn_nEUR ukb_small
# bash timer.sh data kgn_EUR ukb_oadpEURsmall
# bash pca_globalnEUR_globalsmall.sh $root $home
# bash pca_EUR_oadpEURsmall.sh $root $home
bash pca_global_globalsmall.sh $root

date
