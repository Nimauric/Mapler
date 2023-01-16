#!/bin/sh
# This script coordinates the various scripts for the long reads metagenomic assembly pipeline


source ./env_init.sh
echo "environement initialisation done"

./shotgun_sequences_downloader.sh
echo "sequences downloaded"

./quality_checker.sh
echo "sequences analysed"

./metaflye_assembler.sh
echo "assembly complete"