#!/bin/sh


#run_name="SRR8073714"
#assembly_name="metaflye_SRR8073714"
#reads="../data/input_reads/SRR8073714.fastq"
#assembly="../data/assemblies/metaflye_SRR8073714/assembly.fasta"
#output_folder="../data/bins/metaflye_SRR8073714/"

run_name="$1"
assembly_name="$2"
reads="$3"
assembly="$4"
output_folder="$5"
prefix="$6"

mkdir "$output_folder"
# Fetch the sequencer used for this run
sequencer=$(../scripts/sequencer_fetcher.sh "$run_name")
case $sequencer in
    "PacBio RS II")
        sequencer_arguments="map-pb"
        ;;
    "MinION")
        sequencer_arguments="map-ont"
        ;;
    "pacbio-hifi")
        sequencer_arguments="map-hifi"
        ;;
    *)
        echo "Unsupported or unrecognized read sequencer !"
        echo $metadata
        exit 1
        ;;
esac


echo ""
echo "Running minimap2..."
echo ""
minimap2 -ax "$sequencer_arguments" "$assembly" "$reads" -o "$output_folder"reads_on_contigs_"$assembly_name".bam

echo ""
echo "Running samtools sort..."
echo ""
samtools sort -l 1 "$output_folder"reads_on_contigs_"$assembly_name".bam -o "$output_folder"reads_on_contigs_"$assembly_name".bam

echo ""
echo "Running metabat2..."
echo ""

jgi_summarize_bam_contig_depths --outputDepth "$output_folder"depth.txt "$output_folder"reads_on_contigs_"$assembly_name".bam --percentIdentity 90

metabat2 -i "$assembly" -a "$output_folder"depth.txt -o "$output_folder"
