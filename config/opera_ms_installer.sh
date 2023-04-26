#!/bin/sh

# Install mamba dependencies

#mamba create -y -p ~/operaMS_install_env -c conda-forge perl-app-cpanminus r-rlang

eval "$(conda shell.bash hook)" #Makes it possible to use conda activate
conda activate ~/operaMS_install_env

# Install OPERA-MS
cd dependencies
#git clone https://github.com/CSB5/OPERA-MS.git
cd OPERA-MS
make
perl OPERA-MS.pl check-dependency

cd ../..

