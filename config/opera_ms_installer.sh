#!/bin/sh

# Install mamba dependencies
mamba create -y -p ~/operams_test -c conda-forge perl-app-cpanminus r-rlang
conda activate ~/operams_test

# Install OPERA-MS
git clone https://github.com/CSB5/OPERA-MS.git
cd OPERA-MS
make
perl OPERA-MS.pl check-dependency

