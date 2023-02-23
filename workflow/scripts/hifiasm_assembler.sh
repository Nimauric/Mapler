#!/bin/sh
# This script assemble a set of reads into a metagenome, using miniasm
# "$1" : path/to/the/run.fastq
# "$2" : path/to/the/output/folder

Ncpu= $(squeue -j "$$" -o \"%C\")
echo $Ncpu

hifiasm_meta -o "$2" -t"Ncpu" "$1"

