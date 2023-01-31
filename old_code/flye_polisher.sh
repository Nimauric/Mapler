#!/bin/sh
# This script polishes an assembly with flye

echo "$1"
echo "$2"

read="data/raw_reads/"$2".fastq.gz"
contigs={contigs,assembly}
assembly=$(find "data/assemblies/"$1"_"$2"/" -name "assembly.fasta" -print)
outdir="data/assemblies/flye_polish_"$1"_"$2""

echo $assembly

metadata=$(./sequencer_fetcher.sh $2 2> /dev/null)
case $metadata in
    "PacBio RS II")
        option="pacbio-raw"
        ;;
    "MinION")
         option="nano-raw"
        ;;
    *)
        echo "Unsupported or unrecognized read sequencer !"
        echo $metadata
        ;;
esac
if [ ! -z "$assembly" ]; then
    echo flye --"$option" "$read" --polish-target "$assembly" --out-dir "$outdir"
    flye --"$option" "$read" --polish-target "$assembly" --out-dir "$outdir"
fi
