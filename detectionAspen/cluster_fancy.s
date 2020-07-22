#!/bin/bash
#
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --time=12:00:00
#SBATCH --mem=7GB
#SBATCH --job-name=clusterfancy
#SBATCH --mail-type=END
#SBATCH --mail-user=aspen.yoo@nyu.edu
#SBATCH --output=o_%a.out

module purge
module load matlab/2016b

cat<<EOF | matlab -nodisplay
addpath(genpath('/home/ay963/matlab-scripts'))
addpath(genpath('/home/ay963/bigAISP/detectionAspen'))

idx = $SLURM_ARRAY_TASK_ID;
cluster_fcn_fancy(idx)

fprintf('job complete!')

EOF
