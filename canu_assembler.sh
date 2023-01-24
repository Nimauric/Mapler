#!/bin/sh
# This script assemble a set of reads into a metagenome, using canu

for f in "$@"
do  
    #get the accession number
    filename=`basename $f .fastq.gz`
    
    #get the metadata
    metadata=$(./sequencer_fetcher.sh $filename 2> /dev/null)
    
    #assemble
    arguments="maxInputCoverage=10000 corOutCoverage=10000 corMhapSensitivity=high corMinCoverage=0 redMemory=32 oeaMemory=32 batMemory=200"
    #arguments="corMinCoverage=0 corOutCoverage=all corMhapSensitivity=high correctedErrorRate=0.105 corMaxEvidenceCoverageLocal=10 corMaxEvidenceCoverageGlobal=10 oeaMemory=32 redMemory=32 batMemory=200"
    mkdir ./data/assemblies/canu_$filename
    case $metadata in
        "PacBio RS II")
            echo "canu -p $filename -d ./data/assemblies/canu_$filename genomeSize=500000 -$metadata -pacbio $f $arguments"        
            $(canu -p $filename -d ./data/assemblies/canu_$filename genomeSize=500000 -pacbio $f $arguments useGrid=false)
            ;;
        "MinION")
            $(canu -p $filename -d ./data/assemblies/canu_$filename genomeSize=500000 -nanopore $f $arguments useGrid=false)
            ;;
        *)
            echo "Unsupported or unrecognized read sequencer !"
            echo $metadata
            ;;
    esac
    echo "============================================"
done





