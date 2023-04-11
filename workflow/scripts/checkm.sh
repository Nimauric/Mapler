#!/bin/sh
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=20000

#bins_extensions="fa"
#input_folder="../metabat_test/"
#output_folder="./tmp/"
#out_file="bins_report.tsv"

bins_extension="$1"
input_folder="$2"
output_folder="$3"
out_file="$4"


# build folders
mkdir "$output_folder"
mkdir "$output_folder"tmp/

# call checkm tree, lineage_set, analyze and qa
checkm tree "$input_folder" "$output_folder"tmp/ -x "$bins_extensions"
checkm lineage_set "$output_folder"tmp/ "$output_folder"tmp/markers.txt
checkm analyze "$output_folder"tmp/markers.txt "$input_folder" "$output_folder"tmp/ -x "$bins_extensions"
checkm qa "$output_folder"tmp/markers.txt "$output_folder"tmp/ --tab_table -f "$output_folder""$out_file"


echo "Done !"
