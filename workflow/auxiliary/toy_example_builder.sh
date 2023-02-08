#!/bin/sh
# This script builds a toy example : from a run of reads, select those that align to some reference genomes, 
# then subsample them to reach a desired coverage
run_name="SRR8073713"
path_to_mapping="../data/tmp/mapping_SRR8073713.bam"
path_to_filtered_mapping="../data/tmp/toy_mapping_SRR8073713.bam"
path_to_output="../data/input_reads/toy_SRR8073713.fastq"
path_to_reference_genomes="../data/merged_reference_genome/merged_reference.fasta"
path_to_output_tsv="../data/merged_reference_genome/toy_SRR13.tsv"
combined_genome_size=7832317
#0 : Align reads to the reference genomes
scripts/coverage_calculator.sh SRR8073713 ../data/input_reads/SRR8073713.fastq.gz ../data/merged_reference_genome/merged_reference.fasta ../data/tmp/ ../data/merged_reference_genome/coverage_information_SRR8073713.tsv

#1 : Sort and filter reads to get those that map to Halomonassp_3 or MurspES050
#1.1 Index mapping
echo "indexing mapping..."
samtools index $path_to_mapping
#1.2 : Filter mapping
echo "Filtering mapping..."
samtools view $path_to_mapping Halomonassp_3 MurspES050 --output $path_to_filtered_mapping
#1.3 : Convert mapping to fastq
echo "Convertirg mapping to fastq..."
samtools fastq $path_to_filtered_mapping > "$path_to_output"

#2 : Subsample those reads to reach the desired coverage
echo "Subsampling reads..."
scripts/subsampler.sh $path_to_output 10x $combined_genome_size "$path_to_output".gz

#3 : Test if everything worked
echo "Testing if everything worked..."
scripts/coverage_calculator.sh $run_name "$path_to_output".gz $path_to_reference_genomes ../data/tmp/ $path_to_output_tsv

