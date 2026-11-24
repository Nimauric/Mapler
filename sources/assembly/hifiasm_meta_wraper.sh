#!/usr/bin/env bash
set -euo pipefail

# This script assemble a set of reads into a metagenome, using Hifiasm_meta
# "$1" : path/to/the/run.fastq
# "$2" : path/to/the/output/folder

run="$1"
output_directory="$2"
output="$3"
cleanup="${4:-yes}"


mkdir -p "$output_directory"
hifiasm_meta -o "$output_directory"/tmp -t $(nproc) "$run"

# "$2" and "$3" in the awk command have nothing to do with the parameters, they're special characters for awk
internal_final_assembly="$output_directory"/tmp.p_ctg.fasta
echo awk '/^S/{print ">"$2"\n"$3}' "$output_directory"/tmp.p_ctg.gfa > "$internal_final_assembly"
awk '/^S/{print ">"$2"\n"$3}' "$output_directory"/tmp.p_ctg.gfa > "$internal_final_assembly"
./sources/assembly/finalize_assembly_output.sh "$internal_final_assembly" "$output"

if [ "$cleanup" != "no" ] && [ -s "$output" ]; then
    rm -rf "$output_directory"/tmp*
fi
