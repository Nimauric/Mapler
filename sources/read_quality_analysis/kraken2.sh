#!/usr/bin/env bash
set -euo pipefail

database=$1 #/groups/genscale/nimauric/databases/standard_kraken_database/ #
queries=$2 #outputs/zymo/metaMDBG/unmapped_reads.fastq.gz #
output_directory=$3 #test_kraken # 

mkdir -p "$output_directory"

gzip_option=""
if [[ "$queries" == *.gz ]]; then
    gzip_option="--gzip-compressed"
fi

echo "launching kraken"
kraken2 --db "$database" --threads "$(nproc)" \
    --confidence 0.01 \
    $gzip_option \
    "$queries" --output "$output_directory"/kraken2.tsv

echo "launching Krona"

ktImportTaxonomy \
    -q 2 -t 3 -m 4 \
    -o "$output_directory"/krona.html \
    "$output_directory"/kraken2.tsv

echo "Done !"
