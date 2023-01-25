#!/bin/sh
#This script align a read passed as an argument, to reference genomes, and find out how many map to each genome


# Create a merged reference file if it doesn't already exist
if [ ! -f "data/reference_genomes/multi_ref.multi_fasta" ]; then
    echo "" > data/reference_genomes/multi_ref.multi_fasta
    for f in data/reference_genomes/*.fasta
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
    minimap2 -ax map-pb data/reference_genomes/multi_ref.multifasta "$f" > data/mapping/mapping_"$filename".sam

    # Run SAMtools
    echo "running samtools on $filename..."
    samtools sort -l 1 -o data/mapping/sorted_mapping_"$filename".bam data/mapping/mapping_"$filename".sam
    samtools coverage data/mapping/sorted_mapping_"$filename".bam > data/reference_genomes/coverage_information_"$filename".tsv
done
