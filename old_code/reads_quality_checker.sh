#!/bin/sh
# This script generates a report on the quality of the reads

# Sets up java parameters so that fastQC works on big files
export _JAVA_OPTIONS=-Xmx2048m

for f in $@
do
    foldername=`basename $f .fastq.gz`
    mkdir ./data/reads_QC/$foldername
    fastqc $f -o ./data/reads_QC/$foldername
done
