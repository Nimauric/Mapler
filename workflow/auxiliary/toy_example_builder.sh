#!/bin/sh
# This script builds a toy example : from a run of reads, select those that align to some reference genomes, 
# then subsample them to reach a desired coverage

# "$1" : name of the run (SRA accession number)
# "$2" : path/to/the/run/to/sumbsample/from.fastq.gz
# "$3" : desired coverage
# "$4" : path to the folder to store temporary files ("/" included)
# "${@:5}" : paths to reference genomes

# Create merged reference
path_to_references=( "../data/input_reference_genomes/Halomonassp_3.fasta" "../data/input_reference_genomes/MarspLV10R5108_2.fasta")
path_to_merged_reference=(../data/merged_reference_genome/toy_merge.fasta)
./scripts/references_merger.sh $path_to_merged_reference ${path_to_references}

# Fetch the sequencer used for this run
run_name="SRR8073713"
sequencer=$(./scripts/sequencer_fetcher.sh "$run_name")
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
path_to_run="../data/input_reads/SRR8073713.fastq.gz"
path_to_sam_align="../data/tmp/toy_mapping_SRR8073713.sam"
#minimap2 -ax "$sequencer_arguments" "$path_to_merged_reference" "$path_to_run" > "$path_to_sam_align"

# Get reads from the sam
path_to_output="../data/input_reads/toy_SRR8073713.fastq.gz"
samtools fastq -F 4 "$path_to_sam_align" > "$path_to_output"

