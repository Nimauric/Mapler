#!/bin/sh
# Ce script télécharge chaque shotgun sequence dont les numéros d'accession
# sont écrits dans SraAccList.txt

input="./SraAccList.txt"
while IFS= read -r line
do  
    #if ls "$line"* 1> /dev/null 2>&1
        #then
	    #echo "$line" "is already downloaded"
        #else
            echo "downloading" "$line""..."
	    prefetch "$line" --max-size u
            fasterq-dump "$line"
    #fi
done < "$input"
echo "done !"

