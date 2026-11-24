#!/usr/bin/env bash
set -euo pipefail

#SBATCH --time=1-01:00:00
#SBATCH --mem=200G
#SBATCH --cpus-per-task=12

#kat comp all three files ?

#kat sect each file individually


sequence=$1 #../outputs/salad_irg_metamdbg/unmapped_reads.fastq.gz #
reference_sequence=$2 #/groups/genscale/nimauric/long_reads/SMRTcell1-M8-fev-sal-irg-1.hifi_reads.fastq 
output_prefix=$3 #test #

output_directory=$(dirname "$output_prefix")
mkdir -p "$output_directory"
tmp_directory=$(mktemp -d "$output_directory/kat_tmp.XXXXXX")

cleanup_tmp() {
    rm -rf "$tmp_directory"
}

trap cleanup_tmp EXIT

prepare_kat_input() {
    local input="$1"
    local label="$2"

    if [[ "$input" == *.gz ]]; then
        local tmp_fastq="$tmp_directory/${label}.fastq"
        gzip -dc "$input" > "$tmp_fastq"
        echo "$tmp_fastq"
    else
        echo "$input"
    fi
}

kat_sequence=$(prepare_kat_input "$sequence" "kat_input")
kat_reference_sequence=$(prepare_kat_input "$reference_sequence" "kat_reference")

kat sect -t "$(nproc)" -n -m 27 --hash_size 1000000000 -o "$output_prefix" "$kat_sequence" "$kat_reference_sequence"

echo "Done !"
