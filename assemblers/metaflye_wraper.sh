#!/bin/sh
# This script assemble a set of reads into a metagenome, using Metaflye

# Get parameters
read_type="$1"
run="$2"
output_directory="$3"
Ncpu=$(nproc)

case $read_type in
    "pacbio-clr")
        sequencer_arguments="--pacbio-raw"
        ;;
    "ont")
        sequencer_arguments="--nano-raw"
        ;;
    "pacbio-hifi")
        sequencer_arguments="--pacbio-hifi"
        ;;
    *)
        echo "Unsupported or unrecognized read sequencer !"
        echo $sequencer
        exit 1
        ;;
esac


mkdir -p "$output_directory"/tmp
echo flye --meta -t "$Ncpu" --out-dir "$output_directory"/tmp/ "$sequencer_arguments" "$run"
flye --meta -t "$Ncpu" --out-dir "$output_directory"/tmp/ "$sequencer_arguments" "$run"


mv "$output_directory"/tmp/assembly.fasta "$output_directory"
rm -rf "$output_directory"/tmp/


