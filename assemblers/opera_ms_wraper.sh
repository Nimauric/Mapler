#!/bin/sh

short1="$1"
short2="$2"
long="$3"
output_directory="$4"
Ncpu=$(nproc)

echo ======================================

mkdir -p "$output_directory"


perl dependencies/OPERA-MS/OPERA-MS.pl \
    --no-ref-clustering \
    --num-processors "$Ncpu" \
    --short-read1 "$short1" \
    --short-read2 "$short2" \
    --long-read "$long" \
    --out-dir "$output_directory"/tmp


cp "$output_directory"/tmp/contigs.polished.fasta  "$output_directory"/assembly.fasta

