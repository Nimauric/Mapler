#!/bin/sh
# Ce script télécharge chaque shotgun sequence dont les numéros d'accession
# sont écrits dans SraAccList.txt

input="./SraAccList.txt"
while IFS= read -r line
do  
    if [ -f "$line"* ]
        then
            echo "downloading" "$line""..."
            prefetch "$line"
            fasterq-dump "$line"
        else
            echo "$line" "is already downloaded"
    fi
done < "$input"
echo "done !"

