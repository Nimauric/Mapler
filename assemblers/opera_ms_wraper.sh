#!/bin/sh
# "$1" : path/to/the/R1/short/reads/run.fastq.gz
# "$2" : path/to/the/R2/short/reads/run.fastq.gz

# "$3" : path/to/the/long/reads/run.fastq.gz

# "$4" : path/to/the/output/folder

short1="$1"
short2="$2"
long="$3"
output_directory="$4"
Ncpu=$(nproc)

echo ======================================
generic_arguments="--no-ref-clustering --num-processors "$num_processor" "

mkdir "$4"
#perl dependencies/OPERA-MS/tools_opera_ms/install_perl_module.pl

#source ../config/opera_ms_installer.sh


#eval "$(conda shell.bash hook)" #Makes it possible to use conda activate
#conda activate ~/operaMS_install_env


echo perl dependencies/OPERA-MS/OPERA-MS.pl \
    --no-ref-clustering \
    --num-processors "$num_processor" \
    --short-read1 "$short1" \
    --short-read2 "$short2" \
    --long-read "$long" \
    --out-dir "$output_directory"/tmp


#mv "$4"contigs.polished.fasta  "$4"assembly.fasta


