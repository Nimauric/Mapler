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
    arguments = "maxInputCoverage=10000 corOutCoverage=10000 corMhapSensitivity=high corMinCoverage=0 redMemory=32 oeaMemory=32 batMemory=200"
    case $metadata in
        "PacBio RS II")
            $(canu -p $filename -d $filename genomeSize=500000 -$metadata -pacbio $f $arguments)
            ;;
        "MinION")
            $(canu -p $filename -d $filename genomeSize=500000 -$metadata -nanopore $f $arguments)
            ;;
        *)
            echo "Unsupported or unrecognized read sequencer !"
            echo $metadata
            ;;
    esac
    echo "============================================"
done


    
canu \
 -p ecoli -d ecoli-pacbio \
 genomeSize=4.8m \
 -pacbio pacbio.fastq



