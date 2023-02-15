#!/bin/sh
#assembly="../data/assemblies/miniasm_toy-SRR8073713/assembly.fasta"
#run="../data/input_reads/toy-SRR8073713.fastq"
#assembly_name="miniasm_toy-SRR8073713"
#run_name="toy-SRR8073713"
#threshold=50000
#output="../data/stats_reports/miniasm_toy-SRR8073713/miniasm_toy-SRR8073713_references_free_report.txt"

assembly="$1"
run="$2"
assembly_name="$3"
run_name="$4"
threshold="$5"
output="$6"


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

echo ""
echo "Running minimap2..."
echo ""
minimap2 -ax "$sequencer_arguments" "$assembly" "$run" -o ../data/tmp/mapping_"$assembly_name".bam

echo ""
echo "Counting mapped reads..."
echo ""
mapped_reads=$(samtools view -c -F 4 ../data/tmp/mapping_"$assembly_name".bam)

echo ""
echo "Counting unmapped reads..."
echo ""
unmapped_reads=$(samtools view -c -f 4 ../data/tmp/mapping_"$assembly_name".bam)
mapped_ratio=$(bc <<< "scale=2; 100*$mapped_reads / ($mapped_reads + $unmapped_reads)")

echo "Mapped reads : $mapped_reads" > $output
echo "Unmapped reads : $unmapped_reads" >> $output
echo "Mapped ratio : "$mapped_ratio"%" >> $output

echo ""
echo "Calculating length based metrics..."
echo ""
scripts/references_free_stats.out "$assembly" "$threshold" >> $output
