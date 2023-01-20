#!/bin/sh
# This script activates the environnement created by initialise_environnement.sh

echo "setting up the conda environnement..."
. /local/env/envconda.sh
conda activate ~/meta_flye_env

echo "setting up the genouest evnvironnement..."
. /local/env/envsra-tools-2.11.0.sh
. /local/env/envfastqc-0.11.9.sh
. /local/env/envjava-1.8.0.sh
. /local/env/envquast-5.0.2.sh
