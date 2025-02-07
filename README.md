# Mapler (MAEPLR)
Metagenome Assembly and Evaluation Pipeline for Long Reads


## Description
The aim of this tool is to evaluate HiFi long-reads metagenomic assemblies, and can either perform the assembly itself through multiple state-of-the-art assemblers (metaMDBG, metaflye, hifiasm-meta), or evaluate user-submitted assemblies. In addition to classifying assembly bins in classical quality categories according to their marker gene content and taxonomic assignment, Mapler analyzes the alignment of reads on contigs. To do so, it calculates the ratio of mapped reads and bases, and separately analyzes mapped and unmapped reads via their k-mer frequency, read quality, and taxonomic assignment. Those results are displayed in the form of text reports or plots.


## Installation
I recommend using a slurm server, but the pipeline can also be run locally.
Clone the git repository and install snakemake (tested with version 7.28.3). I recommend using conda :
```
git clone git@gitlab.inria.fr:mistic/mapler.git
conda create -n snakemake -c bioconda snakemake=7.28.3
```

Most other dependencies are installed by the pipeline itself via conda, during execution. If you wish to install the dependencies in advance, you may run the `snakemake --use-conda --conda-create-envs-only  -c1 --configfile <configfile>` command before launching a job.

Some programs unaviable via conda and large databases are not installed automatically, and must be downloaded separately for some optional analysis. If you use them, you must indicate their path in the configfile.
- [OPERA-MS](https://github.com/CSB5/OPERA-MS),  for hybrid assemblies (short and long reads)
- the [genome taxonomy database](https://gtdb.ecogenomic.org/), for the taxonomic assignment of bins with GTDB-Tk
- a [kraken database](https://benlangmead.github.io/aws-indexes/k2) (tested with the standard kraken database), for the taxonomic assignment of reads and selected bins.


## Usage
The pipeline must be launched from within the pipeline directory. It can either be run with `sbatch pipeline.sh` to take advantage of a slurm cluster's ressources, or with `./local_pipeline.sh`. You can also use `./np_pipeline.sh` to preview a run. In either case, a configfile must be provided, either as an argument, or by default `config/config.yaml`. You must configure that configfile before launching the pipeline (a template, `config/config_template.yaml` is provided). Those familiar with snakemake may directly use snakemake commands.

If you use `config/config_test.yaml` as a configfile, a test dataset will be provided

Details on how to configure this file are written as comments in said file. The configfile is structured in three parts :
- Inputs : path to samples and external programs (most are optional and only needed for certain analysis)
- Controls : allowing a choice between multiple options (uncomment lines you wish to use, you may select multiple), or a binary choice on whether you wish to run the analysis (true) or not (false)
- Parameters : functional parameters are values that can be tweaked for certain analyses, resource parameters allows to tweak memory, number of threads and allocated time for resource-intensive rules
  
If the pipeline crashes and locks itself, you can unlock the working directory with `snakemake --unlock --configfile config/config_template.yaml`


## Logs and Outputs
Outputs of the assembly and its analyses can be found in `outputs/<sample_name>/<assembler>/` :
- `assembly.fasta` : the assembly itself
- `fastqc/<fraction>/fastqc_report.html` : read quality analysis
- `kat/`
   - `<fraction>-stats.tsv` : analysis of the k-mer frequency of reads
   - `kat-plot.png` : comparison of the mapped and unmapped fractions
- `kraken2/<fraction>/krona.html` : taxonomic assignation of reads
- `metaquast/report.txt` : summarized metaquast output, aggregated by user-defined species groups (for instance according to species abundance in the sample)
- `reads_on_contigs_mapping_evaluation/report.txt` : statistics on the alignments of reads on contigs
- `<binning>/`
   - `bins/*.fa` : the bins themselves
   - `checkm/` : completeness and contamination assessment of each bin, sorting bins by levels of quality
   - `kraken2/<bin of interst>/` : taxonomic assignment of contigs from a specific bin
   - `gtdbtk/results` : taxonomic assignment of each bin
   - `read_contig_mapping_plot.png` : a plot combining checkm and reads_on_contigs_mapping_evaluation results in a plot to show read mapping by bin quality


Logs can be found in `logs/<analysis_name>/<date_hour>`, and contain the slurm log (only if you used `pipeline.sh` in a slurm cluster), the branch and hash of the latest git commit, and a copy of the config file used.
   
## Thrid-party software
Assembly is performed with:
- metaMDBG (https://github.com/GaetanBenoitDev/metaMDBG)
- hifiasm-meta (https://github.com/xfengnefx/hifiasm-meta)
- metaflye (https://github.com/mikolmogorov/Flye)

Binning is performed with MetaBAT2 (https://bitbucket.org/berkeleylab/metabat/src/master/)

Evaluation is performed with:
- checkm (https://github.com/Ecogenomics/CheckM)
- GTDB-Tk (https://github.com/Ecogenomics/GTDBTk)
- MetaQUAST (https://github.com/ablab/quast)
- FastQC (https://github.com/s-andrews/FastQC)
- Kraken2 (https://github.com/DerrickWood/kraken2)
- Krona (https://github.com/marbl/Krona)
- KAT (https://github.com/TGAC/KAT)

Additionally, I used minimap2, pysam, biopython, pandas, matplotlib and numpy to perform custom evaluation



