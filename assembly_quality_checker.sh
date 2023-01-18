#!/bin/sh

for f in "$@"
do
    metaquast $f -r $( echo data/reference_genomes/*.fasta | tr ' ' , )
done
