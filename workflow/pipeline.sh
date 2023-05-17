#!/bin/sh
#SBATCH --time=3-00:00:00
#SBATCH --mem=500M

# This script lanches the Snakefile with its correct arguments
snakemake -pk --slurm --jobs 10 --cores all all --use-conda --default-resources mem_mb=5000 mem_mb_per_cpu=None runtime=2*60
