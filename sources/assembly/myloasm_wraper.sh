#!/usr/bin/env bash
set -euo pipefail

# This script assembles a set of reads into a metagenome using Myloasm

sample="$1"
tmp_directory="$2"
output="$3"
technology="$4"
cleanup="${5:-yes}"
threads="$6"

mkdir -p "$tmp_directory"

MYLOASM_FLAGS=""

if [ "$technology" = "hifi" ]; then
    MYLOASM_FLAGS="--hifi"
fi

myloasm "$sample" -o "$tmp_directory" -t "$threads" $MYLOASM_FLAGS
./sources/assembly/finalize_assembly_output.sh "$tmp_directory/assembly_primary.fa" "$output"

if [ "$cleanup" != "no" ] && [ -s "$output" ]; then
    rm -rf "$tmp_directory"
fi
