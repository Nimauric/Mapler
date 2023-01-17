#!/bin/sh
source  ./env_init.sh

<<<<<<< HEAD
files=(./assembly/*.f*)
for f in "${files[@]}"
do
    echo $f
    metaquast $f
done

#metaquast ../GCA_003957645.1_BMock12_scaffolds_ILLUMINA_genomic.fna.gz
#metaquast assembly/assembly.fasta
=======

metaquast ./assembly/assembly.fasta -r $( echo reference_genomes/*/*/QC_and_Genome_Assembly/final.assembly.fasta | tr ' ' , )
#./assembly/assembly.fasta
#./GCA_003957645.1_BMock12_scaffolds_ILLUMINA_genomic.fna.gz
>>>>>>> 6fd3619f21fefa2dc5a5840057f6d70a45aa05b4
