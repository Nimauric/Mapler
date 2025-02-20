# Mapler (MAEPLR)
Metagenome Assembly and Evaluation Pipeline for Long Reads


## Description
The aim of this tool is to evaluate HiFi long-reads metagenomic assemblies, and can either perform the assembly itself through multiple state-of-the-art assemblers (metaMDBG, metaflye, hifiasm-meta), or evaluate user-submitted assemblies. In addition to classifying assembly bins in classical quality categories according to their marker gene content and taxonomic assignment, Mapler analyzes the alignment of reads on contigs. To do so, it calculates the ratio of mapped reads and bases, and separately analyzes mapped and unmapped reads via their k-mer frequency, read quality, and taxonomic assignment. Those results are displayed in the form of text reports or plots.

## Installation

Clone the git repository and navigate to the pipeline directory
```
git clone https://gitlab.inria.fr/mistic/mapler.git
cd mapler
```

The pipeline itself requires snakemake and conda, as well as, if on a slurm cluster, the snakemake executor plugin slurm. If they're not already installed, they can be set up in a conda environment :

```bash
conda create -n snakemake 'bioconda::snakemake>=8.28' 'conda-forge::conda>=24.1.2' bioconda::snakemake-executor-plugin-slurm 
conda activate snakemake
```

The pipeline will handle any conda dependencies itself during the execution, but their installation can be quite lengthy.
To download them prior to running the pipeline, it's possible to use the following command.
Note that only a part of the analysis are run on the test dataset. 
To download the environements for other analysis, change the `--configfile` argument.
Those environements will be stored in `.snakemake/conda`

```bash
snakemake --use-conda --conda-create-envs-only  -c1 --configfile config/config_test.yaml
```

<details>
	<summary>Optional databases</summary>

   To run taxonomic assignment, both Kraken 2 (reads) and GTDB-Tk (bins) require external databases. If used, their path must be indicated in the configfile (kraken2db and gtdbtk_database).
   If not already aviable, several Kraken 2 databases are aviable [here](https://benlangmead.github.io/aws-indexes/k2), to be chosen depending on targeted taxa and aviable disk space. The GTDB-Tk reference data can be found [here](https://ecogenomics.github.io/GTDBTk/installing/index.html#installing-gtdbtk-reference-data).

</details>


## Test
To verify the installation, launch the pipeline with a test dataset, either locally or on a cluster
```bash
./local_pipeline.sh config/config_test.yaml > mylog.txt # for local execution
sbatch pipeline.sh config/config_test.yaml # for slurm execution
```
Either way, with 16 CPUs, it should require around 15 minutes (without taking into account dependencies installation) to produces results like this : 
```bash
outputs/test_dataset/
└── metaMDBG
    ├── assembly.fasta
    ├── metabat2_bins_reads_alignement
    │   ├── bins
    │   │   ├── bin.1.fa
    │   │   ├── ...
    │   ├── checkm
    │   │   ├── checkm-plot.pdf # A 2D plot of bin completness and contamination
    │   │   └── checkm_report.txt # A count of near complete, high quality, medium quality and low quality bins, followed by details on each bins
    │   ├── read_contig_mapping_plot.pdf # A visual version of read_contig_mapping.txt
    │   └── read_contig_mapping.txt # A report on the aligned reads and aligned bases ratios, split by bin quality
    └── reads_on_contigs_mapping_evaluation
        └── report.txt # A report on the aligned reads and aligned bases ratios
```


## Usage
The pipeline must be launched from within the pipeline directory. Those familiar with snakemake may directly use snakemake commands to launch it. Otherwise, the following commands can be used :  
```bash
./local_pipeline.sh <configfile> > mylog.txt # for local execution
sbatch pipeline.sh <configfile> # for slurm execution
./np_pipeline.sh <configfile> # to preview the execution
snakemake --unlock --configfile <configfile> # to unlock the working directory after a crash
```
It is recommanded to copy `config/config_template.yaml` as a configfile, and to tweak it according to the analysis's need. 
Details on how to configure this file are written as comments in the template. The configfile is structured in three parts :
- Inputs : path to samples and external programs (most are optional and only needed for certain analysis)
- Controls : allowing a choice between multiple non-exclusive options, or a binary choice on whether the analysis is run (true) or not (false)
- Parameters : functional parameters are values that can be tweaked for certain analyses, resource parameters allows to tweak memory, number of threads and allocated time for resource-intensive rules


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


Logs can be found in `logs/<analysis_name>/<date_hour>`, and contain the slurm log (only if `pipeline.sh` was used in a slurm cluster), the branch and hash of the latest git commit, and a copy of the config file used.
   
## Thrid-party software
Assembly is performed with: [metaMDBG](https://github.com/GaetanBenoitDev/metaMDBG), [hifiasm-meta](https://github.com/xfengnefx/hifiasm-meta), [metaflye](https://github.com/mikolmogorov/Flye), [OPERA-MS](https://github.com/CSB5/OPERA-MS).
Binning is performed with [MetaBAT2](https://bitbucket.org/berkeleylab/metabat/src/master/).
Evaluation is performed with: [checkm](https://github.com/Ecogenomics/CheckM), [GTDB-Tk](https://github.com/Ecogenomics/GTDBTk), [MetaQUAST](https://github.com/ablab/quast), [FastQC](https://github.com/s-andrews/FastQC), [Kraken2](https://github.com/DerrickWood/kraken2), [Krona](https://github.com/marbl/Krona) and [KAT](https://github.com/TGAC/KAT).
Additionally, minimap2, pysam, biopython, pandas, matplotlib and numpy were used to perform custom evaluation



