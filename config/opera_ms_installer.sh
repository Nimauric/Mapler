#!/bin/sh
# Must be executed from dependencies

git clone https://github.com/CSB5/OPERA-MS.git
cd OPERA-MS
cpan App::cpanminus
make
perl tools_opera_ms/install_perl_module.pl
