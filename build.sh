#!/bin/bash

set -e

cd "$(git rev-parse --show-toplevel)"

cd ./scripts_hugo
git checkout main
git pull
cd ..

./scripts_hugo/missing_description.sh
./scripts_hugo/missing_translations.sh
./scripts_hugo/infer_modify_date_from_git.sh

if [[ -n $(git status --porcelain) ]]; then
  echo "Error: You have unstaged changes."
  git status
  exit 1
fi

sudo rm -rf ./public/tmp/ # Created by htmltest from within a docker container
rm -rf ./public

hugo --minify --gc --cleanDestinationDir
