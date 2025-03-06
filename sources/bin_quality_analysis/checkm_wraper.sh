#!/bin/sh

bins_extension="$1"
input_directory="$2"
output_directory="$3"
output_file="$4"
database_dir="$5"

# build directorys
mkdir -p "$output_directory" 

# run checkm2
echo""
rm -r "$output_directory"/*
checkm2 predict --database_path "$database_dir" --input "$input_directory" --extension "$bins_extension" --output-directory "$output_directory" --threads $(nproc) --force

echo "Done !"
