#!/bin/sh
# Ce script télécharge chaque shotgun sequence dont les numéros d'accession
# sont écrits dans SraAccList.txt

input="./SraAccList.txt"
while IFS= read -r line
do
    echo "downloading" "$line""..."
    fasterq-dump "$line"
done < "$input"
echo "done !"

