#!/bin/sh

cd dependencies
git clone https://github.com/CSB5/OPERA-MS.git

cd OPERA-MS
make
perl OPERA-MS.pl check-dependency