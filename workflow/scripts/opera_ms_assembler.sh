#!/bin/sh
# "$1" : path/to/the/R1/short/reads/run.fastq.gz
# "$2" : path/to/the/R2/short/reads/run.fastq.gz

# "$3" : path/to/the/long/reads/run.fastq.gz

# "$4" : path/to/the/output/folder

generic_arguments = "--no-ref-clustering --num-processors=10"
mkdir "$4"
perl dependencies/OPERA-MS/OPERA-MS.pl \
    --short-read1 "$1" \
    --short-read2 "$2" \
    --long-read "$3" \
    "$generic_arguments" \
    --out-dir "$4"
