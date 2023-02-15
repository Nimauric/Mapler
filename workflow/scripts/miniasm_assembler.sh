#!/bin/sh
# This script assemble a set of reads into a metagenome, using miniasm
# "$1" : name of the run (SRA accession number)
# "$2" : path/to/the/run.fastq.gz
# "$3" : path/to/the/output/folder

# Fetch the sequencer used for this run
sequencer=$(./scripts/sequencer_fetcher.sh "$1")
case $sequencer in
    "PacBio RS II")
        sequencer_arguments="ava-pb"
        ;;
    "MinION")
        sequencer_arguments="ava-ont"
        ;;
    "pacbio-hifi")
        echo "Hifi reads not supported by miniasm !"
        exit 1
        ;;
    *)
        echo "Unsupported or unrecognized read sequencer !"
        echo $sequencer
        exit 1
        ;;
esac

# Align the reads against themselves with minimap2
mkdir "$3"
minimap2 -x "$sequencer_arguments" "$2" "$2" | gzip -1 > "$3"minimap.paf.gz

# Assemble the metagenome with miniasm
miniasm -f "$2" "$3"minimap.paf.gz > "$3"assembly.gfa

# Extract the fasta from the gfa
awk '/^S/{print ">"$2"\n"$3}' "$3"assembly.gfa > "$3"assembly.fasta
