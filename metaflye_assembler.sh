#!/bin/sh
#SBATCH --mem=30G
files=(./fastq/*.fastq.gz)
for f in "${files[@]}"
do  
    #get the accession number
    filename=`basename $f .fastq.gz`
    
    #get the metadata
    metadata=$(./metadata_fetcher.sh $filename 2> /dev/null)
    
    #assemble
    #flye --meta --out-dir assembly --pacbio-raw ./fastq/SRR8073714.fastq.gz 
    case $metadata in
        "PacBio RS II")
            $(flye --meta --out-dir assembly --pacbio-raw $f)
            ;;
        "MinION")
            $(flye --meta --out-dir assembly --nano-raw $f) 
        *)
            echo "Unsupported or unrecognized read sequencer !"
            echo $metadata
            ;;
    esac
    echo "============================================"
    echo $filename
    echo $metadata
done
