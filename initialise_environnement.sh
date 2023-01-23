#!/bin/sh
# This script sets up the environement, should only be run once per download

echo "creating folders..."
mkdir data
mkdir data/raw_reads # raw fastq
mkdir data/reads_QC # quality check
mkdir data/reference_genomes
mkdir data/assemblies_QC

echo "creating the conda environnement..."
. /local/env/envconda.sh
conda create -p ~/my_env flye canu xmlstarlet snakemake pandas

echo "Your environnement is ready,"
echo ""
echo "You can now place your raw reads in data/raw_reads/"
echo "If your reads are on the SRA database, you can edit the SraAccList.txt file with the runs accession numbers"
echo "You can then run sra_reads_downloader.sh"
echo ""
echo "You can now place your reference genomes in data/reference_genomes/"
echo "Hard coded for my specific dataset : I may use reference_genome_renamer.sh if the genomes are in different folders"
