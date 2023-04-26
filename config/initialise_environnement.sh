#!/bin/sh
#SBATCH --mem=10G

# This script sets up the environement, should only be run once per download

echo "creating folders..."
mkdir ../data
mkdir ../data/input_reads
mkdir ../data/input_reference_genomes
mkdir ../data/merged_reference_genome
mkdir ../data/runs_metadata
mkdir ../data/tmp
mkdir ../data/bins
mkdir ../data/reads_quality_check
mkdir ../data/assemblies
mkdir ../data/assemblies_quality_check
mkdir ../data/stats_reports
mkdir ../data/alignements

echo "installing conda..."
#mamba create -y -p ~/snakemake_env -c bioconda -c conda-forge snakemake=7.20 mamba

echo "installing opera MS..."
../config/opera_ms_installer.sh 

echo "installing metaMDBG..."
#../config/meta_mdbg_installer.sh

echo "Done !"
