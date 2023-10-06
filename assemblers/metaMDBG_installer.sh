#!/bin/sh
cd dependencies

# Download metaMDBG repository  
git clone https://github.com/GaetanBenoitDev/metaMDBG.git

# Create metaMDBG conda environment
cd metaMDBG

# Activate metaMDBG environment
conda activate metaMDBG

# Compile the software
mkdir build
cd build
cmake ..
make -j 3

cd ../../..