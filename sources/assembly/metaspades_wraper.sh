#!/usr/bin/env bash
set -euo pipefail

# This script assembles a metagenomic short-read dataset using metaSPAdes
# Optional long reads can be provided as supplementary data

# Get parameters
reads_1="$1"
reads_2="$2"
output_directory="$3"
output="$4"
long_reads="$5"
long_read_technology="$6"
cleanup="${7:-yes}"
threads="${8:-16}"
memory_mb="${9:-250000}"

# Convert memory from MB to GB for SPAdes -m
memory_gb=$((memory_mb / 1000))

mkdir -p "$output_directory"/tmp

# Select optional long-read parameter
LONG_READ_ARG=""
if [ -n "$long_reads" ] && [ "$long_reads" != "none" ]; then
    if [ "$long_read_technology" = "ont" ]; then
        LONG_READ_ARG="--nanopore $long_reads"
    elif [ "$long_read_technology" = "pacbio" ]; then
        LONG_READ_ARG="--pacbio $long_reads"
    fi
fi

spades.py \
    --meta \
    -1 "$reads_1" \
    -2 "$reads_2" \
    -t "$threads" \
    -m "$memory_gb" \
    -o "$output_directory"/tmp/ \
    $LONG_READ_ARG

./sources/assembly/finalize_assembly_output.sh "$output_directory"/tmp/contigs.fasta "$output"

if [ "$cleanup" != "no" ] && [ -s "$output" ]; then
    rm -rf "$output_directory"/tmp/
fi
