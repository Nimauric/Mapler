
config=${1:-"config/config.yaml"}

snakemake -np all --configfile $config --rerun-incomplete --rerun-triggers mtime

#snakemake --unlock --configfile config.yaml
