#!/bin/sh
cd dependencies

# Download metaMDBG repository  
git clone https://github.com/GaetanBenoitDev/metaMDBG.git

# Create metaMDBG conda environment
cd metaMDBG
conda env create -f conda_env.yml
conda activate metaMDBG
conda env config vars set CPATH=${CONDA_PREFIX}/include:${CPATH}
conda deactivate

# Activate metaMDBG environment
conda activate metaMDBG

# Compile the software
mkdir build
cd build
cmake ..
make -j 3

cd ../../..