#!/bin/bash

set -e

image="wjdp/htmltest"

cd "$(git rev-parse --show-toplevel)"

hugo
cp ./scripts_hugo/.htmltest.yml ./public/

image_exists=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep -w "$image" || true)
if [ -z "$image_exists" ]; then
    docker pull $image
fi

docker run --volume $(pwd)/public:/test --rm $image --conf /test/.htmltest.yml
