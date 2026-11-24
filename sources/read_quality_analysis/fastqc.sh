#!/bin/bash
# This script analyses a run and generates a quality report
# It only works with PE Illumina avec R1 et R2. 


set -euo pipefail

export _JAVA_OPTIONS=-Xmx8g

R1=$1
R2=$2
output_directory=$3
R1_output=$4
R2_output=$5
threads=$6

mkdir -p "$output_directory"

fastqc \
    -t "$threads" \
    -o "$output_directory" \
    "$R1" "$R2"

R1_base=$(basename "$R1")
R2_base=$(basename "$R2")

R1_base=${R1_base%.gz}
R1_base=${R1_base%.fastq}
R1_base=${R1_base%.fq}

R2_base=${R2_base%.gz}
R2_base=${R2_base%.fastq}
R2_base=${R2_base%.fq}

R1_html="$output_directory/${R1_base}_fastqc.html"
R2_html="$output_directory/${R2_base}_fastqc.html"

if [ "$R1_html" != "$R1_output" ]; then
    mv "$R1_html" "$R1_output"
fi

if [ "$R2_html" != "$R2_output" ]; then
    mv "$R2_html" "$R2_output"
fi

