#!/bin/bash

set -e

# Change to git root directory
cd "$(git rev-parse --show-toplevel)"

hugo --printI18nWarnings

SCRIPT=$(readlink -f "$0")

output=$(grep -rinI todo * \
    --exclude-dir=venv \
    --exclude-dir=.git \
    --exclude-dir=themes \
    --exclude-dir=public \
    --exclude="$(basename "$SCRIPT")" \
    -B 3 -A 3)
if [ -n "$output" ]; then
    count=$(echo "$output" | grep -i todo | wc -l)
    echo "$output"
    echo
    echo "$count TODOs found!"
    exit 1
else
    echo "No TODOs found."
fi
