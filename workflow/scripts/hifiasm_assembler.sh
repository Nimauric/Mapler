#!/bin/sh
# This script assemble a set of reads into a metagenome, using hifiasm_meta
# "$1" : path/to/the/run.fastq
# "$2" : path/to/the/output/folder

mkdir "$2"

Ncpu=$(nproc)
echo hifiasm_meta -o "$2" -t"$Ncpu" "$1"
hifiasm_meta -o "$2" -t"$Ncpu" "$1"

