#!/bin/bash
set -eu

SOURCE_PATH="$1"
TARGET_PATH="$2"

DEPS=`deps $TARGET_PATH | sed "s:$TARGET_PATH:$SOURCE_PATH:"`

rm -f $TARGET_PATH/tags.tmp
touch $TARGET_PATH/tags.tmp

for DEP in $DEPS
do
    if [ -f $DEP ]
    then
        echo Tagging: $DEP
        ctags -a -f $TARGET_PATH/tags.tmp $DEP
    else
        echo File not found: $DEP
    fi
done

wait

echo Updating: $TARGET_PATH/tags
mv $TARGET_PATH/tags.tmp $TARGET_PATH/tags
