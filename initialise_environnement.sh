#!/bin/sh
#SBATCH --mem=10G

# This script sets up the environement, should only be run once per download

echo "creating folders..."
mkdir data
mkdir data/raw_reads # raw fastq
mkdir data/reads_QC # quality check
mkdir data/reference_genomes
mkdir data/assemblies_QC
mkdir data/stats_reports

echo "creating the conda environnement..."
. /local/env/envconda.sh
mamba create -p ~/my_env2 flye=2.9.1-b1780 canu=2.2 xmlstarlet=1.6.1 snakemake=7.20.0 pandas=1.5.3 quast=5.2.0 minimap2=2.24 miniasm=0.3_r179 fastqc=0.11.9 sra-tools=2.8.0 samtools=1.15 -y

echo "Done !"
