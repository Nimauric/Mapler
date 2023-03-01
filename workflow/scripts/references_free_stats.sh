#!/bin/sh
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=10000


assembly="../data/assemblies/metaflye_SRR8073714/assembly.fasta"
run="../data/input_reads/SRR8073714.fastq"
assembly_name="metaflye_SRR8073714"
run_name="SRR8073714"
threshold=50000
output_folder="../data/stats_reports/metaflye_SRR8073714/"
alignements_folder="../data/alignements/metaflye_SRR8073714/"

#assembly="$1"
#run="$2"
#assembly_name="$3"
#run_name="$4"
#threshold="$5"
#output_folder="$6"
#alignements_folder="$7"


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

if [ ! -f "$alignements_folder"reads_on_contigs.bam ] ; then
    mkdir "$alignements_folder"
    echo ""
    echo "Running minimap2..."
    minimap2 -ax "$sequencer_arguments" "$assembly" "$run" -o "$alignements_folder"reads_on_contigs.bam

    echo ""
    echo "Running samtools sort..."
    samtools sort -l 1 "$alignements_folder"reads_on_contigs.bam -o "$alignements_folder"reads_on_contigs.bam
fi


echo ""
echo "Running samtools coverage..."
samtools coverage "$alignements_folder"reads_on_contigs.bam > "$output_folder"contigs_stats.tsv

echo ""
echo "Counting unmapped reads..."
unmapped_reads=$(samtools view -c -f 4 "$alignements_folder"reads_on_contigs.bam)

echo ""
echo "Calculating GC content..."
scripts/references_free_stats.out "$assembly" "$threshold" "$output_folder"contigs_stats.tsv "$output_folder"contigs_stats_with_GC_content.tsv 

echo ""
echo "Producting a report..."
# "$output_folder"references_free_text_report.txt