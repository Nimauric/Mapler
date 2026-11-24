# Mapler (MAEPLR)
Metagenome Assembly and Evaluation Pipeline


## Description
Mapler is a Snakemake pipeline for metagenomic assembly, binning and evaluation from PacBio HiFi, Oxford Nanopore and Illumina reads.

Mapler can run long-read, short-read and hybrid assemblers, perform binning, and evaluate assemblies and MAGs using mapping-based metrics, reference-based analyses, taxonomic assignment and read-quality reports. It can also evaluate user-submitted assemblies and bins.

## Installation

Clone the git repository and navigate to the pipeline directory
```
git clone https://gitlab.inria.fr/mistic/mapler.git
cd mapler
```

The pipeline requires Snakemake and Conda. If running on a SLURM cluster, the Snakemake SLURM executor plugin is also needed. If they're not already installed, they can be set up in a conda environment:

```bash
conda create -n mapler -c bioconda -c conda-forge 'bioconda::snakemake>=8.28' 'conda-forge::conda>=24.1.2' bioconda::snakemake-executor-plugin-slurm 
conda activate mapler
```

The pipeline will handle and download any conda dependencies during the execution.
To install them prior to running the pipeline and speed up the first execution of the pipeline, it's possible to use the following command.
Those environments will be stored in `.snakemake/conda`

```bash
snakemake --use-conda --conda-create-envs-only  -c1 --configfile config/config_test.yaml
```
Note that only part of the analysis is run on the test dataset. 
To install the environments for other analyses, change the `--configfile` argument.

<details>
	<summary>Optional databases</summary>

   To run taxonomic assignment, both Kraken 2 (reads) and GTDB-Tk (bins) require external databases. If used, their path must be indicated in the configfile (kraken2db and gtdbtk_database).
   If not already available, several Kraken 2 databases are available [here](https://benlangmead.github.io/aws-indexes/k2), to be chosen depending on targeted taxa and available disk space. The GTDB-Tk reference data can be found [here](https://ecogenomics.github.io/GTDBTk/installing/index.html#installing-gtdbtk-reference-data).

</details>


## Testing the pipeline
To speed this up, `config/config_test_evaluation_only.yaml` may be used instead of `config/config_test.yaml`. This will only perform the evaluation, on a precomputed assembly and set of bins. 
To verify the installation, launch the pipeline with the test dataset (included in `test/test_dataset.tar.gz`, decompressed automatically), either locally
```bash
./local_pipeline.sh config/config_test.yaml > mylog.txt
```
Or on a cluster:
```bash
sbatch pipeline.sh config/config_test.yaml
```
Either way, with 16 CPUs and 15G of RAM, it should require around 15 minutes, not including dependency installation, to produce the following results: 
```bash
outputs/test_dataset/
└── metaMDBG
    ├── assembly.fasta.gz
    ├── metabat2_bins_reads_alignement
    │   ├── bins
    │   │   ├── bin.1.fa
    │   │   ├── ...
    │   ├── checkm
    │   │   ├── checkm-plot.pdf # A 2D plot of bin completeness and contamination
    │   │   └── checkm_report.txt # A count of near complete, high quality, medium quality and low quality bins, followed by details on each bins
    │   ├── read_contig_mapping_plot.pdf # A visual version of read_contig_mapping.txt
    │   └── read_contig_mapping.txt # A report on the aligned reads and aligned bases ratios, split by bin quality
    └── reads_on_contigs_mapping_evaluation
        └── report.txt # A report on the aligned reads and aligned bases ratios
```

## Usage
The pipeline must be launched from within the pipeline directory. Those familiar with snakemake may directly use snakemake commands to launch it. Otherwise, the following commands can be used:  
```bash
./local_pipeline.sh <configfile> > mylog.txt # for local execution
sbatch pipeline.sh <configfile> # for SLURM execution
./np_pipeline.sh <configfile> # to preview the execution
snakemake --unlock --configfile <configfile> -np # to unlock the working directory after a crash
```
It is recommended to copy `config/config_template.yaml` as a configfile, and to tweak it according to the analysis's needs. 
Details on how to configure this file are written as comments in the template. The configfile is structured in three parts:
- Inputs: path to samples and external programs (most are optional and only needed for certain analyses)
- Controls: allowing a choice among multiple non-exclusive options, or a binary choice on whether the analysis is run (true) or not (false)
- Parameters: functional parameters define values that can be adjusted for certain analyses, while resource parameters allow users to configure memory, threads, and execution time

Input samples are described in the configuration file. Each sample has a sequencing technology (`hifi`, `ont` or `illumina`), which allows Mapler to apply the appropriate parameters and tool logic for each data type. The pipeline also prevents incompatible tool/input combinations, such as running a short-read assembler on long-read data. Detailed examples and comments are provided in `config/config_template.yaml`.

For hybrid analyses, long-read samples may optionally include auxiliary Illumina paired-end reads. Support for hybrid assemblers such as OPERA-MS and HyLight is currently being integrated and tested. These auxiliary short reads can also be used for short-read co-binning. See `config/config_template.yaml` for examples.

<details>
	<summary>Multiple user-provided assemblies and binning</summary>

   To use multiple user-provided assemblies and binning, you can either run them one at a time, or put the corresponding files (via a copy or the creation of a symbolic link) the assembly and/or bins like this:
   ```bash
   outputs/<sample_name>/<custom_assembly_process>/assembly.fasta.gz
   outputs/<sample_name>/<assembly>/<custom_binning_process>_bins_reads_alignement/bins/<bins.fa>
   ```
   
   Then, in the configfile, insert <custom_assembly_process> in the list of assemblers and/or <custom_binning_process> in the list of binners, and launch the pipeline as usual. It should look something like this: 
   
   ```bash
   samples: 
      - name: <sample_name>
        technology: hifi
        read_path: </read/path.fastq>
      - name: <another_sample_name>
        technology: ont
        read_path: </read/path.fastq>
   [...]
   assemblers: # uncomment assemblers to use them
   # - metaMDBG
    - <custom_assembly_process>
   [...]
   binners: # uncomment binners to use them
   # - metabat2
    - <custom_binning_process>
   ```
   Please note that <custom_assembly_process> cannot have the same name as any of the built-in assembly processes (metaMDBG, custom_assembly, metaflye, myloasm, hifiasm_meta, metaspades, operaMS, hylight). Likewise, the <custom_binning_process> cannot have the same name as any of the built-in binning processes (metabat2, custom)

</details>

## Logs and Outputs
```bash
# Comments describe the required configuration of the config file
outputs
└── <sample_name>
    ├── long_reads_on_reference.<reference>.bam # Requires reference_mapping_evaluation: true
    ├── short_reads_on_reference.<reference>.bam # Requires reference_mapping_evaluation: true
    └── <assembler> # multiple choice in the assemblers field
        ├── assembly.fasta.gz
        ├── fastqc # Requires fraction_evaluation_tools.short_reads: [fastqc]
        │   └── <fraction_name> # multiple choice in the fractions field
        │       ├── R1_fastqc.html
        │       ├── R1_fastqc.zip
        │       ├── R2_fastqc.html
        │       └── R2_fastqc.zip
        ├── nanoplot # Requires fraction_evaluation_tools.long_reads: [nanoplot]
        │   └── <fraction_name>
        │       └── NanoPlot-report.html
        ├── kat # Requires kat: true
        │   ├── kat-plot.pdf # Requires both "mapped" and "unmapped" fractions
        │   └── <fraction_name>-stats.tsv
        ├── kraken2 # Requires kraken2: true
        │   └── <fraction_name>
        │       ├── kraken2.tsv
        │       ├── krona.html
        │       └── krona.html.files
        ├── metaquast # Requires metaquast: true
        │   ├── report.txt
        │   └── results/
        ├── <fraction_name>_reads.fastq.gz # For either "mapped" or "unmapped" fraction analysis
        ├── <binner>_bins_reads_alignement                        # Requires binning: true and long_read_binning: true
        ├── <binner>_bins_short_reads_alignement                  # Requires binning: true and short_read_binning: true
        ├── <binner>_bins_cobinning_alignement                    # Requires binning: true, short_read_cobinning: true and auxiliary_short_reads_1/2 on a long-read sample
        ├── <binner>_bins_additional_reads_cobinning_alignement   # Requires binning: true and additional_reads_cobinning: true
        │   ├── bins
        │   │   ├── bin.1.fa
        │   │   ├── ...
        │   │   └── contigs_depth.txt
        │   ├── checkm # Requires checkm: true
        │   │   ├── checkm-plot.pdf
        │   │   ├── checkm_report.txt
        │   │   └── quality_report.tsv
        │   ├── gtdbtk # Requires gtdbtk:true
        │   ├── kraken2 # Requires kraken2_on_bins:true
        │   ├── read_contig_mapping_plot.pdf # Requires both checkm: true and read_mapping_evaluation: true
        │   └── read_contig_mapping.txt # Requires both checkm: true and read_mapping_evaluation: true
        ├── reads_on_contigs.bam
        ├── reads_on_contigs.bam.bai
        ├── short_reads_on_contigs.bam # Requires short_read_mapping_evaluation: true or short_read_binning: true
        ├── auxiliary_short_reads_on_contigs.bam # Requires short_read_cobinning: true
        ├── contigs_on_reference.<reference>.bam # Multiple choices in the reference_genomes field. Requires contigs_on_reference_mapping:true
        └──  reads_on_contigs_mapping_evaluation # Requires read_mapping_evaluation: true
            └── report.txt
```
Logs can be found in `logs/<analysis_name>/<date_hour>`, and contain the SLURM log (only if `pipeline.sh` was used in a SLURM cluster), the branch and hash of the latest git commit, and a copy of the config file used.

## Results interpretation
### Read mapping
By aligning the reads on the contigs, we can look at two key metrics: 
 - Aligned read ratio: Aligned read count / Total read count
 - Aligned base ratio: Aligned read bases / Total read length

The higher those ratios are, the more representative of the sequenced sample is the assembly.
If the aligned read ratio is significantly higher than the aligned base ratio, it is a sign that most reads are only partially aligned to contigs.

`reads_on_contigs_mapping_evaluation/report.txt` gives a global overview of those ratios, while read_contig_mapping.txt and read_contig_mapping_plot.pdf provide a breakdown of the ratios separated by bin quality. 

Here's an example of read_contig_mapping_plot.pdf: 

![most reads are either unmapped or aligned to unbinned contigs or low-quality bins, with less than 20% of medium, high or near complete quality. Moreover, the alignment length ratio is visibly lower than the aligned read ratio](https://gitlab.inria.fr/-/project/48336/uploads/f84ee66686f8f09a7f335e836c0b4ef1/Screenshot_from_2025-02-26_15-28-45.png)

### Analysis of reads by category
In samples where a significant proportion of the reads is not assembled, it can be useful to compare the set of reads that are represented by the assembly (mapped reads) with the set of reads that are not (unmapped reads).
Fractions can include all reads (`full`), reads mapped to contigs (`mapped`) and reads not mapped to contigs (`unmapped`). Long-read quality reports use NanoPlot, while Illumina paired-end quality reports use FastQC. Other optional analyses can compare taxonomic assignment and k-mer abundance between fractions.

Mapler includes these read set analyses:
<details>
	<summary>NanoPlot</summary>

   NanoPlot reports long-read quality metrics for selected fractions when `fraction_evaluation_tools.long_reads` includes `nanoplot`.
</details>
<details>
	<summary>FastQC</summary>
   
   With FastQC, it's possible to look into basic differences between Illumina paired-end read fractions. Generally, the unmapped reads are slightly shorter and of slightly worse quality than the assembled reads on average.
   They can also tend to have a different GC ratio, but this is unlikely to reflect an actual assembly bias and more likely to be the result of a particular high abundance population being assembled better and happening to have a specific GC ratio.

Here's an example of a FastQC HTML report:
![Per base sequence quality plot](https://gitlab.inria.fr/-/project/48336/uploads/5b9bc2c9322a112c9799f9c49fbd9a37/image.png)
</details>
<details>
	<summary>Kraken 2</summary>

   By exploring the Krona plots, it's possible to check whether some taxa are only present in the unassembled portion of the reads, or whether some species have only been partially assembled, being present in both of the assembled and unassembled parts of the assembly. 
   Here's an example of krona.html: 
![Krona plot](https://gitlab.inria.fr/-/project/48336/uploads/41595f9710202edc41488a34d20c6055/image.png)


</details>
<details>
	<summary>KAT</summary>

   By computing the abundance of each read (via its median k-mer abundance) from the full set of reads, it is possible to check whether some abundances are better assembled than others. 
   Typically, low abundance reads are more libely to be more abundant in the unmapped portions, but the proportion and abundance threshold may very depending on the assembler used.
   Here's an example of `kat-plot.pdf`: 

   ![A plot showing the abundance of unmapped reads, mostly unique, with some more abundant reads, in a sort of exponential decay with some reads with a median k-mer occurrence of 2 or even 3, and mapped reads, also looking like an exponential decay, with with a less sharp decay, with still some reads with a median k-mer occurrence of 16](https://gitlab.inria.fr/-/project/48336/uploads/c573bd3e4c4c5a972da11e02dd868e00/Screenshot_from_2025-02-26_15-31-27.png)

</details>

<br>
<details>
	<summary>User-provided read categories</summary>

   Just like with user-provided assemblies, additional read categories can be inserted (via a file copy or the creation of a symbolic link) in the pipeline, and will be treated like any other: 
   ```bash
   outputs/<sample_name>/<assembler>/<fraction_name>_reads.fastq
   ```
   
   Then, in the configfile, insert <fraction_name> in the list of read categories, and launch the pipeline as usual. It should look something like this: 

   ```bash
   fractions:
    - <fraction_name>
   # - full #all reads
   # - mapped #reads that mapped to a contig, and were successfully assembled
   # - unmapped #reads that are not mapped to a contig
   ```
   Please note that <fraction_name> cannot have the same name as any of the built-in categories (full, mapped, unmapped)
</details>

   
## Third-party software
Assembly is performed with: metaMDBG ([git](https://github.com/GaetanBenoitDev/metaMDBG), [article](https://doi.org/10.1038/s41587-023-01983-6)),
hifiasm-meta ([git](https://github.com/xfengnefx/hifiasm-meta), [article](https://www.nature.com/articles/s41592-022-01478-3)),
metaflye ([git](https://github.com/mikolmogorov/Flye), [article](https://www.nature.com/articles/s41592-020-00971-x)),
myloasm ([git](https://github.com/bluenote-1577/myloasm)),
metaSPAdes ([git](https://github.com/ablab/spades), [article](https://genome.cshlp.org/content/27/5/824)),
HyLight ([git](https://github.com/LuoGroup2023/HyLight)),
OPERA-MS ([git](https://github.com/CSB5/OPERA-MS), [article](https://www.nature.com/articles/s41587-019-0191-2)).
Binning is performed with MetaBAT2 ([code](https://bitbucket.org/berkeleylab/metabat/src/master/), [article](https://pmc.ncbi.nlm.nih.gov/articles/PMC6662567/)).
Evaluation is performed with: 
checkM2 ([git](https://github.com/chklovski/CheckM2), [article](https://www.nature.com/articles/s41592-023-01940-w)),
GTDB-Tk ([git](https://github.com/Ecogenomics/GTDBTk), [article](https://academic.oup.com/bioinformatics/article/36/6/1925/5626182)),
MetaQUAST ([git](https://github.com/ablab/quast), [article](https://academic.oup.com/bioinformatics/article/32/7/1088/1743987)),
FastQC ([git](https://github.com/s-andrews/FastQC), [website](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)),
NanoPlot ([git](https://github.com/wdecoster/NanoPlot), [article](https://academic.oup.com/bioinformatics/article/34/15/2666/4934939)),
Kraken2 ([git](https://github.com/DerrickWood/kraken2), [article](https://genomebiology.biomedcentral.com/articles/10.1186/s13059-019-1891-0)),
Krona ([git](https://github.com/marbl/Krona), [article](https://bmcbioinformatics.biomedcentral.com/articles/10.1186/1471-2105-12-385)),
KAT ([git](https://github.com/TGAC/KAT), [article](https://academic.oup.com/bioinformatics/article/33/4/574/2664339)).
Additionally, minimap2, pysam, biopython, pandas, matplotlib and numpy are used to produce custom mapping-based reports.

## FAQ
<details>
	<summary>How to run Mapler with low computing resources ?</summary>

   The default resources in `config/config_template.yaml` are designed to handle large and complex datasets (150G soil sample). 
   On smaller or less diverse datasets, it is possible to lower their required memory.

   Kraken2 and KAT are both quite memory intensive, if resources are limited, they can be skipped by setting `kat: false`and `kraken2: false`in the config file. 

   The assembly is also quite costly. If available, using a precomputed assembly as an input can save computational resources.
</details>

<details>
	<summary>How to run taxonomic assignment ?</summary>

   There are three ways to use taxonomic assignment with mapler :
- Taxonomic assignment of reads : done with kraken2 (`kraken2: true` in the config file) 
- Taxonomic assignment of all bins : done with GTDB-Tk (`gtdbtk: true` in the config file)
- Taxonomic assignment of specific bins of the bins folder : done with kraken2 (`kraken2_on_bins: true`in the config file). It is generally recommended to use GTDB-Tk on bins, but kraken2 can provide a way to check for coherence between the reads and specific bins.
</details>

<details>
	<summary>Does mapler accept compressed input files ?</summary>

   Most Mapler rules accept gzip-compressed FASTQ files. Some third-party tools, especially OPERA-MS, may be more restrictive; if OPERA-MS fails with compressed reads, use uncompressed FASTQ files.
</details>

<details>
	<summary>Does mapler require internet access ?</summary>

   Most rules do not require internet access, although there is one exception : kronadb_download, used to download krona taxonomy for kraken2 analyses.
   If not already present and included in the config file, the checkm2 database (rule checkm_db_download) and mash (rule gtdbtk_on_bins) databases also require an internet connection to be downloaded the first time they are used.
</details>


## Citation
   Nicolas Maurice, Claire Lemaitre, Riccardo Vicedomini, Clémence Frioux, [Mapler: a pipeline for assessing assembly quality in taxonomically rich metagenomes sequenced with HiFi reads](https://academic.oup.com/bioinformatics/article/41/6/btaf334/8157874), Bioinformatics (2025)
