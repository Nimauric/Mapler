#!/bin/sh

# This script lanches the Snakefile with its correct arguments

snakemake -p --slurm --jobs 10 --cores all all
