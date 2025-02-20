
config=${1:-"config/config.yaml"}

if [[ "$config" == "config/config_test.yaml" ]]; then
    if [[ ! -f test/test_dataset.fastq ]]; then
        gzip -d test/test_dataset.fastq.gz
    fi
fi


snakemake -np all --configfile $config --rerun-incomplete --rerun-triggers mtime

#snakemake --unlock --configfile config.yaml
