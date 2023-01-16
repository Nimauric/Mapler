#!/bin/sh
# This script sets up the environement for the long reads metagenomic assembly pipeline

# Sets up java parameters so that fastQC works on big files
export _JAVA_OPTIONS=-Xmx2048m

files=(./fastq/*.fastq.gz)
for f in "${files[@]}"
do
    filename=`basename $f .fastq.gz`
    if ! [ -f ./fastQC/${filename}_fastqc.html ] # Checks if fastQC was already run for this file
        then
	    fastqc $f -o ./fastQC # Calls the fastQC tool, with its output is the ./fastQC folder
        else
            echo "$filename already analysed"
    fi
    
done
