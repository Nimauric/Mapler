#!/bin/sh
# This script polishes an assembly, using flye
# "$1" : name of the run (SRA accession number)
# "$2" : path/to/the/run.fastq.gz
# "$3" : path/to/the/assembly/to/polish.fasta
# "$4" : path/to/the/output/folder

sequencer=$(./scripts/sequencer_fetcher.sh "$1")
case $sequencer in
    "PacBio RS II")
        sequencer_arguments="--pacbio-raw"
        ;;
    "MinION")
        sequencer_arguments="--nano-raw"
        ;;
    *)
        echo "Unsupported or unrecognized read sequencer !"
        echo $sequencer
        exit 1
        ;;
esac

flye "$sequencer_arguments" "$2"  --polish-target "$3" --out-dir "$4"