#!/bin/sh

INPUT=$1

# search the element from its accession name V
XML="curl 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=sra&term=$INPUT' -s" 

# get the id in the resulting xml file X
ID="$XML | xml sel -t -v '//Id'"
ID=$(eval "$ID")

# get the xml of the run from its id
XML2="curl 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=sra&id=$ID'"

# get the sequencer from that xml
PLATFORM="$XML2 | xml sel -t -v '//INSTRUMENT_MODEL'"
PLATFORM=$(eval "$PLATFORM")



echo $PLATFORM
