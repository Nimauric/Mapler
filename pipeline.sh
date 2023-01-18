#!/bin/sh
#SBATCH --mem=10G

activate_environnement.sh
snakemake --cores all all
