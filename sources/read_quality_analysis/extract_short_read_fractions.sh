#!/usr/bin/env bash
set -euo pipefail

bam=$1
output_directory=$2

mkdir -p "$output_directory/mapped"
mkdir -p "$output_directory/unmapped"

cleanup_paths=()

cleanup_tmp() {
    for path in "${cleanup_paths[@]}"; do
        rm -f "$path"
    done
}

trap cleanup_tmp EXIT

samtools_fastq_supports_output_option() {
    { samtools fastq 2>&1 || true; } | grep -Eq -- '(^|[[:space:]])-o[[:space:]]'
}

write_fastq_gz() {
    local bam="$1"
    local output="$2"
    shift 2

    local tmp="${output}.tmp"
    local fifo="${output}.fifo"
    local plain_tmp="${output}.fastq.tmp"

    rm -f "$tmp" "$fifo" "$plain_tmp"
    mkdir -p "$(dirname "$output")"
    cleanup_paths+=("$tmp" "$fifo" "$plain_tmp")

    if samtools_fastq_supports_output_option; then
        mkfifo "$fifo"

        gzip -n -c < "$fifo" > "$tmp" &
        local gzip_pid=$!

        if samtools fastq -@ "$(nproc)" "$@" -o "$fifo" "$bam"; then
            wait "$gzip_pid"
        else
            local samtools_status=$?
            wait "$gzip_pid" || true
            return "$samtools_status"
        fi

        rm -f "$fifo"
    else
        samtools fastq -@ "$(nproc)" "$@" "$bam" > "$plain_tmp"
        gzip -n -c "$plain_tmp" > "$tmp"
        rm -f "$plain_tmp"
    fi

    if [ ! -s "$tmp" ]; then
        echo "Compressed FASTQ output is empty or missing: $tmp" >&2
        exit 1
    fi

    mv "$tmp" "$output"
}

# ------------------------------------------------------------
# Definition used here:
# mapped/unmapped is evaluated per read, not per pair.
# In other words if a read in R1 is mapped and this very same read is unmapped in R2 bcs it's of low quality 
# it will appear in both the mapped and unmapped .html
# ------------------------------------------------------------

# R1 mapped: first in pair (-f 64), read itself mapped (-F 4)
write_fastq_gz "$bam" "$output_directory/mapped/R1.fastq.gz" -f 64 -F 4

# R2 mapped: second in pair (-f 128), read itself mapped (-F 4)
write_fastq_gz "$bam" "$output_directory/mapped/R2.fastq.gz" -f 128 -F 4

# R1 unmapped: first in pair (-f 64) and read itself unmapped (-f 4)
write_fastq_gz "$bam" "$output_directory/unmapped/R1.fastq.gz" -f 68

# R2 unmapped: second in pair (-f 128) and read itself unmapped (-f 4)
write_fastq_gz "$bam" "$output_directory/unmapped/R2.fastq.gz" -f 132
