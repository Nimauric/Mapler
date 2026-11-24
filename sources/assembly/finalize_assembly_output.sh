#!/usr/bin/env bash
set -euo pipefail

input_assembly="$1"
output_assembly="$2"

mkdir -p "$(dirname "$output_assembly")"

if [ ! -s "$input_assembly" ]; then
    echo "Input assembly does not exist or is empty: $input_assembly" >&2
    exit 1
fi

if [[ "$output_assembly" == *.gz ]]; then
    if [[ "$input_assembly" == *.gz ]]; then
        cp "$input_assembly" "$output_assembly"
    else
        gzip -n -c "$input_assembly" > "$output_assembly"
    fi
else
    cp "$input_assembly" "$output_assembly"
fi

if [ ! -s "$output_assembly" ]; then
    echo "Final assembly output was not created or is empty: $output_assembly" >&2
    exit 1
fi
