# MAEPLR
Metagenome Assembly and Evaluation Pipeline for Long Reads 

## Description
The aim of this repository is to compare long-reads metagenomic assemblers, focusing on hi-fi assemblers, but with support for lo-fi long reads assemblers and hybrid assemblers.

## Installation
Clone the repository in a cluster with slurm and conda support, then run `source initialise_env.sh`

## Usage
Edit the `config.yaml`file to specify the name and path of runs of reads you wish to assemble, and comment or uncomment assemblers and metrics you wish to use.
If you use reference-based metrics, you must specify the path to a folder (reference-genomes) containing reference genomes, and a csv file (abundance-information) containing, for each reference genome, their group (I advice grouping them by abundance)

Then run `source activate_env.sh` and, if you want to previsualise the pipeline, `./np_pipeline.sh`, then `sbatch pipeline.sh` to launch the pipeline

## Files and directories
 - Snakefile : the pipeline itself
 - activate_env.sh : activate the conda environement required to launch the pipeline
 - config.yaml : config file to chose which reads, assemblers and evaluation methods to use
 - initialise_env.sh : create the conda environement required to launch the pipeline and instal external dependencies
 - np_pipeline.sh : a wraper to previsualise the pipeline execution
 - pipeline.sh : a wraper to call the pipeline

#### assemblers :
Metagenome assemblers, and eventually polishers, or other programs that help to assemble a metagenome and are called by rules in `assembly.smk`.

#### assembly_evaluation :
Programs that evaluate the quality of a metagenome assembly and produce reports, with or without references, that are called by rules in `assembly_evaluation.smk`

#### binning_and_evaluation :
Programs that regroup metagenome contigs into bins, and evaluate them without, or eventually with, references, that are called by rules in `binning_evaluation.smk`

#### dependencies :
Programs that install dependencies that are not supported by conda, and where those dependencies are installed

#### env :
Conda environements used by various rules

#### rules :
Auxiliary snakefiles that contain rules for specific parts of the pipeline : assembly, evaluation of the assembly and binning with evaluation of the binning. 

#### utils:
Unsupported files that are not directly involved in the pipeline, but might be (or have been) useful to prepare or analyze data. Most aren't up to date with the pipeline, but might be useful to specific application or for future developements.


