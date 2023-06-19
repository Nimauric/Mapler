#!/bin/sh
# This script assemble a set of reads into a metagenome, using metaflye
read_type="$1"
run="$2"
output_directory="$3"

case $read_type in
    "PacBio-CLR")
        sequencer_arguments="--pacbio-raw"
        ;;
    "ONT")
        sequencer_arguments="--nano-raw"
        ;;
    "PacBio-Hi-Fi")
        sequencer_arguments="--pacbio-hifi"
        ;;
    *)
        echo "Unsupported or unrecognized read sequencer !"
        echo $sequencer
        exit 1
        ;;
esac

Ncpu=$(nproc)

# Run metaflye
mkdir "$output_directory"
mkdir "$output_directory"/tmp

echo flye --meta -t "$Ncpu" --out-dir "$output_directory"/tmp/ "$sequencer_arguments" "$run"
mv "$output_directory"/tmp/assembly.fasta "$output_directory"
rm  "$output_directory"/tmp/*

