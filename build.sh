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
./scripts_hugo/ensure_clean_git.sh

sudo rm -rf ./public/tmp/ # Created by htmltest from within a docker container
rm -rf ./public

hugo --minify --gc --cleanDestinationDir --buildFuture
