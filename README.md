# Mapler (MAEPLR)
Metagenome Assembly and Evaluation Pipeline for Long Reads


## Description
The aim of this repository is to evaluate HiFi long-reads metagenomic assemblies, and can either perform the assembly itself through multiple state-of-the-art assemblers, or evaluate user-submitted assemblies. In addition to classifying assembly bins in classical quality categories according to their marker gene content and taxonomic assignment, Mapler analyzes the alignment of reads on contigs. To do so, it calculates the ratio of mapped reads and bases, and separately analyzes mapped and unmapped reads via their k-mer frequency, read quality, and taxonomic assignment. Those results are displayed in the form of text reports or plots.


## Installation
I recommend using a slurm server, but the pipeline can also be run locally.
Clone the git repository and install snakemake (7.28.3). I recommend using conda :
```
git clone git@gitlab.inria.fr:mistic/mapler.git
conda create -n snakemake -c bioconda snakemake=7.28.3
```
Most other dependencies are installed by the pipeline itself via conda. Exceptions include programs unavailable via conda and large databases, which must be downloaded separately if you want to perform certain analysis :
- [OPERA-MS](https://github.com/CSB5/OPERA-MS), for hybrid assemblies
- the [genome taxonomy database](https://gtdb.ecogenomic.org/), for the taxonomic assignation of bins
- a [kraken database](https://benlangmead.github.io/aws-indexes/k2) (I used the standard kraken database), for the taxonomic assignation of reads and select bins of interest


## Usage
Before using the pipeline, you must create a copy of `config/config_template.yaml` called `config/config.yaml`.
Details on how to configure this file are written as comments of said file,and it is structured in three parts :
- Inputs : path to samples and external programs (most are optional and only needed for certain analysis)
- Controls : sometimes a choice between multiple options (uncomment lines you wish to use, you may select multiple), sometimes a binary choice on whether you wish to run the analysis (true) or not (false)
- Parameters : functional parameters are values that can be tweaked for certain analysis, ressources parameters allows to tweak memory, threads and allocated time for resource-intensive rules


Navigate to the pipeline directory (`mapler`)
If using conda, activate the environment with `conda activate snakemake`.
Then, run `./np_pipeline.sh` to check whether the pipeline will produce the expected results.
If you're in a slurm cluster, run `sbatch pipeline.sh`, otherwise `./local_pipeline.sh`.
If the pipeline crashes and lock itself, you can unlock the working directory with `snakemake --unlock --configfile config.yaml`


## Logs and Outputs
Logs can be found in `logs/<analysis_name>/<date_hour>`, and contain the slurm log (only if you used `pipeline.sh` in a slurm cluster), the branch and hash of the latest git commit, and a copy of the config file used.


Outputs of the assembly and its analysis can be found in `outputs/<sample_name>/<assembler>/` :
- `assembly.fasta` : the assembly itself
- `fastqc/<fraction>/fastqc_report.html` : read quality analysis
- `kat/`
   - `<fraction>-stats.tsv` : analysis of the k-mer frequency of reads
   - `kat-plot.png` : comparison of the mapped and unmapped fractions
- `kraken2/<fraction>/krona.html` : taxonomic assignation of reads
- `metaquast/report.txt` : summarized metaquast output, with averages groupped by species groups
- `reads_on_contigs_mapping_evaluation/report.txt` : statistics on the alignment of reads on contigs
- `<binning>/`
   - `bins/` : the bins themselves
   - `checkm/` : completeness and contamination assessment of och bins, sorting bins by levels of quality
   - `kraken2/<bin of interst>/` : taxonomic assignation of contigs from a specific bin
   - `gtdbtk/results` : taxonomic assignment of each bins
   - `read_contig_mapping_plot.png` : a plot combining checkm and reads_on_contigs_mapping_evaluation results in a plot to show read mapping by bin quality

