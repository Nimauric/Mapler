#!/bin/sh
# This script checks the quality of any input assembly using metaquast
# "$1" : path/to/the/assembly.fasta
# "$2" : path/to/the/output/folder
# "${@:3}" : paths to reference genomes


assembly="$1"
output_directory="$2"
min_identity="$3"
reference_genomes="${@:4}"


mkdir "$output_directory"
metaquast "$assembly" -r $( echo "$reference_genomes" | tr ' ' , ) -o "$output_directory" --min-identity "$min_identity" --unique-mapping --threads $(nproc)
#--reuse-combined-alignments #this option doesn't work with all metaquast options

