#!/bin/sh
# This script assemble a set of reads into a metagenome, using canu
# "$1" : name of the run (SRA accession number)
# "$2" : path/to/the/run.fastq.gz
# "$3" : path/to/the/output/folder
# "$4" : estimated average genome size

# Fetch the sequencer used for this run
generic_arguments=genomeSize="$4" maxInputCoverage=10000 corOutCoverage=10000 corMhapSensitivity=high corMinCoverage=0 redMemory=32 oeaMemory=32 batMemory=200
sequencer=$(./scripts/sequencer_fetcher.sh "$1")
case $sequencer in
    "PacBio RS II")
        sequencer_arguments="-pacbio"
        ;;
    "MinION")
        sequencer_arguments="-nanopore"
        ;;
    *)
        echo "Unsupported or unrecognized read sequencer !"
        echo $sequencer
        exit 1
        ;;
esac

# Run Canu
#useGrid=flase means canu doesn't use the cluster
canu -p "$1" -d "$3" "$sequencer_arguments" "$2" "$generic_arguments" useGrid=false
mv "$3""$1".contigs.fasta "$3"assembly.fasta
