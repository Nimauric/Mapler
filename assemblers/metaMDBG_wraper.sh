#!/bin/sh
# This script assemble a set of reads into a metagenome, using MetaMDBG
run="$1"
output_directory="$2"
Ncpu=$(nproc)


mkdir -p "$output_directory"
echo ./dependencies/metaMDBG/build/bin/metaMDBG asm "$output_directory" "$run" -t $Ncpu
./dependencies/metaMDBG/build/bin/metaMDBG asm "$output_directory" "$run" -t $Ncpu

gzip -d "$output_directory"/tmp/contigs_polished.fasta.gz
mv "$output_directory"/tmp/contigs_polished.fasta "$output_directory"/assembly.fasta
#rm -rf "$output_directory"/tmp



