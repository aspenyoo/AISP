#!/bin/bash
#
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --time=01:00:00
#SBATCH --mem=4GB
#SBATCH --job-name=fit_parameters
#SBATCH --mail-type=END
#SBATCH --mail-user=aspen.yoo@nyu.edu
#SBATCH --output=o_%a.out

module purge
module load matlab/2016b

cat<<EOF | matlab -nodisplay
addpath(genpath('/home/ay963/matlab-scripts'))
addpath(genpath('/home/ay963/bigAISP/detectionAspen'))

% fixed model fitting settings
nReps = 20;
idx = $SLURM_ARRAY_TASK_ID;
%load('idxstocomplete.mat')
%idx=idxlist(idxx);


fit_cluster_ibs(idx,nReps)

blah

EOF
