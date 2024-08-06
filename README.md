# Mapler (MAEPLR)
Metagenome Assembly and Evaluation Pipeline for Long Reads 

## Description
The aim of this repository is to compare long-reads metagenomic assemblers, focusing on hi-fi assemblers, but with support for lo-fi long reads assemblers and hybrid assemblers.

This pipeline was used to study assembly of complex ecosystems and their evaluation, the results of which can be found here : https://inria.hal.science/hal-04142837

## Installation
I reccommend using a slurm server, but the pipeline can be run locally 
Clone the git repository and install snakemake (7.28.3). I recommend using conda : 
```
git clone git@gitlab.inria.fr:mistic/mapler.git
conda create -n snakemake -c bioconda snakemake=7.28.3
```
Most other dependencies are installed by the pipeline itself via conda. Exeptions include programs unaviable via conda and large databases, which must be downloaded separately if you want to perform certain analysis :
- [OPERA-MS](https://github.com/CSB5/OPERA-MS), for hybrid assemblies
- the [genome taxonomy database](https://gtdb.ecogenomic.org/), for the taxonomic assignation of bins
- a [kraken database](https://benlangmead.github.io/aws-indexes/k2) (I used the standard kraken database), for the taxonomic assignation of reads and select bins of interest


## Usage
Before using the pipeline, you must create a copy of `config/config_template.yaml` called `config/config.yaml`. 
Details on how to configure this file are written as comments of said file,a nd it is structred in threee parts : 
- Inputs : path to samples and external programs (most are optional)
- Controls : sometimes a choice between multiple options (uncomment lines you wish to use, you may select multiple), sometimes a binary choice on wether you wish to run the analysis (true) or not (false)
- Parameters : functional parameters are values that can be tweaked for certain analysis, ressources parameters allows to tweak memory, threads and allocated time for ressource-intensive rules

Navigate to the pipeline directory (`mapler`)
If using conda, activate the environnement with `conda activate snakemake`. 
Then, run `./np_pipeline.sh` to check wether the pipeline will produce the expected results.
If you're in a slurm cluster, run `sbatch pipeline.sh`, otherwise `local_pipeline.sh`

## Logs and Outputs
Logs can be found in `logs/<analysis_name>/<date_hour>`, and contain the slurm log (only if ran `pipeline.sh`), the branch and hash of the latest git commit, and a copy of the config file used.

Outputs of the assembly and its analysis can be found in `outputs/<sample_name>/<assembler>/` : 
- `assembly.fasta` : the assembly itself
- `fastqc/<fraction>/fastqc_report.html` : read queality analysis
- `kat/`
    - `<fraction>-stats.tsv` : analysis of the k-mer frequency of reads
    - `kat-plot.png` : comparison of the mapped and unmapped fractions
- `kraken2/<fraction>/krona.html` : taxonomic assignation of reads
- `metaquast/report.txt` : summarised metaquast output, with averages groupped by species groups
- `reads_on_contigs_mapping_evaluation/report.txt` : statistics on the alignment of reads on contigs
- `<binning>/`
    - `bins/` : the bins themselves
    - `checkm/` : completness and contamination assessment of och bins, sorting bins by levels of quality
    - `kraken2/<bin of interst>/` : taxonomic assignation of contigs from a specific bin
    - `gtdbtk/results` : taxonimic assignation of each bins
    - `read_contig_mapping_plot.png` : a plot combining checkm and reads_on_contigs_mapping_evaluation results in a plot to show read mapping by bin quality
