#! /bin/bash
set -eu

for dir in "$@"; do
    if [ -d "$dir" ]
    then
        subdirs=`find "$dir" -type d -mindepth 1 | wc -l`
    else
        subdirs='-'
    fi
    printf "%10s %s\n" $subdirs "$dir"
done
