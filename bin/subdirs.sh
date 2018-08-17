#! /bin/bash
set -eu

for dir in "$@"; do
    if [ -d "$dir" ]
    then
        subdirs=`find "$dir" | wc -l`
    else
        subdirs='-'
    fi
    printf "%10s %s\n" $subdirs "$dir"
done
