#!/bin/sh

database="$1"



echo ""
if [ ! -e "$database" ]; then
    parent_dir=$(dirname "$database");
    echo "$parent_dir"/..
    echo "$database"
    mkdir -p "$parent_dir"/..
    checkm2 database --download --path "$parent_dir"/..
fi
