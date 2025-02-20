#!/bin/sh
#SBATCH --time=3-00:00:00
#SBATCH --mem=10G
#SBATCH --cpus-per-task=1

opera_path="$1"
long_reads="$2"
short_reads_1="$3"
short_reads_2="$4"
short_read_assembly="$5"
tmp_directory="$6"


if [ ! -d "$opera_path" ]; then
   echo "not here"
   mkdir -p "$opera_path"
   cd "$opera_path"
   cd ..
   git clone https://github.com/CSB5/OPERA-MS.git
   cd OPERA-MS
   make
   perl OPERA-MS.pl check-dependency
fi


perl "$opera_path"/OPERA-MS.pl \
    --num-processors $(nproc) \
    --no-ref-clustering \
    --contig-file "$short_read_assembly" \
    --short-read1 "$short_reads_1" \
    --short-read2 "$short_reads_2" \
    --long-read "$long_reads" \
    --out-dir "$tmp_directory"

