#!/bin/sh
# This script analyses a run and generates a quality report
# $1 : path/to/a/run.fastq
# $2 : path/to/the/output/folder

reads=$1
output_directory=$2

# Sets up java parameters so that fastQC works on big files
export _JAVA_OPTIONS=-Xmx2048m
echo "processing $reads"
mkdir "$output_directory"/
fastqc "$reads" -o "$output_directory"/ -t $(nproc)

rename 's/.html/ "$output_directory"\/fastqc_report.html' "$output_directory"/*.html

mv "$output_directory"/*.html "$output_directory"/fastqc_report.html




