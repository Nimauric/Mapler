#!/bin/sh
# This script assembles a metagenomic short-read dataset using metaSPAdes
# Optional long reads can be provided as supplementary data

# Get parameters
reads_1="$1"
reads_2="$2"
output_directory="$3"
long_reads="$4"
long_read_technology="$5"

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
    -t "$(nproc)" \
    -o "$output_directory"/tmp/ \
    $LONG_READ_ARG

mv "$output_directory"/tmp/contigs.fasta "$output_directory"/assembly.fasta
if [ -f "$output_directory/assembly.fasta" ]; then
    rm -rf "$output_directory"/tmp/
fi