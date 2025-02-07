#!/bin/bash
#SBATCH --job-name=mapler 
#SBATCH --time=3-00:00:00
#SBATCH --mem=100G

config=${1:-"config/config.yaml"}

if [[ "$config" == "config/config_test.yaml" ]]; then
    gzip -d test/test_dataset.fastq.gz
fi

analysis_name=$(grep "analysis_name:" $config | cut -d " " -f 2)
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
log_directory=logs/$analysis_name/$timestamp/

# Log config file and git info
echo "/!\ The exection log isn't saved when run in local mode, please save it manually or if you have access to a slurm cluster, run pipeline.sh instead"
mkdir -p $log_directory
cp $config  $log_directory/config.yaml
echo "Branch: $(git rev-parse --abbrev-ref HEAD)" > $log_directory/git_info.txt
echo "Latest Commit: $(git rev-parse HEAD)" >> $log_directory/git_info.txt

# Launch the pipeline
snakemake all --cores all --jobs 10 \
    --printshellcmds --keep-going \
    --use-conda --rerun-triggers mtime \
    --configfile $log_directory/config.yaml \
    --default-resources mem_mb=5000 mem_mb_per_cpu=None runtime=2*60


