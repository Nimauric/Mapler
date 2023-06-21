
mkdir outputs/


. /local/env/envconda.sh
mamba create -y -p env/snakemake -c bioconda -c conda-forge snakemake=7.20 mamba

./dependencies/metaMDBG_installer.sh
