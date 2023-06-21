#!/bin/sh
# This script assemble a set of reads into a metagenome, using MetaMDBG
run="$1"
output_directory="$2"
Ncpu=$(nproc)


mkdir "$2"
echo ./dependencies/metaMDBG/build/bin/metaMDBG asm "$output_directory"/tmp/ $run -t $Ncpu
./dependencies/metaMDBG/build/bin/metaMDBG asm "$output_directory"/tmp/ $run -t $Ncpu


gzip -d "$output_folder"/tmp/contigs.fasta.gz
mv "$output_directory"/tmp/contigs.fasta "$output_directory"
#rm -rf "$output_directory"/tmp/



