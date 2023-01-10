#!/bin/sh
# This script downloads each sequence whose accession number is written in the SraAccList.txt file

input="./SraAccList.txt"
while IFS= read -r line
do  
    echo ""
    echo "downloading" "$line""..."
    # Prefetch followed by fasterq-dump is the fastest way to download a fastq file
    prefetch "$line" --max-size u
    fasterq-dump "$line"

    # If it doesn't work (no file is created) (mainly because fasterq-dump doesn't work on PacBio sequences), use fastq-dump
    if ! ls "$line"* 1> /dev/null 2>&1; then
        echo "fasterq failed, trying fastq..."
        fastq-dump  "$line"
    fi
done < "$input"

# Once it'd done, move all fastq files to the fastq folder for the rest of the pipeline
mv *.fastq fastq/
echo "done !"

