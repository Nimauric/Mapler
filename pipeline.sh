#!/bin/sh
#SBATCH --mem=30G

source ./activate_environnement.sh
snakemake --cores all all
