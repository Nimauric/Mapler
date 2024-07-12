#!/bin/sh
# This script assemble a set of reads into a metagenome, using Metaflye

# Get parameters
run="$1"
output_directory="$2"


mkdir -p "$output_directory"/tmp
flye --meta -t $(nproc) --out-dir "$output_directory"/tmp/ --pacbio-hifi "$run"

mv "$output_directory"/tmp/assembly.fasta "$output_directory"
rm -rf "$output_directory"/tmp/

