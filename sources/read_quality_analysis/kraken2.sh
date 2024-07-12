#!/bin/sh

kraken2_directory=$1
database=$2
krona_directory=$3
queries=$4
output_directory=$5

echo "launching kraken"
"$kraken2_directory"kraken2 --db "$database" --threads $(nproc) \
    --confidence 0.01 \
    "$queries" --output "$output_directory"/kraken2.tsv

echo "launching Krona"
"$krona_directory"ktImportTaxonomy \
    -q 2 -t 3 -m 4 \
    -o "$output_directory"/krona.html \
    "$output_directory"/kraken2.tsv

echo "Done !"
