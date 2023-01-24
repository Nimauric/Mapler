#!/bin/sh
# This script checks the quality of any input assembly using metaquast

for f in "$@"
do
    foldername=`basename $f`
    mkdir data/assemblies_QC/"$foldername"
    metaquast "$f"/*.fasta -r $( echo data/reference_genomes/*.fasta | tr ' ' , ) -o data/assemblies_QC/"$foldername"
done
