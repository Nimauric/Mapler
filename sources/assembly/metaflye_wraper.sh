#!/usr/bin/env bash
set -euo pipefail

# This script assemble a set of reads into a metagenome, using Metaflye

# Get parameters
run="$1"
output_directory="$2"
output="$3"
technology="$4"
cleanup="${5:-yes}"

mkdir -p "$output_directory"/tmp

# Select read type depending on sequencing technology
if [ "$technology" = "ont" ]; then
    READ_TYPE="--nano-hq"
else
    READ_TYPE="--pacbio-hifi"
fi

flye --meta -t $(nproc) --out-dir "$output_directory"/tmp/ $READ_TYPE "$run"

./sources/assembly/finalize_assembly_output.sh "$output_directory"/tmp/assembly.fasta "$output"
if [ "$cleanup" != "no" ] && [ -s "$output" ]; then
    rm -rf "$output_directory"/tmp/
fi
