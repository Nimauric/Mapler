# metagenomic_benchmark
## Description
The aim of this repository is to compare long-reads metagenomic assemblers.

## Files
### Auxiliarry :
 - initialise_environnement.sh : creates folders and sets up the environement. Should only be ran once
 - SraAccList.txt : contains the SRA accession numbers for reads to be downloaded from the SRA database
 - sra_reads_downloader.sh : Downloads the reads using SraAccList.txt as a guide
 - IMG ref organiser : rename and extracts from their folders the reference genomes that were downloaded from the IMG database

### Pipeline :
 - pipeline.sh : calls the Snakefile after activating the environnement
 - activate_environement.sh : activates the genouest environement 
 - Snakefile : coordinates the scripts below
 - reads_quality_checker.sh : checks the reads quality using fastQC
 - metaflye_assembler.sh : assemble metagenomes using metaflye
 - canu_assembler.sh (work in progress): assemble metagenomes using canux
 - sequencer_fetcher.sh : fetch the sequencer used by a SRA run
 - assembly_quality_checker : checks the quality of the assemblies using metaquast




## Usage
Clone the repository in a genouest environnement, then modify the SraAccList.txt file to your liking and run pipeline.sh (if this is the first time you're running it, you need to follow the instruction in the comments of pipeline.sh before running it)
