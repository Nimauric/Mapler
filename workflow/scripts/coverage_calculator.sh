#!/bin/sh
#This script align thepassed as an argument, to reference genomes, and find out how many map to each genome
# "$1" : name of the run (SRA accession number)
# "$2" : path to the read to align
# "$3" : path to the merged_reference.fasta
# "$4" : path to the folder to store temporary files ("/" included)
# "$5" : path to the output tsv

# Fetch the sequencer used for this run
sequencer=$(./scripts/sequencer_fetcher.sh "$1")
case $sequencer in
    "PacBio RS II")
        sequencer_arguments="map-pb"
        ;;
    "MinION")
        sequencer_arguments="map-ont"
        ;;
    *)
        echo "Unsupported or unrecognized read sequencer !"
        echo $metadata
        exit 1
        ;;
esac

# Run minimap2
minimap2 -ax "$sequencer_arguments" "$3" "$2" > "$4"mapping_"$filename".sam
# Run SAMtools
samtools sort -l 1 "$4"mapping_"$filename".sam -o "$4"mapping_"$filename".bam
samtools coverage "$4"mapping_"$filename".bam > "$5"
