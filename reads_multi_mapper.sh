#!/bin/sh
#This script align a read passed as an argument, to reference genomes, and find out how many map to each genome

# Create a merged reference file 
echo "" > data/reference_genomes/multi_ref.fasta
for f in data/reference_genomes/*.fasta
do
    if [ $f = "data/reference_genomes/multi_ref.fasta" ]; then
        continue
    fi
    echo $f
    filename=`basename $f .fasta`
    echo ">$filename" >> data/reference_genomes/multi_ref.fasta
    sed -n 'n;p' $f | tr -d '\n' >> data/reference_genomes/multi_ref.fasta
    echo '\n' >> data/reference_genomes/multi_ref.fasta
    #sed -n 'n;p' $f >> data/reference_genomes/multi_ref.fasta
done

# Run minimap2
minimap2 -ax map-pb data/reference_genomes/multi_ref.fasta data/raw_reads/SRR8073714.fastq.gz > data/mapping/mapping_multi_ref.sam

# Run SAMtools
samtools sort -l 1 -o data/mapping/sorted_multi_ref.bam data/mapping/mapping_multi_ref.sam
samtools coverage data/mapping/sorted_multi_ref.bam > data/reference_genomes/coverage_information.tsv
