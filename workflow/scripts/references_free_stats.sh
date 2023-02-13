
#!/bin/sh
assembly="../data/assemblies/metaflye_SRR8073713/assembly.fasta"

# 0 : Preprocessing : Sort contigs from highest to lowest, discard those that are too small

# 1 : Calculate total assembly length

# 2 : Calculate N50

# 3 : Calculate % of reads mapped to assembly
coverage_calculator.sh SRR8073713 ../data/input_reads/SRR8073713.fastq.gz ../data/assemblies/metaflye_SRR8073713/assembly.fasta ../data/ ../data
# "$1" : name of the run (SRA accession number)
# "$2" : path to the read to align
# "$3" : path to the merged_reference.fasta
# "$4" : path to the folder to store temporary files ("/" included)
# "$5" : path to the output tsv

samtools coverage ../data/mapping_SRR8073713.bam > ../data/percent.tsv

