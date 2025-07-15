#!/bin/bash

set -e

supported_translations=("de")
exceptions=("privacy-policy" "refund-policy" "terms")

cd "$(git rev-parse --show-toplevel)"
cd content

echo "= Checking for missing translations ="

count=0
for file in $(find . -name "*.en.md"); do
    for exception in "${exceptions[@]}"; do
        if [[ "$file" == *"/$exception/index.en.md" ]]; then
            echo "Skipping exception: $file"
            continue 2
        fi
    done
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
