#!/bin/sh
# This script assemble a set of reads into a metagenome, using meta_mdbg
# "$1" : path/to/the/run.fastq
# "$2" : path/to/the/output/folder

reads="$1"
output_folder="$2",
num_processor=$(nproc)

mkdir "$2"
./dependencies/metaMDBG/build/bin/metaMDBG asm $output_folder $reads -t $num_processor
