#!/bin/sh

for f in ../data/reference_genomes/*.fasta
do  
    # Align reads
    filename=`basename $f .fasta`
    echo $f   
    minimap2 -ax map-pb $f data/raw_reads/SRR8073714.fastq.gz > data/mapping/mapping_"$filename".sam
done

for f in ../data/mapping/*.sam
do
    # Count aligned reads
    samtools flagstat $f
done

