#!/bin/sh
#SBATCH --mem=30G
#SBATCH --cpus-per-task=4

source ./activate_environnement.sh
snakemake --cores all all
