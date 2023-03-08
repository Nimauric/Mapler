#!/bin/sh
# This script activates the environnement created by initialise_environnement.sh

echo "setting up the conda environnement..."
. /local/env/envconda.sh
conda activate ~/my_env2
