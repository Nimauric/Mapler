#!/bin/sh
# This script sets up the environement for the long reads metagenomic assembly pipeline

echo "creating folders..."
mkdir fastq # raw fastq
mkdir fastQC # quality check

echo "setting up the genouest evnvironnement..."
. /local/env/envsra-tools-2.11.0.sh
. /local/env/envfastqc-0.11.9.sh
. /local/env/envjava-1.8.0.sh

echo "setting up the conda environnement"
# created with : . /local/env/envconda.sh
# then : conda create -p ~/meta_flye_env flye  
conda activate ~/meta_flye_env
