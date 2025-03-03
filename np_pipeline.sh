
config=${1:-"config/config.yaml"}

if [[ "$config" == "config/config_test.yaml" || "$config" == "config/config_test_evaluation_only.yaml" ]]; then
    tar -xf "test/test_dataset.tar.gz"

fi


snakemake -np all --configfile $config --rerun-incomplete --rerun-triggers mtime

#snakemake --unlock --configfile config.yaml
