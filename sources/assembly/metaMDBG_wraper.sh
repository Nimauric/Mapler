#!/bin/sh
# This script assemble a set of reads into a metagenome, using MetaMDBG
sample="$1"
tmp_directory="$2"
output="$3"
Ncpu=$(nproc)


mkdir -p "$tmp_directory"
metaMDBG asm "$tmp_directory" "$sample" -t $Ncpu

gzip -d "$tmp_directory"/tmp/contigs_polished.fasta.gz
mv "$tmp_directory"/tmp/contigs_polished.fasta "$output"
rm -rf "$tmp_directory"
