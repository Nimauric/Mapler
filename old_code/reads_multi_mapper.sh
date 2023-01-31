#!/bin/sh
#This script align a read passed as an argument, to reference genomes, and find out how many map to each genome


# Create a merged reference file if it doesn't already exist
if [ ! -f "data/reference_genomes/multi_ref.multifasta" ]; then
    echo "" > data/reference_genomes/multi_ref.multifasta
    for f in data/reference_genomes/individual_genomes/*.fasta
    do
        filename=`basename $f .fasta`
        # Name the sequence from the filenmae
        echo ">$filename" >> data/reference_genomes/multi_ref.multifasta
        # If one of the reference genome already contains multiple sequences, concatenate it
        sed -n 'n;p' $f | tr -d '\n' >> data/reference_genomes/multi_ref.multifasta
        echo '\n' >> data/reference_genomes/multi_ref.multifasta
    done
fi

# Align each file
for f in "$@"
do
    filename=`basename $f .fastq.gz`

    echo "running minimap2 on $filename..."
    # Run minimap2
    metadata=$(./sequencer_fetcher.sh $filename 2> /dev/null)
    case $metadata in
        "PacBio RS II")
            minimap2 -ax map-pb data/reference_genomes/multi_ref.multifasta "$f" > data/mapping/mapping_"$filename".sam
            ;;
        "MinION")
            minimap2 -ax map-ont  data/reference_genomes/multi_ref.multifasta "$f" > data/mapping/mapping_"$filename".sam
            ;;
        *)
            echo "Unsupported or unrecognized read sequencer !"
            echo $metadata
            ;;
    esac

    # Run SAMtools
    echo "running samtools on $filename..."
    samtools sort -l 1 -o data/mapping/sorted_mapping_"$filename".bam data/mapping/mapping_"$filename".sam
    samtools coverage data/mapping/sorted_mapping_"$filename".bam > data/reference_genomes/coverage_information_"$filename".tsv
done
