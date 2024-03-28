#!/bin/sh
#SBATCH --time=3-00:00:00
#SBATCH --mem=100G
#SBATCH --cpus-per-task=48

opera_path="$1"
long_reads="$2"
short_reads_1="$3"
short_reads_2="$4"
short_read_assembly="$5"
tmp_directory="$6"

perl "$opera_path"/OPERA-MS.pl \
    --num-processors $(nproc) \
    --no-ref-clustering \
    --contig-file "$short_read_assembly" \
    --short-read1 "$short_reads_1" \
    --short-read2 "$short_reads_2" \
    --long-read "$long_reads" \
    --out-dir "$tmp_directory"

