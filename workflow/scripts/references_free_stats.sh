#!/bin/sh

#assembly="../data/assemblies/metaflye_SRR8073714/assembly.fasta"
#run="../data/input_reads/SRR8073714.fastq"
#assembly_name="metaflye_SRR8073714"
#run_name="SRR8073714"
#threshold=50000
#output_folder="../data/stats_reports/metaflye_SRR8073714/"
#alignements_folder="../data/alignements/metaflye_SRR8073714/"

assembly="$1"
run="$2"
assembly_name="$3"
run_name="$4"
threshold="$5"
output_folder="$6"
alignements_folder="$7"

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

mkdir "$alignements_folder"
echo ""
echo "Running minimap2..."
minimap2 -cx "$sequencer_arguments" "$assembly" "$run" -o "$alignements_folder"reads_on_contigs.paf

echo ""
echo "Calculating metrics : "
./scripts/references_free_stats.out "$alignements_folder"reads_on_contigs.paf $run $assembly "$output_folder"contigs_stats.csv "$output_folder"filtered_stats.csv "$output_folder"references_free_text_report.txt $threshold

echo ""
echo "Producing plots..."
python3 scripts/references_free_stats.py "$output_folder"contigs_stats.csv $output_folder

echo "Done !"
