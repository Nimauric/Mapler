#!/bin/sh

output_directory="$1"
gtdbtk_database="$2"
mash_database="$3"
bin_directory="$4"


mkdir -p $output_directory/results
mkdir -p $output_directory/tmp

export GTDBTK_DATA_PATH=$gtdbtk_database

gtdbtk classify_wf --cpus $(nproc) \
    --genome_dir $bin_directory \
    --out_dir $output_directory/results \
    --tmpdir $output_directory/tmp \
    --mash_db $mash_database \
    --extension fa
