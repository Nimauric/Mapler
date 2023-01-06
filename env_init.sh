#!/bin/sh
# create folders for the data
mkdir fastq # raw fastq
mkdir fastQC # quality check

# uses the genouest environnements
. /local/env/envsra-tools-2.11.0.sh
. /local/env/envfastqc-0.11.9.sh
. /local/env/envjava-1.8.0.sh
