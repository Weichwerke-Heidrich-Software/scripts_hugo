#!/bin/bash

set -e

supported_translations=("de")

cd "$(git rev-parse --show-toplevel)"

echo "= Checking for missing translations ="

hugo --printI18nWarnings

cd content

count=0
for file in $(find . -name "*.en.md"); do
    for translation in "${supported_translations[@]}";
    do
        if [ ! -f "${file%.en.md}.${translation}.md" ]; then
            echo "Missing translation: ${file%.en.md}.${translation}.md"
            count=$((count+1))
        fi
    done
done

if [ $count -gt 0 ]; then
    echo "Found $count missing translations for published pages!"
    exit 1
fi
