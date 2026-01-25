#!/bin/bash

set -e

toplevel="$(git rev-parse --show-toplevel)"

echo "= Checking that links in Markdown files point to directory ="
cd "$toplevel"
cd content

md_files=$(find . -type f -name "*.md")
index_regex='\[[^\]]+\]\([^)]+index\.html[^\)]*\)'
links_to_index_html=()
# Match links (not starting with http, mailto or a #) whose path part does not end with a slash.
# Allow URLs where the path ends with a slash but is followed by a query or fragment (/? or /#).
no_slash_regex='\[[^\]]+\]\((?!http|mailto|#)[^?#\)]*(?<!/|\.svg|\.png|\.jpg|\.jpeg|\.gif)(?:[?#][^)]*)?\)'
links_not_ending_with_slash=()
for file in $md_files; do
    if grep -qP "$index_regex" "$file"; then
        links_to_index_html+=("$file")
    fi
    if grep -qP "$no_slash_regex" "$file"; then
        links_not_ending_with_slash+=("$file")
    fi
done
if [[ ${#links_to_index_html[@]} -gt 0 ]]; then
    echo "Found links to index.html in the following files:"
    for file in "${links_to_index_html[@]}"; do
        echo
        echo $file:
        grep -P "$index_regex" "$file"
    done
    exit 1
else
    echo "No links to index.html found in Markdown files."
fi
if [[ ${#links_not_ending_with_slash[@]} -gt 0 ]]; then
    echo "Found links not ending with a slash in the following files:"
    for file in "${links_not_ending_with_slash[@]}"; do
        echo
        echo $file:
        grep -P "$no_slash_regex" "$file"
    done
    exit 1
else
    echo "All links end with a slash as expected."
fi

echo "= Checking that links in translated Markdown files point to translated content ="
cd "$toplevel"
cd content

supported_translations=(de)
exceptional_links=("/images/" "/privacy-policy/" "/refund-policy/" "/terms/")

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

echo "= Running HTML test ="
cd "$toplevel"

image="wjdp/htmltest"

image_exists=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep -w "$image" || true)
if [ -z "$image_exists" ]; then
    docker pull $image
fi

rm -f $(find ./public -type f -name "*.html")
hugo --buildFuture
cp ./scripts_hugo/.htmltest.yml ./public/

docker run \
    --network=host \
    --volume $(pwd)/public:/test \
    --rm \
    $image \
    --conf /test/.htmltest.yml
