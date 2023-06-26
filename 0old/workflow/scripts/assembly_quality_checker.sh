#!/bin/sh
# This script checks the quality of any input assembly using metaquast
# "$1" : path/to/the/assembly.fasta
# "$2" : path/to/the/output/folder
# "${@:3}" : paths to reference genomes

#mkdir "$2"
#echo $(echo "${@:3}")
#echo metaquast "$1" -r $( echo "${@:3}" | tr ' ' , ) -o "$2"
metaquast "$1" -r $( echo "${@:3}" | tr ' ' , ) -o "$2"

