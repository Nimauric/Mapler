#!/bin/sh

source ./env_init.sh
echo "environement initialisation done"

./shotgun_sequences_downloader.sh
echo "sequences downloaded"

./quality_checker.sh
echo "sequences analysed"