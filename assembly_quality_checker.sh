#!/bin/sh

for f in "$@"
do
    foldername=`basename $f`
    mkdir data/assemblies_QC/"$foldername"
    metaquast "$f"/assembly.fasta -r $( echo data/reference_genomes/*.fasta | tr ' ' , ) -o data/assemblies_QC/"$foldername"
done
