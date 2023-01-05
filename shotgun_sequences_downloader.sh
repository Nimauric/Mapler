#!/bin/sh
# Ce script télécharge chaque shotgun sequence dont les numéros d'accession
# sont écrits dans SraAccList.txt

input="./SraAccList.txt"
while IFS= read -r line
do  
    #
        #then
	    #echo "$line" "is already downloaded"
        #else
    echo ""
    echo downloading "$line"...
    #prefetch "$line" --max-size u
    #fasterq-dump "$line"

    if ! ls "$line"* 1> /dev/null 2>&1; then
        echo "fasterq failed, trying fastq..."
        #fastq-dump  "$line"
    fi
done < "$input"
echo "done !"

