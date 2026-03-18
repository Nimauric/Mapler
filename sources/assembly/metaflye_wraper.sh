#!/bin/sh
# This script assemble a set of reads into a metagenome, using Metaflye

# Get parameters
run="$1"
output_directory="$2"
technology="$3"

mkdir -p "$output_directory"/tmp

# Select read type depending on sequencing technology
if [ "$technology" = "ont" ]; then
    READ_TYPE="--nano-hq"
else
    READ_TYPE="--pacbio-hifi"
fi

flye --meta -t $(nproc) --out-dir "$output_directory"/tmp/ $READ_TYPE "$run"

mv "$output_directory"/tmp/assembly.fasta "$output_directory"
if [ -f "$output_directory/assembly.fasta" ]; then
    rm -rf "$output_directory"/tmp/
fi

