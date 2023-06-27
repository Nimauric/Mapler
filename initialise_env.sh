#!/bin/sh
#SBATCH --time=6:00:00
#SBATCH --mem=5G

mkdir outputs/

. /local/env/envconda.sh

mamba create -y -p env/snakemake -c bioconda -c conda-forge snakemake=7.20 mamba || \
conda create -y -p env/snakemake -c bioconda -c conda-forge snakemake=7.20 mamba

eval "$(conda shell.bash hook)" #Makes it possible to use conda activate
conda activate env/snakemake

source dependencies/metaMDBG_installer.sh
source dependencies/operaMS_installer.sh

conda activate env/snakemake
