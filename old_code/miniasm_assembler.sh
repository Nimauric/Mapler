#!/bin/sh

for f in "$@"
do
    filename=`basename $f .fastq.gz`

    echo "assembling $filename ..."
    # Get the metadata
    metadata=$(./sequencer_fetcher.sh $filename 2> /dev/null)

    # Align reads with minimap2
    case $metadata in
        "PacBio RS II")
            minimap2 -x ava-pb "$f" "$f" | gzip -1 > data/mapping/minimap_"$filename".paf.gz
            ;;
        "MinION")
            minimap2 -x ava-ont "$f" "$f" | gzip -1 > data/mapping/minimap_"$filename".paf.gz
            ;;
        *)
            echo "Unsupported or unrecognized read sequencer !"
            echo $metadata
            ;;
    esac
    
    mkdir ./data/assemblies/miniasm_"$filename"/
    # Assemble them with miniasm
    miniasm -f $f data/mapping/minimap_"$filename".paf.gz > ./data/assemblies/miniasm_"$filename"/assembly.gfa

    # Convert the outputed .gfa into a .fasta
    awk '/^S/{print ">"$2"\n"$3}' ./data/assemblies/miniasm_"$filename"/assembly.gfa > ./data/assemblies/miniasm_"$filename"/assembly.fasta

done
