#!/bin/sh
#SBATCH --time=3-00:00:00

# This script lanches the Snakefile with its correct arguments
snakemake -pk --slurm --jobs 10 --cores all all --use-conda --default-resources mem_mb=5000 mem_mb_per_cpu=None
