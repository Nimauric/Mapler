#!/usr/bin/env bash
set -euo pipefail

reads_on_contigs=$1
mapped_reads=$2
unmapped_reads=$3

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

echo "extracting unmapped reads..."
write_fastq_gz "$reads_on_contigs" "$unmapped_reads" -f 4

echo "extracting mapped reads..."
write_fastq_gz "$reads_on_contigs" "$mapped_reads" -F 4

echo "Done !"
