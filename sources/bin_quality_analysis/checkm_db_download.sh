#!/bin/sh

database_dir="$1"

echo ""
if [ ! -d "$database_dir" ] || [ -z "$(ls -A "$database_dir")" ]; then
    checkm2 database --download --path "$database_dir"
fi
