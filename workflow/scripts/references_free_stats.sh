#!/bin/sh
assembly="../data/assemblies/miniasm_toy-SRR8073713/assembly.fasta"
run="../data/input_reads/toy-SRR8073713.fastq"
assembly_name="miniasm_toy-SRR8073713"
run_name="toy-SRR8073713"

# Fetch the sequencer used for this run
sequencer=$(./scripts/sequencer_fetcher.sh "$run_name")
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

# Run minimap2
echo ""
echo "Running minimap2..."
echo ""
minimap2 -ax "$sequencer_arguments" "$assembly" "$run" -o ../data/tmp/mapping_"$assembly_name".bam

# Running samtools view
echo ""
echo "Counting mapped reads..."
echo ""
mapped_reads=$(samtools view -c -F 4 ../data/tmp/mapping_"$assembly_name".bam)
echo ""
echo "Counting unmapped reads..."
echo ""
unmapped_reads=$(samtools view -c -f 4 ../data/tmp/mapping_"$assembly_name".bam)
mapped_ratio=$(bc <<< "scale=2; 100*$mapped_reads / ($mapped_reads + $unmapped_reads)")

echo "Mapped reads : $mapped_reads"
echo "Unmapped reads : $unmapped_reads"
echo "Mapped ratio : "$mapped_ratio"%"
