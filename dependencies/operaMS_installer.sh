#!/bin/sh
cd dependencies
eval "$(conda shell.bash hook)" #Makes it possible to use conda activate

# Download operaMS repository  
git clone https://github.com/CSB5/OPERA-MS.git

# Create operaMS conda environment
cd OPERA-MS
conda create -y -p ../../env/operaMS_install_env -c conda-forge -c bioconda perl-app-cpanminus r-rlang pilon

# Activate operaMS environment
conda activate ../../env/operaMS_install_env

# Compile the software
make
perl OPERA-MS.pl check-dependency

cd ../..
