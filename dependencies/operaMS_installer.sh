#!/bin/sh
cd dependencies
eval "$(conda shell.bash hook)" #Makes it possible to use conda activate

# Download operaMS repository  
git clone https://github.com/CSB5/OPERA-MS.git

# Create operaMS conda environment
cd OPERA-MS
conda env create -y -p operaMS_install_env -c conda-forge perl-app-cpanminus r-rlang
conda activate operaMS_install_env

# Activate operaMS environment
conda activate metaMDBG

# Compile the software
make
perl OPERA-MS.pl check-dependency

cd ../../..
