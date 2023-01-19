#!/bin/sh


for f in "$@"
do  
    #get the accession number
    filename=`basename $f .fastq.gz`
    
    #get the metadata
    metadata=$(./sequencer_fetcher.sh $filename 2> /dev/null)
    
    #assemble
    arguments="maxInputCoverage=10000 corOutCoverage=10000 corMhapSensitivity=high corMinCoverage=0 redMemory=32 oeaMemory=32 batMemory=200"
    mkdir ./data/assemblies/canu_$filename
    case $metadata in
        "PacBio RS II")
            echo "canu -p $filename -d ./data/assemblies/canu_$filename genomeSize=500000 -$metadata -pacbio $f $arguments"        
            $(canu -p $filename -d ./data/assemblies/canu_$filename genomeSize=500000 -pacbio $f $arguments)
            ;;
        "MinION")
            $(canu -p $filename -d ./data/assemblies/canu_$filename genomeSize=500000 -nanopore $f $arguments)
            ;;
        *)
            echo "Unsupported or unrecognized read sequencer !"
            echo $metadata
            ;;
    esac
    echo "============================================"
done





