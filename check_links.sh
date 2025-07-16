#!/bin/bash

set -e

toplevel="$(git rev-parse --show-toplevel)"

echo "= Checking links in Markdown files ="
cd "$toplevel"
cd content

supported_translations=(de)
exceptional_links=("/privacy-policy/" "/refund-policy/" "/terms/")

for lang in "${supported_translations[@]}"; do
    files=$(find . -type f -name "*.$lang.md")
    links_to_english_pages=$(grep -rnP "\[[^\]]+\]\((?!http|mailto|/$lang|#)[^)]+\)" $files || true)
    for link in "${exceptional_links[@]}"; do
        links_to_english_pages=$(echo "$links_to_english_pages" | grep -v "$link" || true)
    done
    if [[ -n "$links_to_english_pages" ]]; then
        count=$(echo "$links_to_english_pages" | wc -l)
        echo "Found $count links from $lang-pages to English pages:"
        echo "$links_to_english_pages"
        exit 1
    else
        echo "Found no links from $lang-pages to English pages."
    fi
done

echo "= Checking links in Hugo site ="
cd "$toplevel"

image="wjdp/htmltest"

image_exists=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep -w "$image" || true)
if [ -z "$image_exists" ]; then
    docker pull $image
fi

rm -f $(find ./public -type f -name "*.html")
hugo
cp ./scripts_hugo/.htmltest.yml ./public/

todays_links=$(./scripts_hugo/todays_links.sh)
if [[ -n "$todays_links" ]]; then
    echo "Attention, ignoring links from pages released today:"
    echo
    echo "$todays_links"
    echo
    echo "Please check manually that these links are correct."

    echo "" >> ./public/.htmltest.yml
    echo "IgnoreURLs:" >> ./public/.htmltest.yml
    echo "$todays_links" | sed 's/^/  - /' >> ./public/.htmltest.yml
fi

docker run \
    --network=host \
    --volume $(pwd)/public:/test \
    --rm \
    $image \
    --conf /test/.htmltest.yml
