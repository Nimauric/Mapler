#!/bin/sh
# This script assemble a set of reads into a metagenome, using Hifiasm_meta
# "$1" : path/to/the/run.fastq
# "$2" : path/to/the/output/folder
# "$3" : prefix for the assembly files


run="$1"
output_directory="$2"
Ncpu=$(nproc)


mkdir "$2"
hifiasm_meta -o "$output_directory"/tmp -t" $Ncpu" "$run"

# "$2" and "$3" in the awk command have nothing to do with the parameters, they're special characters for awk
awk '/^S/{print ">"$2"\n"$3}'"$output_directory"/tmp.p_utg.gfa > "$output_directory"/assembly.fasta
rm -rf "$output_directory"/tmp*