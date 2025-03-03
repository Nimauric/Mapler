#!/bin/sh

database=$1 #/groups/genscale/nimauric/databases/standard_kraken_database/ #
queries=$2 #outputs/zymo/metaMDBG/unmapped_reads.fastq #
output_directory=$3 #test_kraken # 

echo "launching kraken"
kraken2 --db "$database" --threads $(nproc) \
    --confidence 0.01 \
    "$queries" --output "$output_directory"/kraken2.tsv

echo "launching Krona"

ktImportTaxonomy \
    -q 2 -t 3 -m 4 \
    -o "$output_directory"/krona.html \
    "$output_directory"/kraken2.tsv

echo "Done !"
