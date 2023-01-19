#!/bin/sh
# This script downloads each sequence whose accession number is written in the SraAccList.txt file

input="./SraAccList.txt"
while IFS= read -r line
do  
    echo ""
    echo "downloading" "$line""..."
    # Prefetch followed by fasterq-dump is the fastest way to download a fastq file
    echo "prefetching..."
    prefetch "$line" --max-size u
    echo "dumping..."
    fasterq-dump "$line"*
    echo "compressing..."
    rm -r "$line" # removes the temporary folder made by prefetch to quicken fasterq-dump
    gzip "$line".fastq # compress the fastq
    

    # If it doesn't work (no file is created) (mainly because fasterq-dump doesn't work on PacBio sequences), use fastq-dump
    if ! ls "$line"* 1> /dev/null 2>&1; then
        echo "fasterq failed, trying fastq..."
        fastq-dump --split-files --gzip "$line"
    fi

    # Once it'd done, move the archive to the fastq folder for the rest of the pipeline
    mv "$line".fastq.gz data/raw_reads/

done < "$input"


echo "done !"

