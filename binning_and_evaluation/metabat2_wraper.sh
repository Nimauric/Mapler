#!/bin/sh
run_type="$1"
run="$2"
assembly="$3"
output_directory="$4"
Ncpu=$(nproc)

mkdir "$output_directory"

case "$run_type" in
    "pacbio-clr")
        sequencer_arguments="map-pb"
        ;;
    "ont")
        sequencer_arguments="map-ont"
        ;;
    "pacbio-hifi")
        sequencer_arguments="map-hifi"
        ;;
    *)
        echo "Unsupported or unrecognized read sequencer !"
        echo "$run_type"
        exit 1
        ;;
esac



echo ""
echo "Aligning reads and assembly..."
minimap2 -t "$Ncpu" -ax "$sequencer_arguments" "$assembly" "$run" -o "$output_directory"/reads_on_contigs.bam

echo ""
echo "Sorting alignement..."
samtools sort -l 1 "$output_directory"/reads_on_contigs.bam -o "$output_directory"/reads_on_contigs.bam

echo ""
echo "Summarizing conting depths..."
jgi_summarize_bam_contig_depths --outputDepth "$output_directory"/contigs_depth.txt "$output_directory"/reads_on_contigs.bam --percentIdentity 90

echo ""
echo "Building contigs..."
metabat2 -i "$assembly" -a "$output_directory"/contigs_depth.txt -o "$output_directory"/bin

echo ""
echo "Done !"