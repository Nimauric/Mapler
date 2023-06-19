#!/bin/sh
# This scipt fetches the metadata to get the sequencer used to produce a run, from its SRA accession number
# "$1" : SRA accession number

INPUT=$1
if [ "$INPUT" == Toy ]; then
    echo "PacBio RS II"
    exit 0
fi

# If the information was already fetched, retrieve it
if [ -f ../data/runs_metadata/"$INPUT".txt ] ; then
    cat ../data/runs_metadata/"$INPUT".txt
    exit 0
 
fi

# search the element from its accession name
XML="curl 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=sra&term=$INPUT' -s" 

# get the id in the resulting xml file
ID="$XML | xml sel -t -v '//Id'"
ID=$(eval "$ID")

# get the xml of the run from its id
XML2="curl 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=sra&id=$ID'"

# get the sequencer from that xml
PLATFORM="$XML2 | xml sel -t -v '//INSTRUMENT_MODEL'"
PLATFORM=$(eval "$PLATFORM")


# return the sequencer
if [  -z "${PLATFORM}"  ] ; then
    echo "No sequencer was retrieved !"
    exit 0
fi

echo $PLATFORM > ../data/runs_metadata/"$1".txt
echo $PLATFORM
