#!/bin/sh
#SBATCH --time=0-01:00:00
#SBATCH --mem=10G
#SBATCH --cpus-per-task=24
#conda activate .snakemake/conda/5d2e4a1fd40405f7cd25f2b961322ceb_
#./sources/mapping.sh outputs/zymo/metaMDBG/contigs_on_reference.Saccharomyces_cerevisiae.bam outputs/zymo/metaMDBG/assembly.fasta /groups/genscale/nimauric/ZymoD6331/Saccharomyces_cerevisiae.fasta
#./sources/mapping.sh outputs/zymo/metaMDBG/contigs_on_reference.Salmonella_enterica.bam outputs/zymo/metaMDBG/assembly.fasta /groups/genscale/nimauric/ZymoD6331/Salmonella_enterica.fasta


output="$1"
query="$2"
target="$3"
preset="$4" #map-hifi or asm20 or sr
additional_query="$5" # In case of short read mapping, query= R1, query2 = R2.

echo minimap2 -a -t $(nproc) -cx $preset $target $query $additional_query
echo samtools sort --threads $(nproc) -o $output
echo samtools index $output

minimap2 -a -t $(nproc) -cx $preset $target $query $additional_query\
    | samtools sort --threads $(nproc) -o $output \
    && samtools index $output




