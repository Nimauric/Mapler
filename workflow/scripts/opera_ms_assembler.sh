#!/bin/sh
# "$1" : path/to/the/R1/short/reads/run.fastq.gz
# "$2" : path/to/the/R2/short/reads/run.fastq.gz

# "$3" : path/to/the/long/reads/run.fastq.gz

# "$4" : path/to/the/output/folder

num_processor=$(nproc)
echo $num_processor
generic_arguments="--no-ref-clustering --num-processors "$num_processor" "

mkdir "$4"
perl dependencies/OPERA-MS/OPERA-MS.pl \
    $generic_arguments \
    --short-read1 "$1" \
    --short-read2 "$2" \
    --long-read "$3" \
    --out-dir "$4"

mv "$4"contigs.polished.fasta  "$4"assembly.fasta
