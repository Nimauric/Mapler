#!/bin/sh
# This script builds a toy example : from a run of reads, select those that align to some reference genomes, 
# then subsample them to reach a desired coverage

# "$1" : name of the run (SRA accession number)
# "$2" : path/to/the/run/to/sumbsample/from.fastq.gz
# "$3" : desired coverage
# "$4" : path to the folder to store temporary files ("/" included)
# "${@:5}" : paths to reference genomes

path_to_references=( "../data/input_reference_genomes/Halomonassp_3.fasta" "../data/input_reference_genomes/MarspLV10R5108_2.fasta")
path_to_merged_reference=(../data/merged_reference_genome/toy_merge.fasta)

# Create merged reference
./scripts/references_merger.sh $path_to_merged_reference ${path_to_references}

# Fetch the sequencer used for this run

# Run minimap2

# Extract the mapped reads
#samtools view -b -F 4 file.bam > mapped.bam
#samtools view -F 4 file.bam > mapped.bam
