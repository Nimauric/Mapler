#!/bin/bash
assembly="$1"
reads_on_contigs="$2"
output_directory="$3"
second_reads_on_contigs="${@:4}"  # Optional, used for co-binning
Ncpu=$(nproc)



echo ""
echo "Summarizing conting depths..."
jgi_summarize_bam_contig_depths --outputDepth "$output_directory"/contigs_depth.txt $reads_on_contigs ${second_reads_on_contigs} --percentIdentity 90

echo ""
echo "Building contigs..."
metabat2 -i "$assembly" -a "$output_directory"/contigs_depth.txt -o "$output_directory"/bin -t $(nproc)

echo ""
echo "Done !"