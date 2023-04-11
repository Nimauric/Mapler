#!/bin/sh
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=20000

#input_folder="$1"
output_folder="$2"
out_file="$3"

checkm lineage_wf ../metabat_test/ ./tmp -x fa
# tree, lineage_set, analyze, qa
# Maybe spilt wf into constituent parts to have an idea of the progression and write the qa output in a file ?