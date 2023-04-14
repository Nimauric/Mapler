#!/bin/sh
# This script assemble a set of reads into a metagenome, using hifiasm_meta
# "$1" : path/to/the/run.fastq
# "$2" : path/to/the/output/folder
# "$3" : prefix for the assembly files

mkdir "$2"

# Assembly
Ncpu=$(nproc)
hifiasm_meta -o "$2" -t" $Ncpu" "$1"

# "$2" and "$3" in the awk command have nothing to do with the parameters, they're special characters for awk
awk '/^S/{print ">"$2"\n"$3}' "$2""$3".p_utg.gfa > "$2"assembly.fasta
