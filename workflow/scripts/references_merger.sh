#!/bin/sh
# This scripts merges multiples fasta files into one, merging contigs from the same file as one
# "$1" : path to the output
# "${@:2}" : paths to reference genomes

echo "" > "$1"
for f in "${@:2}"
do
    # Extract the file name and use it as a header
    filename=`basename $f .fasta`
    echo ">$filename" >> "$1"
    # Extract the file contents (if multiple contigs, concatenates them)
    sed -n 'n;p' $f | tr -d '\n' >> "$1"
    echo '\n' >> "$1"
done
