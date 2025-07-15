#!/bin/bash

set -e

# Change to git root directory
cd "$(git rev-parse --show-toplevel)"

echo "= Listing TODOs ="

hugo list drafts
./scripts_hugo/missing_description.sh
./scripts_hugo/missing_translations.sh

SCRIPT=$(readlink -f "$0")

output=$(grep -rinI todo * \
    --include=\*.{md,sh,toml,yml,yaml} \
    --exclude-dir={venv,.git,.vscode,public,themes} \
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
