#!/usr/bin/env bash
set -euo pipefail

# This script assemble a set of reads into a metagenome, using MetaMDBG

sample="$1"
tmp_directory="$2"
output="$3"
technology="$4"
cleanup="${5:-yes}"

Ncpu=$(nproc)

mkdir -p "$tmp_directory"

# Select read type depending on sequencing technology
if [ "$technology" = "ont" ]; then
    READ_TYPE="--in-ont"
else
    READ_TYPE="--in-hifi"
fi

metaMDBG asm --out-dir "$tmp_directory" $READ_TYPE "$sample" --threads $Ncpu

./sources/assembly/finalize_assembly_output.sh "$tmp_directory"/contigs.fasta.gz "$output"

if [ "$cleanup" != "no" ] && [ -s "$output" ]; then
    rm -rf "$(dirname "$output")"/tmp/
fi
