#!/bin/sh
#SBATCH --mem=30G
flye --meta --out-dir assembly --pacbio-raw ./fastq/SRR8073714.fastq.gz 
