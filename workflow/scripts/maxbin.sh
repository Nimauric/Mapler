#!/bin/sh

#assembly="../../data/assemblies/metaflye_SRR8073714/assembly.fasta"
#reads="../../data/input_reads/SRR8073714.fastq"
#prefix="maxbin_out"

assembly="$1"
reads="$2"
prefix="$3" # Path to folder + prefix of each file

run_MaxBin.pl -contig "$assembly" -reads "$reads" -out "$prefix"
