# metagenomic_benchmark
## Description
The aim of this repository is to compare long-reads metagenomic assemblers.

## Installation
Clone the repository in a cluster with slurm and conda support, then run `source initialise_env.sh`

## Usage
Edit the `config.yaml`file to specify the name and path of runs of reads you wish to assemble, and comment or uncomment assemblers and metrics you wish to use.
If you use reference-based metrics, you must specify the path to a folder (reference-genomes) containing reference genomes, and a csv file (abundance-information) containing, for each reference genome, their group (I advice grouping them by abundance)

Then run `source activate_env.sh` and, if you want to previsualise the pipeline, `./np_pipeline.sh\, then `sbatch pipeline.sh`
## Pipeline 

![dag](dag.pdf)

## Files
#### config : 
 - config.yaml : used to tell the pipeline which reads to assemble with which assemblers
 - initialise_environnement.sh : creates folders and sets up a conda environement
 - activate_environement.sh : activates the aforementioned conda environement 

#### workflow :
 - Snakefile : the pipeline itself
 - pipeline.sh : activates the environement, then calls snakemake

#### workflow/auxiliary : 
Unsupported files that are not directly involved in the pipeline, but might be (or have been) useful to prepare or analyze data

#### workflow/scripts :
 - reads_quality_checker.sh : checks the reads quality using fastQC
 - sequencer_fetcher.sh : fetches the sequencer used by a run, either from a file or from the sra database
 - metaflye_assembler.sh : assemble metagenomes using metaflye
 - canu_assembler.sh : assemble metagenomes using canu
 - miniasm_assembler.sh : assemble metagenomes using minimap, miniasm and awk
 - flye_polisher.sh : polishes metagenome assemblies with flye
 - references_free_stats.sh : checks the quality of the assemblies by checking the proportion of reads mapping to the assembly
 - references_free_stats.cpp : checks the quality of the assemblies with length-based metrics
 - references_merger.sh : congreate references genomes in a single file to help with coverage calculation
 - coverage_calculator.sh : map reads to reference genomes to infer their sequencing debth
 - assembly_quality_checker.sh : checks the quality of the assemblies using metaquast
 - references_based_stats.py : aggregates metaquast metrics and group them depending on the species abudance.


