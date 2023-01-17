#!/bin/sh
#This programs unfold reference genomes to give other scripts an easier access and to give them more informative names
files=(./reference_genomes/*/)

#initialise csv with info on the files
echo "old_filename,file_id,JGI_Grouping_ID,old_directory/path,Short_Organism_Name,Genome/Metagenome_Name,md5_checksum,file_size" > ./reference_genomes/references.csv

for f in "${files[@]}"
do
    #update csv
    echo $( tail "$f"*.csv -n 1 ) >> ./reference_genomes/references.csv

    #  move fasta
    basename=`basename $f`
    mv "$f"*/QC_and_Genome_Assembly/final.assembly.fasta ./reference_genomes/"$basename".fasta

    # remove obsolete folder
    rm -r $f 

done
