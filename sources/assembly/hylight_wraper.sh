#!/usr/bin/env bash
set -euo pipefail

long_reads="$1"
auxiliary_short_reads_1="$2"
auxiliary_short_reads_2="$3"
tmp_directory="$4"
output="$5"
cleanup="${6:-yes}"
threads="${7:-32}"

min_identity="0.95"
min_ovlp_len="3000"
size="15000"
insert_size="450"

mkdir -p "$(dirname "$output")"
mkdir -p "$tmp_directory"
tmp_directory=$(cd "$tmp_directory" && pwd)

long_read_size_bytes=$(stat -c%s "$long_reads")
gb=$((1024 * 1024 * 1024))

if [ "$long_read_size_bytes" -lt $((5 * gb)) ]; then
    nsplit=100
elif [ "$long_read_size_bytes" -lt $((50 * gb)) ]; then
    nsplit=1000
else
    nsplit=2000
fi

echo "HyLight nsplit selected automatically: $nsplit"

interleaved_reads="$tmp_directory/auxiliary_short_reads.interleaved.fastq"

fastp \
    -i "$auxiliary_short_reads_1" \
    -I "$auxiliary_short_reads_2" \
    --stdout \
    --disable_quality_filtering \
    --disable_length_filtering \
    --disable_adapter_trimming \
    > "$interleaved_reads"

average_read_len=$(awk 'NR % 4 == 2 {sum += length($0); n++} n == 10000 {exit} END {if (n > 0) print int(sum/n); else print 150}' "$interleaved_reads")

if [ -z "$average_read_len" ] || [ "$average_read_len" -le 0 ]; then
    average_read_len=150
fi

echo "HyLight average_read_len estimated automatically: $average_read_len"

hylight \
    -l "$long_reads" \
    -s "$interleaved_reads" \
    --nsplit "$nsplit" \
    -t "$threads" \
    --min_identity "$min_identity" \
    --min_ovlp_len "$min_ovlp_len" \
    --size "$size" \
    --insert_size "$insert_size" \
    --average_read_len "$average_read_len" \
    -o "$tmp_directory"

if [ -s "$tmp_directory/final_contigs.fa" ]; then
    ./sources/assembly/finalize_assembly_output.sh "$tmp_directory/final_contigs.fa" "$output"
elif [ -s "$tmp_directory/long_con_polished.fa" ]; then
    ./sources/assembly/finalize_assembly_output.sh "$tmp_directory/long_con_polished.fa" "$output"
else
    echo "HyLight did not produce final_contigs.fa or long_con_polished.fa" >&2
    echo "Content of tmp directory:" >&2
    ls -lh "$tmp_directory" >&2
    exit 1
fi

if [ "$cleanup" != "no" ] && [ -s "$output" ]; then
    rm -rf "$tmp_directory"
fi
