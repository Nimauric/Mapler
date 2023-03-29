#!/bin/sh

#assembly="../../data/assemblies/metaflye_SRR8073714/assembly.fasta"
#reads="../../data/input_reads/SRR8073714.fastq"
#prefix="maxbin_out"

assembly="$1"
reads="$2"
outfolder="$3"
prefix="$4" #prefix of each file

mkdir "$outfolder"
run_MaxBin.pl -contig "$assembly" -reads "$reads" -out "$outfolder""$prefix"
