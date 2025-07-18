#!/bin/bash

set -e

for submod in ~/git/*/scripts_hugo/; do
    cd "$submod"
    git checkout main
    git pull
    cd ..

    if [[ -n $(git status --porcelain) ]]; then
        git add .
        git commit -m "Updating submodule scripts_hugo."
        git push
    fi
done
