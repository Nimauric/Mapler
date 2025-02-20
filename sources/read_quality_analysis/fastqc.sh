#!/bin/sh
# This script analyses a run and generates a quality report
# $1 : path/to/a/run.fastq
# $2 : path/to/the/output/folder

reads=$1
output_directory=$2

# Sets up java parameters so that fastQC works on big files
export _JAVA_OPTIONS=-Xmx2048m
echo "processing $reads"
mkdir -p "$output_directory"/
rm -r "$output_directory"/*
fastqc "$reads" -o "$output_directory"/ -t $(nproc)

mv "$output_directory"/*.html "$output_directory"/fastqc_report.html
echo "Done!"



