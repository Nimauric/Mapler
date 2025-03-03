#!/bin/bash
#SBATCH --job-name=mapler 
#SBATCH --cpus-per-task=16
#SBATCH --mem=10G
#SBATCH --time=1-00:00:00

config=${1:-"config/config.yaml"}

if [[ "$config" == "config/config_test.yaml" ]]; then
    tar -xf "test/test_dataset.tar.gz"
fi

analysis_name=$(grep "analysis_name:" $config | cut -d " " -f 2)
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
log_directory=logs/$analysis_name/$timestamp/

# Log config file and git info
echo "/!\ The execution log isn't saved when run in local mode, please save it manually or if you have access to a slurm cluster, run pipeline.sh instead"
mkdir -p $log_directory
cp $config  $log_directory/config.yaml
echo "Branch: $(git rev-parse --abbrev-ref HEAD)" > $log_directory/git_info.txt
echo "Latest Commit: $(git rev-parse HEAD)" >> $log_directory/git_info.txt



# Launch the pipeline
memory=${SLURM_MEM_PER_NODE:-$(free -m | awk '/^Mem:/ {print $2}')}
snakemake all --cores all \
    --printshellcmds --keep-going \
    --use-conda --rerun-triggers mtime \
    --configfile $log_directory/config.yaml \
    --default-resources mem_mb=5000 mem_mb_per_cpu=None runtime=2*60 \
    --cores $(nproc) \
    --resources mem_mb="$memory" \
    --latency-wait 60


