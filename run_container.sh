#!/bin/bash

# This script builds and runs the Hugo site inside a Docker container, making it available on
# localhost:80

set -e

cd "$(git rev-parse --show-toplevel)"

repo_name=$(basename "$PWD")

docker build -t ${repo_name}:latest -f Dockerfile .
docker run --rm --detach -p 80:80 --name ${repo_name}-container ${repo_name}:latest
