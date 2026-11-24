#!/bin/bash
# This script utilises nanoplot for a QC of long_reads either HIFI or ONT

set -euo pipefail

input_fastq=$1
output_directory=$2
threads=$3

mkdir -p "$output_directory"

NanoPlot \
    --fastq "$input_fastq" \
    --outdir "$output_directory" \
    --threads "$threads" \
    --N50 \
    --tsv_stats \
    --info_in_report \
    --format png pdf \
    --plots kde hex \
    --loglength