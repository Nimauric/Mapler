#!/bin/sh
source  ./env_init.sh


metaquast ./assembly/assembly.fasta -r $( echo reference_genomes/*/*/QC_and_Genome_Assembly/final.assembly.fasta | tr ' ' , )
#./assembly/assembly.fasta
#./GCA_003957645.1_BMock12_scaffolds_ILLUMINA_genomic.fna.gz
