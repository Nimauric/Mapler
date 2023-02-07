#!/bin/sh
# "$1" : path/to/the/run.fastq.gz
# "$2" : desired coverage
# "$3" : path/to/indexed/merged/reference/genome
# "$4" : path/to/the/new_subsampled/run.fastq.gz

rasusa --input $1 --coverage $2 --genome-size $3 --output $4