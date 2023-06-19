
mkdir outputs/
mkdir env/

. /local/env/envconda.sh
mamba create -y -p env/snakemake -c bioconda -c conda-forge snakemake=7.20 mamba
