#!/bin/sh
# This script assemble a set of reads into a metagenome, using metaflye
# "$1" : name of the run (SRA accession number)
# "$2" : path/to/the/run.fastq
# "$3" : path/to/the/output/folder

# Fetch the sequencer used for this run
sequencer=$(./scripts/sequencer_fetcher.sh "$1")
case $sequencer in
    "PacBio RS II")
        sequencer_arguments="--pacbio-raw"
        ;;
    "MinION")
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

# Run metaflye
mkdir "$3"
Ncpu=$(nproc)
echo $Ncpu
flye --meta -t" $Ncpu" --out-dir "$3" "$sequencer_arguments" "$2"
