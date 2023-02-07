#!/bin/sh
# This script analyses a run and generates a quality report
# $1 : path/to/a/run.fastq.gz
# $2 : path/to/the/output/folder

# Sets up java parameters so that fastQC works on big files
export _JAVA_OPTIONS=-Xmx2048m

mkdir "$2"
fastqc "$1" -o "$2"

