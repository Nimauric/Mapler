#!/bin/sh

# This script lanches the Snakefile with its correct arguments
snakemake -pk --slurm --jobs 10 --cores all all --default-resources mem_mb=None mem_mb_per_cpu=None
