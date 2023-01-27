#!/bin/sh
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
conda create -p ~/my_env flye canu xmlstarlet snakemake pandas quast samtools=1.15 minimap2 miniasm fastqc sra-tools

echo "Done !"
