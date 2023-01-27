#!/bin/sh
#SBATCH --mem=30G
#SBATCH --cpus-per-task=4

# This script coordinates the other scripts

source ./activate_environnement.sh
snakemake -p --cores all all
