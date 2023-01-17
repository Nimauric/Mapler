#!/bin/sh

files=(./assembly/*.f*)
for f in "${files[@]}"
do
    echo $f
    metaquast $f
done

#metaquast ../GCA_003957645.1_BMock12_scaffolds_ILLUMINA_genomic.fna.gz
#metaquast assembly/assembly.fasta
