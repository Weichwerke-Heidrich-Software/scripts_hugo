#!/bin/bash

set -e

# When two websites (like product page and documentation) are updated at the same time,
# they may contain links to each other. The htmltest tool cannot find these links,
# so we need to explicitly ignore them.
# This script collects all links from pages that are updated today.

cd "$(git rev-parse --show-toplevel)"
cd content

todays_links=()
md_files=$(find . -name "*.md" -type f)
today=$(date +%Y-%m-%d)
for file in $md_files; do
    if ! grep -q "$today" "$file"; then
        continue
    fi
    # Extract all links from the markdown file
    links=$(grep -oP '\[.*?\]\(\K.*?(?=\))' "$file" || true)
    # Filter to keep only external links
    links=$(echo "$links" | grep -E '^(http)' || true)
    todays_links+=($links)
done

# Remove duplicate links
printf "%s\n" "${todays_links[@]}" | sort -u
