#!/bin/sh
#SBATCH --time=1-01:00:00
#SBATCH --mem=200G
#SBATCH --cpus-per-task=12

#kat comp all three files ?

#kat sect each file individually


sequence=$1 #../outputs/salad_irg_metamdbg/unmapped_reads.fastq #
reference_sequence=$2 #/groups/genscale/nimauric/long_reads/SMRTcell1-M8-fev-sal-irg-1.hifi_reads.fastq 
output_prefix=$3 #test #

kat sect -t $(nproc) -n -m 27 --hash_size 1000000000 -o  $output_prefix $sequence $reference_sequence 

echo "Done !"
