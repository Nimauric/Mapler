#!/bin/sh

for f in "$@"
do  
    #get the accession number
    filename=`basename $f .fastq.gz`
    
    #get the metadata
    metadata=$(./sequencer_fetcher.sh $filename 2> /dev/null)
    
    #assemble
    #flye --meta --out-dir assembly --pacbio-raw ./fastq/SRR8073714.fastq.gz 
    mkdir ./data/assemblies/metaflye_$filename
    case $metadata in
        "PacBio RS II")
            $(flye --meta --out-dir ./data/assemblies/metaflye_$filename --pacbio-raw $f)
            ;;
        "MinION")
            $(flye --meta --out-dir ./data/assemblies/metaflye_$filename --nano-raw $f)
            ;;
        *)
            echo "Unsupported or unrecognized read sequencer !"
            echo $metadata
            ;;
    esac
done

