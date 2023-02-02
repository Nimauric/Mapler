#!/bin/sh
# This scipt fetches the metadata to get the sequencer used to produce a run, from its SRA accession number

INPUT=$1

if ["$INPUT"="Toy"]
    echo "PacBio RS II"
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
echo $PLATFORM

