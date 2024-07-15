# Mapler (MAEPLR)
Metagenome Assembly and Evaluation Pipeline for Long Reads 

## Description
The aim of this repository is to compare long-reads metagenomic assemblers, focusing on hi-fi assemblers, but with support for lo-fi long reads assemblers and hybrid assemblers.

This pipeline was used to study assembly of complex ecosystems and their evaluation, the results of which can be found here : https://inria.hal.science/hal-04142837

## Installation
Clone the repository in a cluster with slurm support.


## Usage
Activate a conda environment with conda and snakemake  installed.
Edit the `config.yaml` to specify the name and path of samples you wish to use. 
Some metrics can be set to true or false, others are list, delete or comment which options you don't want to use. There are others numerical parameters which can be set to any value.

Then, if you want to previsualise the pipeline, run `./np_pipeline.sh`, then `sbatch pipeline.sh` to launch the pipeline on the cluster
