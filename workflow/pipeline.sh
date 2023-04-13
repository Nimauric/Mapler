#!/bin/sh
#SBATCH --ntasks=20
#SBATCH --mem-per-cpu=100000

# This script lanches the Snakefile with its correct arguments
snakemake -pk --jobs 10 --cores all all --use-conda --default-resources mem_mb=5000 mem_mb_per_cpu=None
