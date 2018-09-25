#!/bin/bash

while true
do
    echo $PWD
    if [[ "$PWD" == "/" ]]
    then
        break
    else
        cd ..
    fi
done
