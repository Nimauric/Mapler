#!/bin/sh
# This script assemble a set of reads into a metagenome, using Hifiasm_meta
# "$1" : path/to/the/run.fastq
# "$2" : path/to/the/output/folder


run="$1"
output_directory="$2"
Ncpu=


mkdir -p "$output_directory"
hifiasm_meta -o "$output_directory"/tmp -t $(nproc) "$run"

# "$2" and "$3" in the awk command have nothing to do with the parameters, they're special characters for awk
echo awk '/^S/{print ">"$2"\n"$3}' "$output_directory"/tmp.p_ctg.gfa > "$output_directory"/assembly.fasta
awk '/^S/{print ">"$2"\n"$3}' "$output_directory"/tmp.p_ctg.gfa > "$output_directory"/assembly.fasta
rm -rf "$output_directory"/tmp*
