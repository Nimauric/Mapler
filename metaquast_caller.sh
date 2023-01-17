#!/bin/sh
source  ./env_init.sh

files=(./assembly/*.f*)
for f in "${files[@]}"
do
    echo $f
    metaquast $f -r $( echo reference_genomes/*/*/QC_and_Genome_Assembly/final.assembly.fasta | tr ' ' , )
done

#metaquast ../GCA_003957645.1_BMock12_scaffolds_ILLUMINA_genomic.fna.gz
#metaquast assembly/assembly.fasta

